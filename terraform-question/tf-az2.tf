provider "aws" {
  region = "us-east-2"
  alias = "east2"
}


# Create Virtual Private Cloud
resource "aws_vpc" "vpc_2" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "vpc_2"
  }
}

# Create Internet Gateway 
resource "aws_internet_gateway" "igw_2" {
  vpc_id = aws_vpc.vpc_2.id
  tags = {
    Name = "IGW1"
  }
}

# Create subnet 
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.vpc_2.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "public_2"
  }
}

# Create route table so IGW_2 can access internet 
resource "aws_route_table" "art_public_2" {
  vpc_id = aws_vpc.vpc_2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_2.id
  }

  tags = {
    Name = "art_public_2"
  }
}

# Associate RT with subnet 
resource "aws_route_table_association" "rta_subnet_public-2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.art_public_2.id
}

# This should allow traffic in to ngnix 

resource "aws_security_group" "sg_2" {
  name   = "sg_2"
  vpc_id = aws_vpc.vpc_2.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "_2"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_2"
  }
}

resource "aws_instance" "nginx2" {
  ami                    = "ami-0ca285d4c2cda3300"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_2.id
  vpc_security_group_ids = ["aws_security_group.sg_2.id"]
  key_name               = "terraform"
  tags = {
    Name = "nginx2"
  }
}

output "ec2_global_ips-2" {
  value = aws_instance.nginx2
}