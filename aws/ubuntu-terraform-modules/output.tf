output "instance_ip" {
  value = aws_instance.ubuntu-instance-v3.*.public_ip
}