provider "aws" {
  # US East (N. Virginia) Region
  region = "us-east-1"
}

resource "aws_instance" "myinstance02" {
  ami           = "ami-0dc2d3e4c0f9ebd18"
  instance_type = "t2.micro"
  tags = {
    Name = "Whizlabs-instance-tf"
  }
}

resource "aws_eip" "myelasticip" {
  instance = aws_instance.myinstance02.id
  vpc      = true
  tags = {
    Name = "Whizlabs-EIP-tf"
  }
}

# OUTPUTS
output "instance_ip_address" {
  value       = aws_instance.myinstance02.public_ip
  description = "Instance IP Address"
}

output "eip_ip_address" {
  value       = aws_eip.myelasticip.public_ip
  description = "Elastic IP Address"
}
