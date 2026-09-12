# create a role to be used for config security automation
resource "aws_iam_role" "config" {
  name = "aws-config-security-automation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "config.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# attach the aws config policy to the role we created
resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# create the config recorder with this new role
resource "aws_config_configuration_recorder" "security" {
  name     = "security-automation-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = false
    include_global_resource_types = false
    resource_types                = ["AWS::S3::Bucket"]
  }

  recording_mode {
    recording_frequency = "CONTINUOUS"
  }
}

# create the bucket in which we store messages from the recorder
resource "aws_s3_bucket" "config_delivery" {
  bucket_prefix = "jjacala-config-history-"
  force_destroy = true
}

# TODO: assign permissions for the config recorder to check bucket acl and write
resource "aws_s3_bucket_policy" "config_delivery_policy" {
  bucket = aws_s3_bucket.config_delivery.id

  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        # grant the config permission to get the bucket acl
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config_delivery.arn
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        # grant the config permission to write logs to the bucket
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config_delivery.arn}/AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# create the delivery channel for the config recorder and bucket
resource "aws_config_delivery_channel" "security" {
  name           = "security-automation-delivery"
  s3_bucket_name = aws_s3_bucket.config_delivery.bucket

  depends_on = [
    aws_config_configuration_recorder.security,
    aws_s3_bucket_policy.config_delivery_policy
  ]
}

# turn on the config recorder
resource "aws_config_configuration_recorder_status" "security" {
  name       = aws_config_configuration_recorder.security.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.security
  ]
}

# todo: build config rule