provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "is-public"
    values = ["true"]
  }
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.amazon2.id
  instance_type = "t2.micro"
}

# References
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami_ids
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
