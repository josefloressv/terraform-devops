#!/bin/bash
# Docs https://www.terraform.io/docs/language/values/variables.html#variable-definition-precedence

# 01 default values
terraform plan

# 02 inline vars and inline file vars
#   inline vars error
terraform plan -var "ec2_num_instances=2" -var "ec2_az=1"

#   inline vars ok
terraform plan -var "ec2_num_instances=2" -var "ec2_az=b"
terraform destroy

#   inline file vars error
terraform plan -var-file=t02-error.tfvars

#   inline file vars ok
terraform plan -var-file=t02-ok.tfvars
# terraform import -var-file=t02-ok.tfvars aws_instance.web i-093db7a6297d09869
# terraform destroy -var-file=t02-ok.tfvars

#   Combined inline vars and inline file vars
#       error
terraform apply -var "ec2_num_instances=2" -var "ec2_az=b" -var-file=t02-error.tfvars
#       ok
terraform apply -var "ec2_num_instances=2" -var "ec2_az=2" -var-file=t02-ok.tfvars
terraform destroy -var "ec2_num_instances=2" -var "ec2_az=2" -var-file=t02-ok.tfvars

# 03 Auto-generated vars
#   Auto-generated vars error, renamme t03-error.tfvars->t03-error.auto.tfvars
terraform plan
#   Change t03-error.auto.tfvars->t03-error.tfvars
#   Auto-generated vars OK, renamme t03-ok.tfvars->t03-ok.auto.tfvars
terraform plan

# 04 terraform.tfvars file
#   renamme t03-ok.tfvars->t03-ok.auto.tfvars
#   get OK by precedence of auto. Renamme terraform-error.tfvars->terraform.tfvars
terraform plan
#   get Error. Renamme t03-ok.auto.tfvars->t03-ok.tfvars

#   renamme terraform.tfvars->terraform-error.tfvars
#   get Ok renamme terraform-ok.tfvars->terraform.tfvars
terraform plan

# 05 with environment variables
#   get OK by precedence of terraform.tfvars
export TF_VAR_ec2_az="otra"
env | grep TF_VAR

terraform plan

#   get Error by env var. Renamme terraform.tfvars->terraform-ok.tfvars
terraform plan
#Note: the plan does not generate error, but when you apply it, it does
terraform apply

# correct the value and add a new variable
# deployment the infrastructure with one instance, OK
export TF_VAR_ec2_az="c"
export TF_VAR_ec2_num_instances=1

terraform apply

#cleaning the environment
terraform destroy

unset TF_VAR_ec2_az
unset TF_VAR_ec2_num_instances
env | grep TF_VAR

# 06 Combining precedences
#    a. export these variables
export TF_VAR_ec2_az="c"
export TF_VAR_ec2_num_instances=1
export TF_VAR_ec2_tags='{Environment:"env01", OperatingSystem: "Amazon Linux x01"}'

#   b. rename terraform-06.tfvars->terraform.tfvars

#   check the precedence
terraform plan  #b is the winner (teraform.tfvars)

#   c. rename t06.tfvars->t06.auto.tfvars

#   check the precedence
terraform plan  #c is the winner (.auto.tfvars)

#   d. use -var inline
#   check the precedence, d is the winner (-var inline)
terraform plan -var "ec2_az=c" -var "ec2_num_instances=4" -var ec2_tags='{Environment:"env04", OperatingSystem: "Amazon Linux x04"}' 

#   e. use -var-file inline
#   check the precedence, e is the winner (-var-file inline)
terraform plan -var "ec2_az=c" -var "ec2_num_instances=4" -var ec2_tags='{Environment:"env04", OperatingSystem: "Amazon Linux x04"}'  -var-file=t0601.tfvars 
