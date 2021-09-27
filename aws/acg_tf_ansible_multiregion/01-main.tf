terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = ">=3.0.0"
  }
  backend "s3" {
    region  = "us-east-1"
    profile = "default"
    key     = "terraformstatefile"
    bucket  = "acgtfstate"
  }
}

provider "aws" {
  region = var.region-master
  alias  = "region-master"
}

provider "aws" {
  region = var.region-worker
  alias  = "region-worker"
}

#Create VPC in us-east-1
resource "aws_vpc" "vpc_master" {
  provider             = aws.region-master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "master-vpc-jenkins"
  }

}

#Create VPC in us-west-2
resource "aws_vpc" "vpc_master_oregon" {
  provider             = aws.region-worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "worker-vpc-jenkins"
  }

}

#Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
}

#Create IGW in us-west-2
resource "aws_internet_gateway" "igw-oregon" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_master_oregon.id
}

#Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}


#Create subnet # 1 in us-east-1
resource "aws_subnet" "subnet_1" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"
}


#Create subnet #2  in us-east-1
resource "aws_subnet" "subnet_2" {
  provider          = aws.region-master
  vpc_id            = aws_vpc.vpc_master.id
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  cidr_block        = "10.0.2.0/24"
}


#Create subnet in us-west-2
resource "aws_subnet" "subnet_1_oregon" {
  provider   = aws.region-worker
  vpc_id     = aws_vpc.vpc_master_oregon.id
  cidr_block = "192.168.1.0/24"
}

## VPC Peering

#Initiate Peering connection request from us-east-1
resource "aws_vpc_peering_connection" "useast1-uswest2" {
  provider    = aws.region-master
  peer_vpc_id = aws_vpc.vpc_master_oregon.id
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = "us-west-2"

}

#Accept VPC peering request in us-west-2 from us-east-1
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  auto_accept               = true
}

#Create route table in us-east-1
resource "aws_route_table" "internet_route" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Master-Region-RT"
  }
}

#Overwrite default route table of VPC(Master) with our route table entries
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id
}

#Create route table in us-west-2
resource "aws_route_table" "internet_route_oregon" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_master_oregon.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-oregon.id
  }
  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Worker-Region-RT"
  }
}

#Overwrite default route table of VPC(Worker) with our route table entries
resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  provider       = aws.region-worker
  vpc_id         = aws_vpc.vpc_master_oregon.id
  route_table_id = aws_route_table.internet_route_oregon.id
}

## Deploying Secuity Groups
#Create SG for LB, only TCP/80,TCP/443 and outbound access
resource "aws_security_group" "lb-sg" {
  provider    = aws.region-master
  name        = "lb-sg"
  description = "Allow 443 and traffic to Jenkins SG"
  vpc_id      = aws_vpc.vpc_master.id
  ingress {
    description = "Allow 443 from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 80 from anywhere for redirection"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create SG for allowing TCP/8080 from * and TCP/22 from your IP in us-east-1
resource "aws_security_group" "jenkins-sg" {
  provider    = aws.region-master
  name        = "jenkins-sg"
  description = "Allow TCP/8080 & TCP/22"
  vpc_id      = aws_vpc.vpc_master.id
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "allow anyone on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description     = "allow anyone on port 8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb-sg.id]
  }
  ingress {
    description = "allow traffic from us-west-2"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.1.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



#Create SG for allowing TCP/22 from your IP in us-west-2
resource "aws_security_group" "jenkins-sg-oregon" {
  provider = aws.region-worker

  name        = "jenkins-sg-oregon"
  description = "Allow TCP/8080 & TCP/22"
  vpc_id      = aws_vpc.vpc_master_oregon.id
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow traffic from us-east-1"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.1.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Fetch AMI IDs
#Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region-master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Get Linux AMI ID using SSM Parameter endpoint in us-west-2
data "aws_ssm_parameter" "linuxAmiOregon" {
  provider = aws.region-worker
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


## Deploying Key Pairs for Apps Nodes
#Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "master-key" {
  provider   = aws.region-master
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

#Create key-pair for logging into EC2 in us-west-2
resource "aws_key_pair" "worker-key" {
  provider   = aws.region-worker
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}


## Deploying Jenkins Master and Worker Instances
#Create and bootstrap EC2 in us-east-1
resource "aws_instance" "jenkins-master" {
  provider                    = aws.region-master
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id

  tags = {
    Name = "jenkins_master_tf"
  }

  depends_on = [aws_main_route_table_association.set-master-default-rt-assoc]
  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.aws_cli_profile} ec2 wait instance-status-ok --region ${var.region-master} --instance-ids ${self.id}
ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/jenkins-master-sample.yaml
EOF
  }
}

#Create EC2 in us-west-2
resource "aws_instance" "jenkins-worker-oregon" {
  provider                    = aws.region-worker
  count                       = var.workers-count
  ami                         = data.aws_ssm_parameter.linuxAmiOregon.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.worker-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg-oregon.id]
  subnet_id                   = aws_subnet.subnet_1_oregon.id

  tags = {
    Name = join("_", ["jenkins_worker_tf", count.index + 1])
  }
  depends_on = [aws_main_route_table_association.set-worker-default-rt-assoc, aws_instance.jenkins-master]
  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.aws_cli_profile} ec2 wait instance-status-ok --region ${var.region-worker} --instance-ids ${self.id}
ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/jenkins-worker-sample.yaml
EOF
  }
}


## ALB
resource "aws_lb" "application-lb" {
  provider           = aws.region-master
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  tags = {
    Name = "Jenkins-LB"
  }
}


#Create variable named webserver-port , type number , default 80
#Change port to variable in jenkins-sg group ingress rule which allows traffic from LB SG.

resource "aws_lb_target_group" "app-lb-tg" {
  provider    = aws.region-master
  name        = "app-lb-tg"
  port        = var.webserver-port
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_master.id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/"
    port     = var.webserver-port
    protocol = "HTTP"
    matcher  = "200-299"
  }
  tags = {
    Name = "jenkins-target-group"
  }
}

resource "aws_lb_listener" "jenkins-listener-http" {
  provider          = aws.region-master
  load_balancer_arn = aws_lb.application-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    #    type             = "forward"
    #    target_group_arn = aws_lb_target_group.app-lb-tg.id
    #    after config HTTPS with ACM and Route 53
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_target_group_attachment" "jenkins-master-attach" {
  provider         = aws.region-master
  target_group_arn = aws_lb_target_group.app-lb-tg.arn
  target_id        = aws_instance.jenkins-master.id
  port             = var.webserver-port
}


## DNS Configuration
#Get already , publicly configured Hosted Zone on Route53 - MUST EXIST
data "aws_route53_zone" "dns" {
  provider = aws.region-master
  name     = var.dns-name
}

## ACM CONFIGURATION
#Creates ACM certificate and requests validation via DNS(Route53)
resource "aws_acm_certificate" "jenkins-lb-https" {
  provider          = aws.region-master
  domain_name       = join(".", ["jenkins", data.aws_route53_zone.dns.name])
  validation_method = "DNS"
  tags = {
    Name = "Jenkins-ACM"
  }
}

#Validates ACM issued certificate via Route53
resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.region-master
  certificate_arn         = aws_acm_certificate.jenkins-lb-https.arn
  for_each                = aws_route53_record.cert_validation
  validation_record_fqdns = [aws_route53_record.cert_validation[each.key].fqdn]
}

####ACM CONFIG END

resource "aws_lb_listener" "jenkins-listener-https" {
  provider          = aws.region-master
  load_balancer_arn = aws_lb.application-lb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.jenkins-lb-https.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.arn
  }

  depends_on = [aws_acm_certificate_validation.cert]
}

#Create record in hosted zone for ACM Certificate Domain verification
resource "aws_route53_record" "cert_validation" {
  provider = aws.region-master
  for_each = {
    for val in aws_acm_certificate.jenkins-lb-https.domain_validation_options : val.domain_name => {
      name   = val.resource_record_name
      record = val.resource_record_value
      type   = val.resource_record_type
    }
  }
  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.dns.zone_id
}

#Create Alias record towards ALB from Route53
resource "aws_route53_record" "jenkins" {
  provider = aws.region-master
  zone_id  = data.aws_route53_zone.dns.zone_id
  name     = join(".", ["jenkins", data.aws_route53_zone.dns.name])
  type     = "A"
  alias {
    name    = aws_lb.application-lb.dns_name
    zone_id = aws_lb.application-lb.zone_id
    evaluate_target_health = true
  }
}
