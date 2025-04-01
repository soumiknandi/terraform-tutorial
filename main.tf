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

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "main_vpc_subnet_pub" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "main_vpc_subnet_pub"
  }
}

resource "aws_subnet" "main_vpc_subnet_pvt" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "main_vpc_subnet_pvt"
  }
}

resource "aws_internet_gateway" "main_vpc_gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_vpc_gw"
  }
}

resource "aws_route_table" "main_vpc_subnet_pub_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_vpc_gw.id
  }

  tags = {
    Name = "main_vpc_subnet_pub_rt"
  }
}

resource "aws_route_table" "main_vpc_subnet_pvt_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "main_vpc_subnet_pvt_rt"
  }
}

resource "aws_route_table_association" "main_vpc_subnet_pvt_rt_association" {
  subnet_id = aws_subnet.main_vpc_subnet_pvt.id
  route_table_id = aws_route_table.main_vpc_subnet_pvt_rt.id
}

resource "aws_route_table_association" "main_vpc_subnet_pub_rt_association" {
  subnet_id = aws_subnet.main_vpc_subnet_pub.id
  route_table_id = aws_route_table.main_vpc_subnet_pub_rt.id
}

# Security group
resource "aws_security_group" "sg_allow_ssh_http_tls" {
  name = "allow_ssh_https_tls"
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "allow_ssh_https_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress_allow_ssh_http_tls" {
  security_group_id = aws_security_group.sg_allow_ssh_http_tls.id

  for_each = toset(["22", "80", "443"])
  from_port = each.value
  to_port = each.value

  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "sq_egress_allow_ephemeral" {
  security_group_id = aws_security_group.sg_allow_ssh_http_tls.id

  for_each = toset(["tcp","udp"])
  ip_protocol = each.value

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 1024
  to_port = 65535
}

resource "aws_vpc_security_group_egress_rule" "sq_egress_allow_http_tls" {
  security_group_id = aws_security_group.sg_allow_ssh_http_tls.id

  for_each = toset(["80","443"])
  from_port = each.value
  to_port = each.value

  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
}

data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["amazon"]

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

# resource "aws_instance" "ec2_ubuntu" {
#   ami = data.aws_ami.latest_ubuntu.id
#   associate_public_ip_address = "true"
#   instance_type = "t2.micro"
#   key_name = aws_key_pair.key_aws.key_name
#   subnet_id = aws_subnet.main_vpc_subnet_pub.id
#   vpc_security_group_ids = [aws_security_group.sg_allow_ssh_http_tls.id]
#   user_data = file("${path.module}/user_data.sh")
# }