terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "security_demo" {
  bucket_prefix = "jjacala-security-demo-"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "security_demo" {
  bucket = aws_s3_bucket.security_demo.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "security_demo" {
  bucket = aws_s3_bucket.security_demo.id
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