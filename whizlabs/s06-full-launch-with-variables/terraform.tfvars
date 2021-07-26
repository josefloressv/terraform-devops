# provider
region = "us-east-1" # US East (Virginia)
provider_default_tags = {
  Environment = "staging"
}
# Networking
vpc_tags = {
  Name = "vpc01-tf"

}

#    Subnets
sn01_availability_zone = "us-east-1b"
sn01_tags = {
  Name = "sn01-public-tf"
}

#    Internet Gateway
ig01_tags = {
  Name = "ig-vpc01"
}

#     Routing Table   
rt01_tags = {
  Name = "rt01-wig-tf"
}

#     Security Group
sg01_name = "sg01-tf-vpc01"
sg01_ingress = [{
  description = "Allow port 22"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["10.0.1.0/24", "190.86.109.131/32"]
  }, {
  description = "Allow port HTTP"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  }, {
  description = "Allow ICMP"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = ["10.0.1.0/24", "190.86.109.131/32"]
}]

sg01_tags = {
  Name = "sg01-tf-allow-ssh-http"
  Info = "Allow SSH & HTTP"
}

# Instances
/*
AMI change by Regions
ami-0dc2d3e4c0f9ebd18 Virginia Amazon
ami-0233c2d874b811deb Ohio Amazon
*/
default_instance_ami      = "ami-0dc2d3e4c0f9ebd18"
default_instance_type     = "t2.micro"
default_instance_key_name = "myawskey"
default_instance_os_tag = {
  OperatingSystem = "Amazon Linux 2 AMI x86"
}