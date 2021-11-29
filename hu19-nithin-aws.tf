provider "aws" {
  region  = "ap-south-1"
}

# terraform {
#   required_version = ">= 0.13"
#   required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "~> 3.0"
#    }
#  }
# }
# resource "aws_network_interface" "test" {
#   subnet_id       = aws_subnet.public_a.id
#   private_ips     = ["10.0.0.50"]
#   security_groups = [aws_security_group.web.id]

#   attachment {
#     instance     = aws_instance.test.id
#     device_index = 1
#   }
# }
# resource "aws_network_interface" "test" {
#   network_interface_id = aws_network_interface.test.id
#   device_index         = 0
# }
resource "aws_security_group" "security_group" {
  name        = "security_group"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-0fc248fc45ee4cfab"

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["10.1.212.0/23"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["10.1.212.0/23"]
  }

  tags = {
    Name = "security_group"
  }
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.1.212.0/22"
  tags = {
    Name = "MY_VPC"
  }
}
resource "aws_subnet" "hu19-nithin-terraform-public-subnet" {
  vpc_id           = "vpc-0fc248fc45ee4cfab"
  cidr_block = "10.1.212.0/23"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"
  
  tags = { 
    Name = "hu19-nithin-terraform-public-subnet"
  }
}
resource "aws_subnet" "hu19-nithin-terraform-private-subnet" {
    vpc_id           = "vpc-0fc248fc45ee4cfab"
    cidr_block = "10.1.214.0/23"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = "true"
    
    tags = { 
      Name = "hu19-nithin-terraform-private-subnet"
    }
  }

  resource "aws_instance" "wordpress" {
  ami           = "ami-0108d6a82a783b352"
  instance_type = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data = file("script.sh")
  key_name = "linux-key-1"
  tags = {
    Name = "nithin-wordpress"
  }
}

# resource "aws_db_instance" "default" {
#   identifier           = "sample"
#   allocated_storage    = 10
#   storage_type         = "gp2"
#   engine               = "mydb"
#   engine_version       = "5.7"
#   instance_class       = "db.t2.micro"
#   name                 = "mydb"
#   username             = "root"
#   password             = "redhat123"
#   publicly_accessible  = true
#   parameter_group_name = "default.mysql5.7"
#   skip_final_snapshot  = true
# } 