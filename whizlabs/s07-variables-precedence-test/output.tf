output "web_tags" {
  value       = aws_instance.web[*].tags
  description = "Tags of the web instances"
}

output "web_availability_zone_0" {
  value       = aws_instance.web[0].availability_zone
  description = "Availability Zone of the first instance"
}

output "web_ip_address" {
  value       = aws_instance.web[*].public_ip
  description = "Public IP of the web instances"
}

output "web_public_dns" {
  value       = aws_instance.web[*].public_dns
  description = "Public DNS of the web instances"
}