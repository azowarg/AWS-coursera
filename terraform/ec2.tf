provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_security_group" "app-sg" {
  name   = "app-sg"
  vpc_id = var.default_vpc

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "app-sg"
  }

}

resource "aws_key_pair" "ian" {
  key_name   = "ian"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC97VV031KOAlNXSEJquG+NF2ZcnUsI+fTEXXrQMiGApyh9Kb/IFJl7Ia5DC1JJLDqHQ4g4V7v4yuGwnlbeep/TMQDQ4NNeps+zf+kPpmDLnANJi0wLUEPLxvHMtuH9KQWNa1W9r4nQr2dw5Vqk2UvMSmZRM6WwZ1J6x30kVPaccCi31Ue4lJxJ61ZNYoZdt9qDzjZNEW8WDtFV2yE7jgYYtaPqkInGMSPfUtmAN0cvLuCAM66KkfrnuLFdvL3HVVZNMy1ER6zjJPgq46Gm1GGH16k3HRHl5P4I8thJsNU7OwU7EqoQt3ivtrdd/F08U4rRY5k29yxwJsFmRN5C7wQJBz/g+NYUek7OGNosZlTdP45dheFiBnVUByJEFmys+roIw0HcDtoX9dj68E68yTRxZIzexMSHporXUVVus5ijx/YDSRbnmL2vPyoftjxPV0zq9iLhbW4MXgOJDpM0QrNiahKiTdzyespXHu/Vm86XzLvbNtTb1ARfrtRC1a05+tM="
}

resource "aws_instance" "employee-directory-app" {
  count                       = 1
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ian.key_name
  associate_public_ip_address = true
  subnet_id                   = "subnet-02dee8d67d0436adb"
  vpc_security_group_ids      = [aws_security_group.app-sg.id]
  iam_instance_profile        = "S3DynamoDBFullAccessRole"
  tags = {
    "Name" = "employee-directory-app-${count.index}"
  }

  user_data_replace_on_change = true
  user_data = <<EOF
#!/bin/bash
wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/DEV-AWS-MO-GCNv2/FlaskApp.zip
unzip FlaskApp.zip
cd FlaskApp/
yum -y install python3 mysql
pip3 install -r requirements.txt
export PHOTOS_BUCKET="poka hernia"
amazon-linux-extras install epel
yum -y install stress
export AWS_DEFAULT_REGION=us-east-1
export DYNAMO_MODE=on
FLASK_APP=application.py /usr/local/bin/flask run --host=0.0.0.0 --port=80
EOF
}

output "ip_address" {
  value = aws_instance.employee-directory-app[*].public_ip 
}