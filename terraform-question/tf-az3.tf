provider "aws" {
  region = "us-east-1"
  alias = "east1"
}


# Create Virtual Private Cloud
resource "aws_vpc" "vpc_3" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "vpc_3"
  }
}

# Create Internet Gateway 
resource "aws_internet_gateway" "igw_3" {
  vpc_id = aws_vpc.vpc_3.id
  tags = {
    Name = "IGW1"
  }
}

# Create subnet 
resource "aws_subnet" "public_3" {
  vpc_id                  = aws_vpc.vpc_3.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "public_3"
  }
}

# Create route table so IGW_3 can access internet 
resource "aws_route_table" "art_public_3" {
  vpc_id = aws_vpc.vpc_3.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_3.id
  }

  tags = {
    Name = "art_public_3"
  }
}

# Associate RT with subnet 
resource "aws_route_table_association" "rta_subnet_public-3" {
  subnet_id      = aws_subnet.public_3.id
  route_table_id = aws_route_table.art_public_3.id
}

# This should allow traffic in to ngnix 

resource "aws_security_group" "sg_3" {
  name   = "sg_3"
  vpc_id = aws_vpc.vpc_3.id

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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx3" {
  ami                    = "ami-0ca285d4c2cda3300"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_3.id
  vpc_security_group_ids = ["aws_security_group.sg_3.id"]
  key_name               = "terraform"
  tags = {
    Name = "nginx3"
  }
}

output "ec2_global_ips-3" {
  value = aws_instance.nginx3.public_ip
}