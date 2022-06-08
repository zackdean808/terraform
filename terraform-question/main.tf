
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "prod_vpc" {
  cidr_block		= "10.0.0.0/16" 
  enable_dns_support 	= "true"
  enable_dns_hostnames	= "true"
  enable_classiclink 	= "false"
  instance_tenancy	= "default"

  tags {
    Name 		= "prod-vpc"
  }	
}	
