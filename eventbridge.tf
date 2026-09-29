# create the iam role we need to let the lambda execute

resource "aws_iam_role" "lambda_role" {
  name = "aws-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# give the role basic execution permissions

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# define policy document for public access block operations

data "aws_iam_policy_document" "lambda_s3_block_doc" {
  statement {
    sid = "AllowLambdaS3PublicAccessBlock"
    effect = "Allow"

    actions = [
      "s3:PutBucketPublicAccessBlock",
      "s3:GetBucketPublicAccessBlock"
    ]

    # we have to be careful giving it access to every bucket
    # however, our use case necessitates the capacity to remediate every bucket
    resources = ["*"]
  }
}


# create the policy for public access block operations

resource "aws_iam_policy" "lambda_s3_block" {
  name = "lambda-s3-public-access-block-operation"
  policy = data.aws_iam_policy_document.lambda_s3_block_doc.json
}

# give the role the ability to re-enable public access block

resource "aws_iam_role_policy_attachment" "lambda_remediate_block" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_block.arn
}

# use terraform data feature to zip the lambda source code

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/lambda_function.py"
  output_path = "${path.module}/src/lambda_function.zip"
}

# define the lambda function

resource "aws_lambda_function" "security_automation" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "security-automation-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
}

# define the eventbridge rule

resource "aws_cloudwatch_event_rule" "config_rule_trigger" {
  name        = "aws-config-rule-trigger"
  description = "Triggers when the aws config compliance state changes"

  event_pattern = jsonencode({
    detail-type = [
      "Config Rules Compliance Change"
    ]
  })
}

# give eventbridge the permission to execute the lambda function we defined

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.security_automation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.config_rule_trigger.arn
}

# set the lambda as the target for the eventbridge rule

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.config_rule_trigger.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.security_automation.arn
}