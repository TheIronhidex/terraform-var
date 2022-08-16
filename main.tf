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

  output "op_sg" {
    value = aws_security_group.security_group1
  }

##Launching instance
resource "aws_instance" "web" {
  ami             = "ubuntu"
  instance_type   = "t2.micro"
  security_groups = [ "allow_tls" ]
  user_data       = file("init-script.sh")
}

output "op_inst_az" {
  value = aws_instance.web.availability_zone
}

