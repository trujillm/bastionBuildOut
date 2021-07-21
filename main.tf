terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.DEFAULT_REGION
}

variable "OCP_NAME" {
  type = string
  default = "test"
}

variable "DEFAULT_REGION" {
  type = string
  default = "us-east-2"
}

variable "CLUSTER_VPC_SG_ID" {
  type = string 
  
}

variable "PUBLIC_SUBNET_ID" {
  type = string 

}

variable "VPC_ID" {
  type = string 

}

resource "aws_security_group" "bastion_server" {
  name        = "${var.OCP_NAME}-bastion-sg"
  description = "Security group for bastion server"
  vpc_id      = var.VPC_ID

  ingress {
    description      = "ssh to bastion server"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.OCP_NAME}-bastion-sg"
  }
}

data "aws_security_group" "selected" {
  filter {
    name = "group-name"
    values = ["${var.OCP_NAME}-bastion-sg"]
  }
  depends_on = [
    aws_security_group.bastion_server
  ]
}

resource "aws_volume_attachment" "bastion_server" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.bastion_server.id
  instance_id = aws_instance.bastion_server.id

}

resource "aws_instance" "bastion_server" {
  ami           = "ami-01e36b7901e884a10"
  instance_type = "m5.large"
  availability_zone = "${var.DEFAULT_REGION}a"
  key_name = "${var.OCP_NAME}_kp"
  subnet_id = "${var.PUBLIC_SUBNET_ID}"
  vpc_security_group_ids = ["${var.CLUSTER_VPC_SG_ID}", data.aws_security_group.selected.id]

  tags = {
    Name = "${var.OCP_NAME}_bastion"
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.bastion_server.id
  vpc      = true
}

resource "aws_ebs_volume" "bastion_server" {
  availability_zone = "${var.DEFAULT_REGION}a"
  size              = 50

  tags = {
    Name = "${var.OCP_NAME}_bastion"
  }

}
