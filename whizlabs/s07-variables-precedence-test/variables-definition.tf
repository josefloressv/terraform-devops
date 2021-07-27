variable "region" {
  type        = string
  description = "Default region"
  default     = "us-east-1"
  # take care, before to change region I need to destroy the infrastructure first
}

variable "ec2_num_instances" {
  type        = number
  description = "Num of instances to create"
  default     = 2
}

variable "ec2_az" {
  type        = string
  description = "Availability zone for the instance"
  default     = "b"
  validation {
    condition     = can(regex("[abcd]", var.ec2_az))
    error_message = "The value must be a, b, c or d."
  }
}

variable "ec2_instance_type" {
  type        = string
  description = "Instance type"
  default     = "t2.micro"
}

variable "ec2_tags" {
  type        = map(string)
  description = "Tags for the instance"
  default = {
    Environment     = "testing"
    OperatingSystem = "Amazon Linux x86"
  }
}
