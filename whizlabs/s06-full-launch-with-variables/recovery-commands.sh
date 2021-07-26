#!/bin/bash
#recovery ohio
terraform import  aws_vpc.vpc01 vpc-0bfbb0fa5e63ba242
terraform import  aws_subnet.sn01 subnet-0e1215b8bce1ec0fa
terraform import  aws_internet_gateway.ig01 igw-0e21e43dc9d5739b7
terraform import  aws_route_table.rt01 rtb-0878f9004cba42135
terraform import  aws_security_group.sg01 sg-0175cd9bfc12043e7
terraform import  aws_network_interface.ni01 eni-0527322a32aa62da1
terraform import  aws_route_table_association.rta01 
terraform import aws_instance.instance01 i-01d8d1115996ecbf3
terraform import aws_instance.instance02 i-0b7ebdd46c7aafa4a
terraform import aws_instance.instance03 i-03669653696611fc5

# recovery virginia
terraform import  aws_vpc.vpc01 vpc-055ef627cb2e49ab8
terraform import  aws_subnet.sn01 subnet-0bc1d457da6711f46
terraform import  aws_internet_gateway.ig01 igw-05c431bc8caccf4ba
terraform import  aws_route_table.rt01 rtb-0d7943e905af7fca6
terraform import  aws_security_group.sg01 sg-04a72d3ef0ae2bfe0
terraform import  aws_network_interface.ni01 eni-0f6ec6e05786ba0eb
terraform import aws_instance.instance01 i-00ca1cae830036bdc
terraform import aws_instance.instance02 i-02b605545aeffff89
terraform import aws_instance.instance03 i-0d0ebbfd32d0bcc93
