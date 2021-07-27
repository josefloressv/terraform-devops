provider "aws" {
  region = var.region
}

locals {
  amazon_ami_by_regions = {
    "us-east-1" = "0dc2d3e4c0f9ebd18", # N. Virginia
    "us-east-2" = "0233c2d874b811deb", # Ohio
    "us-west-1" = "0ed05376b59b90e46", # N. California
    "us-west-2" = "0dc8f589abe99f538", # Oregon
  }
}

resource "aws_instance" "web" {
  count             = var.ec2_num_instances
  ami               = "ami-${local.amazon_ami_by_regions[var.region]}"
  instance_type     = var.ec2_instance_type
  availability_zone = "${var.region}${var.ec2_az}"
  tags = merge(
    var.ec2_tags,
    {
      Name = "ec2-web-${count.index + 1}"
    }
  )
}
