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

module "kms" {
  source = "../.."

  region      = "us-east-1"
  name_prefix = "acme"
  name_suffix = "example"

  tags = {
    Environment = "example"
    ManagedBy   = "terraform"
  }

  keys = {
    app = {
      description         = "Example application key"
      enable_key_rotation = true
    }
  }

  aliases = {
    app = {
      target_key_ref_key = "app"
    }
  }
}
