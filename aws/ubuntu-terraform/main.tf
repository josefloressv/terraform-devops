provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "ubuntu-instance" {
  ami           = "ami-00399ec92321828f5"
  key_name      = "one-previous-ec2-key-pair"
  instance_type = "t2.micro"
  tags = {
    Name        = "ubuntu-terraform"
    Environment = "Dev"
  }
}