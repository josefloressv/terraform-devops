provider "aws" {
  region = "us-east-1" # Virginia
}

# Networking
resource "aws_vpc" "vpc01" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc01-tf"
  }
}

resource "aws_subnet" "sn01" {
  vpc_id                  = aws_vpc.vpc01.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "sn01-public-tf"
  }
}

resource "aws_internet_gateway" "ig01" {
  vpc_id = aws_vpc.vpc01.id
  tags = {
    Name = "ig-vpc01"
  }
}

resource "aws_route_table" "rt01" {
  vpc_id = aws_vpc.vpc01.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig01.id
  }
  tags = {
    Name = "rt01-wig-tf"
  }
}

resource "aws_route_table_association" "rta01" {
  subnet_id      = aws_subnet.sn01.id
  route_table_id = aws_route_table.rt01.id
}

# Security Group
resource "aws_security_group" "sg01" {
  vpc_id = aws_vpc.vpc01.id
  name   = "sg01-tf-vpc01"
  ingress {
    description = "Allow port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.sn01.cidr_block, "190.86.109.131/32"]
  }
  ingress {
    description = "Allow port HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "Allow ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_subnet.sn01.cidr_block, "190.86.109.131/32"]
  }
  egress {
    description = "Allow all for egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "sg01-tf-allow-ssh-http"
    Description = "Allow SSH & HTTP"
  }
}

# Instances

# custo interface with static IP
resource "aws_network_interface" "ni01" {
  subnet_id       = aws_subnet.sn01.id
  security_groups = [aws_security_group.sg01.id]
  private_ips     = ["10.0.1.4"]
  tags = {
    Name = "Primary Network Interface"
  }
}

# Intance with custom network interface
resource "aws_instance" "instance01" {
  ami           = "ami-0dc2d3e4c0f9ebd18"
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = aws_network_interface.ni01.id
    device_index         = 0
  }
  key_name = "myawskey"
  tags = {
    Name = "ec2-tf-server-01"
    OS   = "Amazon Linux 2 AMI x86"
  }
}

resource "aws_instance" "instance02" {
  ami                    = "ami-0dc2d3e4c0f9ebd18"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sn01.id
  vpc_security_group_ids = [aws_security_group.sg01.id]

  # this provocate always recreate
  #  vpc_security_group_ids = [aws_security_group.sg01.id]

  key_name = "myawskey"
  tags = {
    Name = "ec2-tf-server-02"
    OS   = "Amazon Linux 2 AMI x86"
  }
}

# Instance with default vpc and default security group
resource "aws_instance" "instance03" {
  ami           = "ami-0dc2d3e4c0f9ebd18"
  instance_type = "t2.micro"
  # InvalidGroup.NotFound: You have specified two resources that belong to different networks.
  #  vpc_security_group_ids = [aws_security_group.sg01.id]

  # no accesible via ssh
  key_name = "myawskey"
  tags = {
    Name = "ec2-tf-server-03"
    OS   = "Amazon Linux 2 AMI x86"
  }
}


output "instance_01_public_ip" {
  value       = aws_instance.instance01.public_ip
  description = "EC2 instance 01 Public IP"
}

output "instance_02_public_ip" {
  value       = aws_instance.instance02.public_ip
  description = "EC2 instance 02 Public IP"
}

output "instance_03_public_ip" {
  value       = aws_instance.instance03.public_ip
  description = "EC2 instance 03 Public IP"
}

# References
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance