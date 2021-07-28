output "instance_ip" {
  value = aws_instance.server.public_ip
}

output "instance_az" {
  value = aws_instance.server.availability_zone
}

output "data_image_id" {
  value = data.aws_ami.amazon2.id
}

output "data_image_location" {
  value = data.aws_ami.amazon2.image_location
}

output "data_image_description" {
  value = data.aws_ami.amazon2.description
}
