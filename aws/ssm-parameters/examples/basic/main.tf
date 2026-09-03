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

module "ssm_parameters" {
  source = "../.."

  region      = "us-east-1"
  name_prefix = "acme"
  name_suffix = "example"

  tags = {
    Environment = "example"
    ManagedBy   = "terraform"
  }

  parameters = {
    app-config = {
      type           = "String"
      insecure_value = "example-value"
      description    = "Non-secret example parameter"
    }
  }
}
