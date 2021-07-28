# provider
variable "aws_region" {
  type        = string
  description = "Defines the region where the infrastructure will be deployed"
}

variable "provider_default_tags" {
  type        = map(any)
  description = "Provider default tags"
}

# Networking
variable "vpc_cidr_block" {
  type        = string
  description = "Define the CIDR for the VPC"
}

variable "vpc_name" {
  type        = string
  description = "Provides the Name for the VPC in the tag"
}

#    Subnets
variable "public_subnet_cidr_block" {
  type        = list(string)
  description = "Define the CIDR for the subnets"
}

variable "sn_name_prefix" {
  type        = string
  description = "Provides the prefix name for each subnet in the tag"
}

variable "public_azs" {
  type        = list(string)
  description = "Specifies the AZ when the sn01 will be created"
}

#    Internet Gateway
variable "igw_name" {
  type        = string
  description = "Provides the Name for the Internet Gateway in the tag"
}

variable "rt_name" {
  type        = string
  description = "Provides the name for the unique route table in the tag"
}

# Security Group
variable "sg01_name" {
  type        = string
  description = "Provides the name of the Security Group"
}

variable "sg01_ingress" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "Provides the inbound rules for the Security Group"
}

variable "sg01_tags" {
  type        = map(string)
  description = "Provides the tags for the Security Group"
}

# Instances
variable "default_instance_type" {
  type        = string
  description = "Provides the default size for each instance in this lab"
}

variable "default_instance_key_name" {
  type        = string
  description = "Provides the name of the key attached to the instances in this lab. The key must be created in this zone."
  sensitive   = true
}

variable "default_instance_os_tag" {
  type        = map(string)
  description = "OS Tag for instances of this lab"
  default     = {}
}

# Volumes

variable "ebs_size" {
  type        = number
  description = "Provides the default size for the volume in this lab, size in GB"
  default     = 10
}

# Load Balancer
variable "alb_name" {
  type        = string
  description = "Define the name of the LB"
}

variable "alb_tg_name" {
  type        = string
  description = "Define the name of the Target Group for the ALB"
}

# Reference
# https://www.terraform.io/docs/language/values/variables.html
# https://learn.hashicorp.com/tutorials/terraform/expressions
# https://www.terraform.io/docs/language/expressions/type-constraints.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags
