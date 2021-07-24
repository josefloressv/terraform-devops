provider "aws" {
  # last version
}

resource "aws_instance" "whizlabs_ec2_demo" {
  ami           = "ami-0dc2d3e4c0f9ebd18" # Amazon Linux 2 AMI (HVM), SSD Volume Type (64-bit x86)
  instance_type = "t2.micro"
}
