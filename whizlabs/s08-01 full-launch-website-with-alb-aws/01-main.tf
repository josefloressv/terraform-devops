provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.provider_default_tags
  }
}

locals {
  amazon_ami_by_regions = {
    "us-east-1" = "ami-0dc2d3e4c0f9ebd18", # N. Virginia
    "us-east-2" = "ami-0233c2d874b811deb", # Ohio
    "us-west-1" = "ami-0ed05376b59b90e46", # N. California
    "us-west-2" = "ami-0dc8f589abe99f538", # Oregon
  }
}

# Networking
# ----------------------------
resource "aws_vpc" "vpc01" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

#   Subnet: public subnets
resource "aws_subnet" "sn" {
  count                   = length(var.public_subnet_cidr_block)
  vpc_id                  = aws_vpc.vpc01.id
  cidr_block              = var.public_subnet_cidr_block[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.public_azs[count.index]
  tags = {
    Name = format("%s%s", var.sn_name_prefix, count.index)
  }
}

#   Gateway
resource "aws_internet_gateway" "ig01" {
  vpc_id = aws_vpc.vpc01.id
  tags = {
    Name = var.igw_name
  }
}

#   Routing table
resource "aws_route_table" "rt01" {
  vpc_id = aws_vpc.vpc01.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig01.id
  }
  tags = {
    Name = var.rt_name
  }
}

resource "aws_route_table_association" "rta01" {
  count          = length(var.public_subnet_cidr_block)
  subnet_id      = aws_subnet.sn[count.index].id
  route_table_id = aws_route_table.rt01.id
}

#   Security Group
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
# ----------------------------
resource "aws_ebs_volume" "vol" {
  count             = length(var.public_azs)
  availability_zone = var.public_azs[count.index]
  size              = var.ebs_size
  tags = {
    Name = format("%s%s", "vol-tf-", count.index)
  }
}

resource "aws_instance" "web" {
  count                  = length(var.public_subnet_cidr_block)
  instance_type          = var.default_instance_type
  subnet_id              = aws_subnet.sn[count.index].id
  ami                    = local.amazon_ami_by_regions[var.aws_region]
  vpc_security_group_ids = [aws_security_group.sg01.id]
  key_name               = var.default_instance_key_name
  user_data              = templatefile("user_data.tftpl", { server_number = count.index + 1 })
  tags = merge(
    var.default_instance_os_tag,
    {
      Name = "ec2-tf-web-${count.index + 1}"
  })
}

resource "aws_volume_attachment" "ebs_att" {
  count       = length(aws_ebs_volume.vol[*].id)
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.vol[count.index].id
  instance_id = aws_instance.web[count.index].id
}

# Load Balancer
# ----------------------------
# Create a new load balancer
resource "aws_lb" "alb01" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg01.id]
  subnets            = aws_subnet.sn.*.id
  tags = {
    Name = var.alb_name
  }
}

resource "aws_lb_target_group" "tg01" {
  name     = var.alb_tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc01.id
}

resource "aws_lb_target_group_attachment" "tga01" {
  count            = length(aws_instance.web[*].id)
  target_group_arn = aws_lb_target_group.tg01.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb01.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg01.arn
  }
}

# References
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener

# https://www.terraform.io/docs/language/functions/templatefile.html
# https://www.terraform.io/docs/language/resources/provisioners/syntax.html