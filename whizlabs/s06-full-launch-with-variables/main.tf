provider "aws" {
  region = var.region
  default_tags {
    tags = var.provider_default_tags
  }
}

# Networking
resource "aws_vpc" "vpc01" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.vpc_enable_dns_support
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  tags                 = var.vpc_tags
}

resource "aws_subnet" "sn01" {
  vpc_id                  = aws_vpc.vpc01.id
  cidr_block              = var.sn01_cidr_block
  map_public_ip_on_launch = var.sn01_default_public_ip
  availability_zone       = var.sn01_availability_zone
  tags                    = var.sn01_tags
}

resource "aws_internet_gateway" "ig01" {
  vpc_id = aws_vpc.vpc01.id
  tags   = var.ig01_tags
}

resource "aws_route_table" "rt01" {
  vpc_id = aws_vpc.vpc01.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig01.id
  }
  tags = var.rt01_tags
}

resource "aws_route_table_association" "rta01" {
  subnet_id      = aws_subnet.sn01.id
  route_table_id = aws_route_table.rt01.id
}

# Security Group
resource "aws_security_group" "sg01" {
  vpc_id = aws_vpc.vpc01.id
  name   = var.sg01_name

  dynamic "ingress" {
    for_each = var.sg01_ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  egress {
    description = "Allow all for egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.sg01_tags
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
  ami           = var.default_instance_ami
  instance_type = var.default_instance_type
  network_interface {
    network_interface_id = aws_network_interface.ni01.id
    device_index         = 0
  }
  key_name = var.default_instance_key_name
  tags = merge(
    var.default_instance_os_tag,
    {
      Name = "ec2-tf-server-01"
  })
}

resource "aws_instance" "instance02" {
  ami                    = var.default_instance_ami
  instance_type          = var.default_instance_type
  subnet_id              = aws_subnet.sn01.id
  vpc_security_group_ids = [aws_security_group.sg01.id]
  key_name               = var.default_instance_key_name
  tags = merge(
    var.default_instance_os_tag,
    {
      Name = "ec2-tf-server-02"
  })
}

# Instance with default vpc and default security group
# no accesible via ssh
resource "aws_instance" "instance03" {
  ami           = var.default_instance_ami
  instance_type = var.default_instance_type
  key_name      = var.default_instance_key_name
  tags = merge(
    var.default_instance_os_tag,
    {
      Name = "ec2-tf-server-03"
  })
}


# Outputs
output "instance_01_public_ip" {
  value       = aws_instance.instance01.public_ip
  description = "EC2 instance 01 Public IP"
}
output "instance_01_tags" {
  value = aws_instance.instance01.tags
}


output "instance_02_public_ip" {
  value       = aws_instance.instance02.public_ip
  description = "EC2 instance 02 Public IP"
}

output "instance_03_public_ip" {
  value       = aws_instance.instance03.public_ip
  description = "EC2 instance 03 Public IP"
}