#!/bin/bash
# create key pair, to access aws
aws ec2 create-key-pair --key-name djs-key --key-type rsa --query 'KeyMaterial' --output text > ~/.ssh/djs-key.pem

aws ec2 create-security-group --group-name djs-sec-group --description "EC2-Webserver-DJS"
aws ec2 authorize-security-group-ingress --group-name djs-sec-group --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name djs-sec-group --protocol tcp --port 22 --cidr 0.0.0.0/0

(
    cd ~/ec2webserver
    aws ec2 run-instances --image-id ami-08c40ec9ead489470 --count 1 --instance-type t2.micro --key-name djs-key --security-groups djs-sec-group --iam-instance-profile Name=LabInstanceProfile --user-data file://initial.txt --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Webserver}]'
)

aws ec2 describe-instances --query "Reservations[*].Instances[*].PublicIpAddress" --output text

