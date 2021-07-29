terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

module "website_s3_bucket" {
  source = "./modules/aws-s3-static-website-bucket"

  bucket_name = var.bucket_name

  tags = var.bucket_tags
}

# References
# https://learn.hashicorp.com/tutorials/terraform/module-create?in=terraform/modules
