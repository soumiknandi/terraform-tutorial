# Terraform Tutorial

### What is Terraform

HashiCorp Terraform is an infrastructure as code tool that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share.


## Terraform Components

### Providers

Defines which cloud or service Terraform interacts with.

```
provider "aws" {
  region = "us-east-1"
}
```

### Resources

The most important part of Terraform, used to create, modify, and delete infrastructure components.

Every resource type is associated with a specific provider (e.g., AWS, Azure, GCP).

```
resource "aws_instance" "example" {
  ami           = "ami-123456"
  instance_type = var.instance_type
}
```

### Data Sources

Used to fetch or read information from external sources without managing them.

Commonly used to retrieve existing infrastructure details (e.g., getting an AWS AMI ID).

```
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"
}
```

### Variables

Used to define dynamic values that can be passed into Terraform configurations.

Helps make configurations reusable and flexible.

```
variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}
```

### Outputs

Used to display values after terraform apply.

```
output "instance_ip" {
  value = aws_instance.example.public_ip
}
```

### Modules

Used to organize and reuse Terraform code.

```
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}
```

## Commands

### Init

When you create a new configuration — or check out an existing configuration from version control — you need to initialize the directory with `teraform init`.

Initializing a configuration directory downloads and installs the providers defined in the configuration

Terraform downloads the required provider and installs it in a hidden subdirectory of your current working directory, named `.terraform`. 

The terraform init command prints out which version of the provider was installed. 

Terraform also creates a lock file named `.terraform.lock.hcl` which specifies the exact provider versions used, so that you can control when you want to update the providers used for your project.

### Fmt
TODO

### Validate
TODO

### Plan

The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.

The plan command alone does not actually carry out the proposed changes You can use this command to check whether the proposed changes match what you expected before you apply the changes or share your changes with your team for broader review.

If Terraform detects that no changes are needed to resource instances or to root module output values, terraform plan will report that no actions need to be taken.

### Apply

The terraform apply command executes the actions proposed in a Terraform plan.

When you run `terraform apply` without passing a saved plan file, Terraform automatically creates a new execution plan as if you had run `terraform plan`, prompts you to approve that plan, and takes the indicated actions. You can use all of the planning modes and planning options to customize how Terraform will create the plan.

[More details](https://developer.hashicorp.com/terraform/cli/commands/apply)

### Destroy
TODO
### Output
TODO

## Credentials Setup

### Basic - Parameters in the provider configuration

```
provider "aws" {
  region = "ap-south-1"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}
```

### Environment variables

```
provider "aws" {}
```

```bash
% export AWS_ACCESS_KEY_ID="anaccesskey"
% export AWS_SECRET_ACCESS_KEY="asecretkey"
% export AWS_REGION="us-west-2"
% terraform plan
```

### Shared Configuration and Credentials Files

We can place or generate the credential files under default path or any path and provide the path to terraform provider block.

- Default path of credential and config is under `$HOME/.aws`. No need to mention path if files are present under default path.

```
provider "aws" {}
```

- For custom path we need to provide the path.
```
provider "aws" {
  shared_config_files = ["/Users/tf_user/.aws/conf"]
  shared_credentials_files = ["/Users/tf_user/.aws/creds"]
  profile = "customprofile"
}
```

### Container credentials
TODO

### IAM Role
TODO

### HashiCorp Vault
TODO



## Code 

### Provider Setup

```
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.92.0"
    }
  }
}
```

### Provider AWS Connection

```
provider "aws" {
  access_key = "ACCESS_KEY"
  secret_key = "SECRET_KEY"
  region = "AWS_REGION"
}
```

### Terraform Resource Structure

```
resource "provider_resource_name" "internal_name_used_for_reference" {
  ...
  details
  ...  
}

resource "provider_resource_name" "another_internal_name" {
  ...
  details
  ...
  reference=provider_resource_name.internal_name_used_for_reference.id
}

```



### Simple S3 Bucket
```
resource "aws_s3_bucket" "mik_test_149" {
  bucket = "mik-test-149"
  tags = {
    "env":"test"
  }
  force_destroy = "true"
}
```

- To delete s3 bucket having data use below
    ```
    force_destroy = "true"
    ```
- Tags are optional
    ```
    tags = {
      "env":"test"
    }
    ```
### S3 Bucket With Versioning
```
resource "aws_s3_bucket" "mik_test_149" {
  bucket = "mik-test-149"
}

resource "aws_s3_bucket_versioning" "mik_test_149_version" {
  bucket = aws_s3_bucket.mik_test_149.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

### Simple EC2
```
resource "aws_instance" "aws_simple_ec2_test" {
  ami = "ami-05c179eced2eb9b5b"
  instance_type = "t2.micro"
}
```

### Simple EC2 With AMI Filtering

```
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
}
```

### Key Pair
We can specify the public key directly or pass the public key file.

```
resource "aws_key_pair" "key_aws" {
  key_name   = "aws"
  public_key = "ssh-rsa xxxxxx user@example.com"
}
```

```
resource "aws_key_pair" "key_aws" {
  key_name   = "aws"
  public_key = file("/home/totoro/.ssh/aws.pub")
}
```

### EC2 With Security Group & Key Pair

> Create EC2 with SG allowing SSH, which will allow users to connect to EC2 instance.

#### Resources Used 
- aws_key_pair
- aws_security_group
- aws_vpc_security_group_ingress_rule
- aws_vpc_security_group_egress_rule
- aws_instance

```
resource "aws_key_pair" "key_aws" {
  key_name   = "aws"
  public_key = file("/home/totoro/.ssh/aws.pub")
}

resource "aws_security_group" "sg_allow_ssh" {
  name = "sg_allow_ssh"

  tags = {
    Name = "sg_allow_ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress_allow_ssh" {
  security_group_id = aws_security_group.sg_allow_ssh.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "sq_egress_allow_ephemeral_tcp" {
  security_group_id = aws_security_group.sg_allow_ssh.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 1024
  ip_protocol = "tcp"
  to_port = 65535

}

resource "aws_vpc_security_group_egress_rule" "sq_egress_allow_ephemeral_udp" {
  security_group_id = aws_security_group.sg_allow_ssh.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 1024
  ip_protocol = "udp"
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
  vpc_security_group_ids = [aws_security_group.sg_allow_ssh.id]
}
```

### EC2 With VPC, Security Group & Key Pair. Implemented for-loop to allow multiple ports and protocols for SG

#### Resources Used 
- aws_key_pair
- aws_vpc
- aws_internet_gateway
- aws_subnet
- aws_route_table
- aws_route_table_association
- aws_security_group
- aws_vpc_security_group_ingress_rule
- aws_vpc_security_group_egress_rule
- aws_instance

```
resource "aws_key_pair" "key_aws" {
  key_name   = "aws"
  public_key = file("/home/totoro/.ssh/aws.pub")
}

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

resource "aws_instance" "ec2_ubuntu" {
  ami = data.aws_ami.latest_ubuntu.id
  associate_public_ip_address = "true"
  instance_type = "t2.micro"
  key_name = aws_key_pair.key_aws.key_name
  subnet_id = aws_subnet.main_vpc_subnet_pub.id
  vpc_security_group_ids = [aws_security_group.sg_allow_ssh_http_tls.id]
  user_data = file("${path.module}/user_data.sh")
}
```