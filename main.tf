terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

##Create security group
resource "aws_security_group" "security_group1" {
  name          = "allow_tls"
  description   = "allow TCP and SSH inbounds"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##Launching instance
resource "aws_instance" "web" {
  ami             = "ubuntu"
  instance_type   = "t2.micro"
  security_groups = [ "allow_tls" ]
  user_data = <<-EOL
  #!/bin/bash -xe
  apt-get update
  apt-get install \
   ca-certificates \
   curl \
   gnupg \
   lsb-release
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt install docker.io
  
  IMAGE='${var.reponame}'
  PORT='${var.container_port}'
  docker run -d -p ${PORT}:80 ${IMAGE}
  EOL
  
  tags = {
    Name = "Web"
}
}
