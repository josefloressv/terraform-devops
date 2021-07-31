# Multi-region provider

# default_region = 'us-east-1'
provider "aws" {
  region = "us-east-1"
}

# second_region = 'us-west-2'
provider "aws" {
  alias  = "ohio"
  region = "us-east-2"
}

# using default region
resource "aws_instance" "webapp1" {
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  tags = {
    Name = "Virginia-instance"
  }
}

# using the second region with alias
resource "aws_instance" "webapp2" {
  provider      = aws.ohio
  ami           = "ami-0443305dabd4be2bc"
  instance_type = "t2.micro"
  tags = {
    Name = "Ohio-instance"
  }
}

# Outputs
output "webapp_virginia" {
  value = aws_instance.webapp1.availability_zone
}

output "webapp_ohio" {
  value = aws_instance.webapp2.availability_zone
}