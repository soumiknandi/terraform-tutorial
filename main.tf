terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.92.0"
    }
  }
}

# Set up provider config
provider "aws" {
  profile = "profile1"
}

# Structure
# resource "provider_resource_name" "internal_name_user_for_reference" {
#   ...
#   details
#   ...
# }

# Basic ec2
# resource "aws_instance" "tf_test_1" {
#   ami = "ami-05c179eced2eb9b5b"
#   instance_type = "t2.micro"
# }

# resource "aws_s3_bucket" "mik_test_149" {
#   bucket = "mik-test-149"
#   tags = {
#     "env":"test"
#   }
#   force_destroy = "true"
# }

# resource "aws_s3_bucket_versioning" "mik_test_149_version" {
#   bucket = aws_s3_bucket.mik_test_149.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# create key
resource "aws_key_pair" "key_aws" {
  key_name   = "aws"
  public_key = file("/home/totoro/.ssh/aws.pub")
}

# Security group
resource "aws_security_group" "sg_allow_tls_ssh" {
  name        = "allow_tls_ssh"

  tags = {
    Name = "allow_tls_ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress_allow_tls" {
  security_group_id = aws_security_group.sg_allow_tls_ssh.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 443
  ip_protocol = "tcp"
  to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress_allow_ssh" {
  security_group_id = aws_security_group.sg_allow_tls_ssh.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "sq_egress_allow_ephemeral" {
  security_group_id = aws_security_group.sg_allow_tls_ssh.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 1024
  ip_protocol = "tcp"
  to_port = 65535

}

data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-*/ubuntu-*-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "ec2_ubuntu" {
  ami = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.key_aws.key_name
  vpc_security_group_ids = [aws_security_group.sg_allow_tls_ssh.id]
}