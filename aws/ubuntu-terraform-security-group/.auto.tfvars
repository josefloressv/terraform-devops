ami_id        = "ami-00399ec92321828f5"
instance_type = "t2.micro"
key_name      = "ec2-platzi"
tags          = { Name = "ubuntu-terraform", Environment = "Prod"}
sg_name       = "goweb-terraform-test"
sg_description = "SG Description"
sg_tags          = { Name = "SG Terraform"}
sg_ingres_values = [
    {
    description      = "WWW from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    },{
    description      = "TLS from Internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    },{
    description      = "JF SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["190.86.33.124/32"]
    }   
]