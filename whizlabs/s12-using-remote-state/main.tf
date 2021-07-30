terraform {
  backend "s3" {
    bucket = "whizlabs-tf-2021"
    key    = "team-02/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "ec2" {
  backend = "s3"

  config = {
    bucket = "whizlabs-tf-2021"
    key    = "team-01/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_ebs_volume" "vol" {
  availability_zone = "us-east-1d"
  size              = 1
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.vol.id
  instance_id = data.terraform_remote_state.ec2.outputs.instance_id
}
