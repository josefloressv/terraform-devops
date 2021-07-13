provider "aws" {
  region = "us-east-2"
}
resource "aws_security_group" "sgrules-instance" {
  name        = var.sg_name
  description = var.sg_description

  dynamic "ingress" {
    for_each = var.sg_ingres_values
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.sg_tags
}

resource "aws_instance" "ubuntu-instance-v3" {
  ami             = var.ami_id
  key_name        = var.key_name
  instance_type   = var.instance_type
  tags            = var.tags
  security_groups = [aws_security_group.sgrules-instance.name]
}