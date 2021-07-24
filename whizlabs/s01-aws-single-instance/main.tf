provider "aws" {
  # last version

  # AWS credentials profile stored in ~./aws/credentials
  profile = "default"

  # US East N. Virginia
  region = "us-east-1"
}

resource "aws_instance" "whizlabs_ec2_demo" {
  count         = 2
  ami           = "ami-0dc2d3e4c0f9ebd18" # Amazon Linux 2 AMI (HVM), SSD Volume Type (64-bit x86)
  instance_type = "t2.micro"
  tags = {
    Name = "Whizlabs-instance-${count.index}"
  }
}