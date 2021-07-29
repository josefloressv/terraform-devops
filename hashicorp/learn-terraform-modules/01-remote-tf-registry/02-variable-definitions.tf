# General
variable "aws_region" {
  type = string
}

variable "default_tags" {
  type = map(string)
}

#VPC
variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_azs" {
  type = list(string)
}

variable "vpc_private_subnets" {
  type = list(string)
}

variable "vpc_public_subnets" {
  type = list(string)
}

variable "vpc_enable_nat_gateway" {
  type = bool
}

variable "vpc_enable_vpn_gateway" {
  type = bool
}

# Instance
variable "ec2_name" {
  type = string
}

variable "ec2_instance_count" {
  type = number
}

variable "ec2_key_name" {
  type = string
}
