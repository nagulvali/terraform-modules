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

# Example uses a placeholder role ARN string for static validation.
# Replace with a real IAM role ARN before apply.
module "workflows" {
  source = "../.."

  region      = "us-east-1"
  name_prefix = "acme"
  name_suffix = "example"

  tags = {
    Environment = "example"
    ManagedBy   = "terraform"
  }

  state_machines = {
    hello = {
      role_arn = "arn:aws:iam::123456789012:role/stepfunctions-example"
      type     = "STANDARD"
      definition = jsonencode({
        Comment = "Hello world example"
        StartAt = "Hello"
        States = {
          Hello = {
            Type   = "Pass"
            Result = "Hello"
            End    = true
          }
        }
      })
    }
  }

  activities = {
    worker = {}
  }
}
