provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "vm" {
  ami = "ami-0aeeebd8d2ab47354"
  subnet_id = "subnet-0baa583d0d00f49f1"
  instance_type = "t3.micro"
  tags = {
      Name = "my-first-tf-vm-ag"
  }
}
