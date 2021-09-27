variable "region-master" {
  type        = string
  description = "The region master"
  default     = "us-east-1"
}

variable "region-worker" {
  type        = string
  description = "The region where the workers are located"
  default     = "us-west-2"
}

variable "external_ip" {
  type        = string
  description = "External IP"
  default     = "0.0.0.0/0"
}

variable "instance-type" {
  type        = string
  description = "Instance type"
  default     = "t3.micro"
}

variable "workers-count" {
  type        = number
  description = "Number of workers"
  default     = 1
}

variable "aws_cli_profile" {
  type        = string
  description = "The name of the profile to use"
  default     = "acg"
}

variable "webserver-port" {
  type    = number
  default = 80
}

variable "dns-name" {
  type        = string
  description = "The DNS name of the master"
  default     = "awslab.tech."
}