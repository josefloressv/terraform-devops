# provider
variable "region" {
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
  default     = "10.0.0.0/16"
}

variable "vpc_enable_dns_support" {
  type        = bool
  description = "Define if tghe VPC will support DNS"
  default     = true
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  description = "Define if the VPC will suppor DNS by hostname"
  default     = true
}

variable "vpc_tags" {
  type        = map(any)
  description = "Provides the tags for the VPC of this lab"
}

#    Subnets
variable "sn01_cidr_block" {
  type        = string
  description = "The CIDR for the first subnet"
  default     = "10.0.1.0/24"
}

variable "sn01_default_public_ip" {
  type        = bool
  description = "Enable or disable create public IP for instances in the subnet sn01"
  default     = true
}

variable "sn01_availability_zone" {
  type        = string
  description = "Specifies the AZ when the sn01 will be created"
}

variable "sn01_tags" {
  type        = map(any)
  description = "Provides the tags for the subnet sn01"
}

#    Internet Gateway
variable "ig01_tags" {
  type        = map(any)
  description = "Provides the tags for the Internet Gateway"
}

variable "rt01_tags" {
  type        = map(any)
  description = "Provides the tag for the route table 01"
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
  type        = map(any)
  description = "Provides the tags for the Security Group"
}

# Instances
variable "default_instance_ami" {
  type        = string
  description = "Provides the AMI by default for each instance in this lab"
  validation {
    condition     = length(var.default_instance_ami) > 4 && substr(var.default_instance_ami, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

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

# Reference
# https://www.terraform.io/docs/language/values/variables.html
# https://learn.hashicorp.com/tutorials/terraform/expressions
# https://www.terraform.io/docs/language/expressions/type-constraints.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags
