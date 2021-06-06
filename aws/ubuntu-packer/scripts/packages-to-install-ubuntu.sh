#!/bin/bash

# Wait for cloud-init to finish
# thanks https://dev.to/hsatac/building-a-ubuntu-virtualbox-image-on-aws-ec2-with-packer-m00
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done

# installing example package
apt update
apt install -y ansible 2>/dev/null
