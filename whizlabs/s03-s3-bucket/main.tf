provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "mybucket01" {
  bucket = "whizlabs-tf-2021"
  acl    = "private"
  tags = {
    Name        = "whizlabs-tf-2021"
    Environment = "dev"
  }
}

# OUTPUTS
output "bucket_arn" {
  value       = aws_s3_bucket.mybucket01.arn
  description = "ARN of the S3 bucket"
}

# docs https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket