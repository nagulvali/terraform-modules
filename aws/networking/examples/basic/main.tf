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

  name_prefix = "acme"
  name_suffix = "prod"

  tags = {
    Environment = "example"
    ManagedBy   = "Terraform"
  }

  vpcs = {
    main = {
      cidr_block           = "10.0.0.0/16"
      instance_tenancy     = "default"
      enable_dns_support   = true
      enable_dns_hostnames = true
    }
  }

  subnets = {
    public_a = {
      vpc_ref_key             = "main"
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
    }
  }

  internet_gateways = {
    main = {
      vpc_ref_key = "main"
    }
  }

  route_tables = {
    public = {
      vpc_ref_key = "main"
      routes = [
        {
          destination_cidr_block = "0.0.0.0/0"
          igw_ref_key            = "main"
        }
      ]
      subnet_associations = [
        { subnet_ref_key = "public_a" }
      ]
    }
  }
}
