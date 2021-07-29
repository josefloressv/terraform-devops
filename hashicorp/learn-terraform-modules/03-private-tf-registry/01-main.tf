terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "remote" {
    organization = "josefloressv-training"

    workspaces {
      name = "test-aws-s3-webapp"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "website_s3_bucket" {
  source      = "app.terraform.io/josefloressv-training/s3-webapp/aws"
  version     = "1.0.0"
  bucket_name = var.bucket_name

  tags = var.bucket_tags
}

# References
# https://learn.hashicorp.com/tutorials/terraform/module-private-registry-share?in=terraform/modules
