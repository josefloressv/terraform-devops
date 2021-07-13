provider "aws" {
  region = "us-east-2"
}

resource "aws_kms_key" "goweb-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "goweb-s3-backend" {
  bucket = var.back_s3_bucket_name
  acl    = var.back_s3_acl
  tags   = var.back_s3_tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.goweb-key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

}
