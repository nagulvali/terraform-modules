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

module "ebs" {
  source = "../.."

  region      = "us-east-1"
  name_prefix = "acme"
  name_suffix = "example"

  tags = {
    Environment = "example"
    ManagedBy   = "terraform"
  }

  volumes = {
    data = {
      availability_zone = "us-east-1a"
      size              = 20
      type              = "gp3"
      encrypted         = true
    }
  }

  snapshots = {
    data-baseline = {
      volume_ref_key = "data"
      description    = "Baseline snapshot for example volume"
    }
  }
}
