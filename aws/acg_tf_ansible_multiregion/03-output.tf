output "jenkins_master_node" {
  value = aws_instance.jenkins-master.public_ip
}

output "jenkins_worker_nodes" {
  value = aws_instance.jenkins-worker-oregon[*].public_ip
}

output "LB-DNS-NAME" {
  value = aws_lb.application-lb.dns_name
}

output "Jenkins-Main-Node-Public-IP" {
  value = aws_instance.jenkins-master.public_ip
}

output "Jenkins-Main-Node-Private-IP" {
  value = aws_instance.jenkins-master.private_ip
}

output "Jenkins-Worker-Public-IPs" {
  value = {
    for instance in aws_instance.jenkins-worker-oregon :
    instance.id => instance.public_ip
  }
}

output "Jenkins-Worker-Private-IPs" {
  value = {
    for instance in aws_instance.jenkins-worker-oregon :
    instance.id => instance.private_ip
  }
}

output "url" {
  value = aws_route53_record.jenkins.fqdn
}