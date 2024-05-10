# Variables
variable "key_name" {}
variable "private_key_path" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider
provider "aws" {
  region = "eu-west-1"
}

# Resources
resource "aws_instance" "app_server_nginx_terraform" {
  ami                    = "ami-0607a9783dd204cae"
  instance_type          = "t2.micro"
  user_data              = file("userdata.tpl")
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.vpc_terraform.id]

  tags = {
    Name = "ServerNginx - Terraform"
  }
}

# Default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC - created via Terraform"
  }
}
# Security Groups
resource "aws_security_group" "vpc_terraform" {
  name        = "vpc_terraform"
  description = "VPC created with Terraform"
  vpc_id      = aws_default_vpc.default.id

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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output
output "aws_instance_public_dns" {
  value = aws_instance.app_server_nginx_terraform.public_dns
}
