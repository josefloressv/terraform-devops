variable "back_s3_bucket_name" {
  default = "goweb-terraform-backend"
}

variable "back_s3_acl" {
  default = "private"
}

variable "back_s3_tags" {
  default = { Environment = "Dev", CreatedBy = "Terraform" }
}