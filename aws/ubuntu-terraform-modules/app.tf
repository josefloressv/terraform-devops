provider "aws" {
  region = "us-east-2"
}

module "app-goweb" {
  source = "./modules/instance"
  #enviando variables
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  tags          = var.tags
}