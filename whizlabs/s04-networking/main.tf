provider "aws" {
  region = "us-west-2" # Oregon
}

resource "aws_vpc" "vpc01" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-tf-01"
  }
}

# Subnets
resource "aws_subnet" "sn-public-01" {
  vpc_id                  = aws_vpc.vpc01.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "sn-public-01"
  }
}

resource "aws_subnet" "sn-public-02" {
  vpc_id                  = aws_vpc.vpc01.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"
  tags = {
    Name = "sn-public-02"
  }
}

resource "aws_subnet" "sn-private-01" {
  vpc_id            = aws_vpc.vpc01.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "sn-private-01"
  }
}

resource "aws_subnet" "sn-private-02" {
  vpc_id            = aws_vpc.vpc01.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "sn-private-02"
  }
}

# Interneet Gateway
resource "aws_internet_gateway" "igw01" {
  vpc_id = aws_vpc.vpc01.id
  tags = {
    Name = "igw-tf-01"
  }
}


# Routes & Associated Routes
resource "aws_route_table" "rt01" {
  vpc_id = aws_vpc.vpc01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw01.id
  }

  tags = {
    Name = "rt-tf-01"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sn-public-01.id
  route_table_id = aws_route_table.rt01.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sn-public-02.id
  route_table_id = aws_route_table.rt01.id
}

# Security Groups
resource "aws_security_group" "sg01" {
  name        = "sgtf-01"
  description = "SG for Terraform"
  vpc_id      = aws_vpc.vpc01.id
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow traffic from TCP/80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow Internal ICMP"
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sg-tf-01"
  }
}

#References
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
