terraform {
    backend "s3" {
        bucket = "whizlabs-tf-2021"
        key    = "terraform.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "web" {
    ami           = "ami-0dc2d3e4c0f9ebd18"
    instance_type = "t2.micro"
}

# combine Labs: s03-s3-bucket