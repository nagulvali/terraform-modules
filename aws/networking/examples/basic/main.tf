terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "networking" {
  source = "../.."

  region = "us-east-1"

  tags = {
    Environment = "example"
    ManagedBy   = "Terraform"
  }

  vpc = {
    create               = true
    cidr_block           = "10.0.0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
      Name = "networking-example"
    }
  }

  subnets = {
    public_a = {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
    }
  }

  igw = {
    create = true
  }

  route_tables = {}
}
