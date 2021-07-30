provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "foo" {
  ami             = "ami-0dc2d3e4c0f9ebd18" # Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  key_name        = "myawskey"          # already exists
  security_groups = ["MySSHConnection"] #sg-myssh already exists

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/myawskey-virginia.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "touch whizlabs.txt",
      "echo 'hello world' > whizlabs.txt"
    ]
  }

  provisioner "file" {
    source      = "assets/hello.txt"
    destination = "hello.txt"
  }

  provisioner "file" {
    content     = "ami used ${self.ami}"
    destination = "ami.txt"
  }

  provisioner "local-exec" {
    command = "echo 'Instance IP: ${self.public_ip}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Destroy-time provisioner'"
  }


}

output "instance_ip" {
  value = aws_instance.foo.public_ip
}