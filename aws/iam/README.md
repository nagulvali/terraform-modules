# AWS IAM Module

Terraform module for creating AWS IAM resources with a consistent key-based reference pattern and flexible naming convention.

## Design Pattern

This module uses a **key-based reference pattern** where:
1. Resources are defined as maps keyed by `ref_key`
2. Downstream resources reference upstream resources using `*_ref_key` attributes
3. Resource names follow the pattern: `{name_prefix}_{ref_key}_{name_suffix}`
4. Other modules reference by `ref_key` and fetch `name`, `arn`, or other attributes

## Naming Convention

```
Pattern: {name_prefix}_{ref_key}_{name_suffix}
```

| `name_prefix` | `name_suffix` | `ref_key` | Resulting Name |
|---------------|---------------|-----------|----------------|
| `"acme"` | `"prod"` | `"lambda-exec"` | `acme_lambda-exec_prod` |
| `"acme"` | `null` | `"lambda-exec"` | `acme_lambda-exec` |
| `null` | `"prod"` | `"lambda-exec"` | `lambda-exec_prod` |
| `null` | `null` | `"lambda-exec"` | `lambda-exec` |

## Resources Supported

| Resource | Variable | Reference Key | Name Output |
|----------|----------|---------------|-------------|
| IAM Role | `roles` | `role_ref_key` | `role_names` |
| IAM Policy | `policies` | `policy_ref_key` | `policy_names` |
| IAM Role Policy (Inline) | `role_policies` | - | `role_policy_names` |
| IAM Role Policy Attachment | `role_policy_attachments` | - | - |

## Usage

```hcl
module "iam" {
  source = "./aws/iam"

  region = "us-east-1"

  # Naming convention
  name_prefix = "mycompany"
  name_suffix = "prod"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }

  # IAM Roles
  roles = {
    lambda-exec = {
      description = "Execution role for Lambda functions"
      
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect    = "Allow"
          Principal = { Service = "lambda.amazonaws.com" }
          Action    = "sts:AssumeRole"
        }]
      })

      # Inline policies defined in role
      inline_policies = {
        cloudwatch = jsonencode({
          Version = "2012-10-17"
          Statement = [{
            Effect   = "Allow"
            Action   = ["logs:*"]
            Resource = "*"
          }]
        })
      }

      # AWS managed policies
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
      ]
    }

    ec2-instance = {
      description = "Role for EC2 instances"
      
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect    = "Allow"
          Principal = { Service = "ec2.amazonaws.com" }
          Action    = "sts:AssumeRole"
        }]
      })
    }
  }

  # IAM Policies (Customer Managed)
  policies = {
    s3-readonly = {
      description = "Read-only access to S3"
      
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect   = "Allow"
          Action   = ["s3:GetObject", "s3:ListBucket"]
          Resource = "*"
        }]
      })
    }
  }

  # IAM Role Policies (Standalone Inline)
  role_policies = {
    ec2-ssm = {
      role_ref_key = "ec2-instance"  # References role by key
      
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect   = "Allow"
          Action   = ["ssm:GetParameter*"]
          Resource = "*"
        }]
      })
    }
  }

  # IAM Role Policy Attachments
  role_policy_attachments = {
    lambda-s3 = {
      role_ref_key   = "lambda-exec"   # References role by key
      policy_ref_key = "s3-readonly"   # References policy by key
    }

    ec2-ssm-managed = {
      role_ref_key = "ec2-instance"
      policy_arn   = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }
}

# Access outputs by ref_key
output "lambda_role_arn" {
  value = module.iam.role_arns["lambda-exec"]
}

output "lambda_role_name" {
  value = module.iam.role_names["lambda-exec"]  # "mycompany_lambda-exec_prod"
}
```

## Reference Keys vs Direct Values

Each resource supports both reference keys (for resources in this module) and direct values (for external resources):

| Resource | Ref Key Attribute | Direct Value Attribute |
|----------|-------------------|------------------------|
| Role | `role_ref_key` | `role_name` |
| Policy | `policy_ref_key` | `policy_arn` |

## Outputs

### Naming
| Output | Description |
|--------|-------------|
| `name_prefix` | Name prefix used for all resources |
| `name_suffix` | Name suffix used for all resources |

### IAM Roles
| Output | Description |
|--------|-------------|
| `roles` | Map of all IAM roles created, keyed by ref_key |
| `role_names` | Map of role names (with prefix/suffix), keyed by ref_key |
| `role_arns` | Map of role ARNs, keyed by ref_key |
| `role_ids` | Map of role IDs, keyed by ref_key |
| `role_unique_ids` | Map of role unique IDs, keyed by ref_key |

### IAM Policies
| Output | Description |
|--------|-------------|
| `policies` | Map of all IAM policies created, keyed by ref_key |
| `policy_names` | Map of policy names (with prefix/suffix), keyed by ref_key |
| `policy_arns` | Map of policy ARNs, keyed by ref_key |
| `policy_ids` | Map of policy IDs, keyed by ref_key |

### IAM Role Policies (Inline)
| Output | Description |
|--------|-------------|
| `role_policies` | Map of all inline policies created, keyed by ref_key |
| `role_policy_names` | Map of inline policy names (with prefix/suffix), keyed by ref_key |
| `role_policy_ids` | Map of inline policy IDs, keyed by ref_key |

### IAM Role Policy Attachments
| Output | Description |
|--------|-------------|
| `role_policy_attachments` | Map of all attachments created, keyed by ref_key |

## Validation

The module includes built-in validation to ensure:
- Each role policy specifies exactly one of `role_ref_key` or `role_name`
- Each attachment specifies exactly one of `role_ref_key` or `role_name`
- Each attachment specifies exactly one of `policy_ref_key` or `policy_arn`

## Cross-Module Reference Example

```hcl
# In Lambda module
resource "aws_lambda_function" "this" {
  role = module.iam.role_arns["lambda-exec"]
  # ...
}

# In EC2 module
resource "aws_iam_instance_profile" "this" {
  role = module.iam.role_names["ec2-instance"]
}
```
