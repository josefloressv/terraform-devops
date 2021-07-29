# Output variable definitions

output "vpc_public_subnets" {
  description = "IDs of the VPC's public subnets"
  value       = module.vpc.public_subnets
}

output "ec2_cluster_public_ips" {
  description = "Public IP addresses of EC2 instances"
  value       = module.ec2_cluster.public_ip
}


output "vpc_todo" {
  value = module.vpc.*
}

output "sg_todo" {
  value = module.sg.*
}

output "ec2_todo" {
  value = module.ec2_cluster.*
}
