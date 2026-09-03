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

module "route53" {
  source = "../.."

  region      = "us-east-1"
  name_prefix = "acme"
  name_suffix = "example"

  tags = {
    Environment = "example"
    ManagedBy   = "terraform"
  }

  zones = {
    public = {
      name          = "example.internal"
      comment       = "Example public zone"
      force_destroy = true
    }
  }

  records = {
    apex = {
      zone_ref_key = "public"
      name         = "example.internal"
      type         = "A"
      ttl          = 300
      records      = ["203.0.113.10"]
    }
  }

  health_checks = {
    apex-http = {
      type              = "HTTP"
      fqdn              = "example.internal"
      port              = 80
      resource_path     = "/"
      request_interval  = 30
      failure_threshold = 3
    }
  }
}
