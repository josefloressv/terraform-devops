provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "ubuntu-instance-v2" {
  ami           = var.ami_id
  key_name      = var.key_name
  instance_type = var.instance_type
  tags          = var.tags
}