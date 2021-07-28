# Dependent variables
# ----------------------------
aws_region                = "us-east-1" # US East (Virginia)
vpc_cidr_block            = "10.0.0.0/16"
public_azs                = ["us-east-1b", "us-east-1c"]
public_subnet_cidr_block  = ["10.0.1.0/24", "10.0.2.0/24"]
default_instance_key_name = "myawskey"

# Global
# ----------------------------
provider_default_tags = {
  Environment = "staging"
}

# Networking
# ----------------------------
vpc_name = "vpc01-tf"

#    Subnets

sn_name_prefix = "sn-public-tf-"

#    Internet Gateway
igw_name = "ig-vpc01"

#     Routing Table   
rt_name = "rt01-wig-tf"

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
# ----------------------------
default_instance_type = "t2.micro"
default_instance_os_tag = {
  OperatingSystem = "Amazon Linux 2 AMI x86"
}

# Load Balancer
# ----------------------------
alb_name    = "alb-tf-01-wwww"
alb_tg_name = "albtg-webs"

