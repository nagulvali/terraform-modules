terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "acm" {
  source = "../.."

  region      = "us-east-1"
  name_prefix = "acme"
  name_suffix = "example"

  tags = {
    Environment = "example"
    ManagedBy   = "terraform"
  }

  certificates = {
    app = {
      domain_name               = "example.com"
      subject_alternative_names = ["www.example.com"]
      validation_method         = "DNS"
      create_route53_records    = false
      wait_for_validation       = false
    }
  }
}
