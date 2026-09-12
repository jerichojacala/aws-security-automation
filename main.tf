# set the terraform version to use
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# define the cloud provider
provider "aws" {
  region = "us-east-1"
}

# create a bucket to use as a vulnerability
# we set force destroy flag to allow for the bucket to
# be destroyed if non-empty
resource "aws_s3_bucket" "security_demo" {
  bucket_prefix = "jjacala-security-demo-"
  force_destroy = true
}

# aws has a public access block as a safeguard while configuring
# for this exercise, we turn it off to test our own infrastructure
resource "aws_s3_bucket_public_access_block" "security_demo" {
  bucket = aws_s3_bucket.security_demo.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# set the bucket to be publicly READABLE
resource "aws_s3_bucket_policy" "security_demo" {
  bucket     = aws_s3_bucket.security_demo.id
  depends_on = [aws_s3_bucket_public_access_block.security_demo]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "PublicRead"
        Effect = "Allow"

        Principal = "*"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.security_demo.arn}/*"
      }
    ]
  })
}