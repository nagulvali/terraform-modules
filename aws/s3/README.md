# AWS S3 Module

Terraform module for creating AWS S3 resources with a consistent key-based reference pattern and flexible naming convention.

## Design Pattern

This module uses a **key-based reference pattern** where:
1. Resources are defined as maps keyed by `ref_key`
2. Downstream resources reference upstream resources using `*_ref_key` attributes
3. Resource names follow the pattern: `{name_prefix}-{ref_key}-{name_suffix}` (hyphens for DNS compliance)
4. Other modules reference by `ref_key` and fetch `name`, `arn`, or other attributes

## Naming Convention

```
Pattern: {name_prefix}-{ref_key}-{name_suffix}
```

Note: S3 bucket names use hyphens instead of underscores for DNS compliance.

| `name_prefix` | `name_suffix` | `ref_key` | Resulting Name |
|---------------|---------------|-----------|----------------|
| `"acme"` | `"prod"` | `"uploads"` | `acme-uploads-prod` |

## Resources Supported

| Resource | Variable | Reference Key | Name Output |
|----------|----------|---------------|-------------|
| S3 Bucket | `buckets` | `bucket_ref_key` | `bucket_names` |
| Bucket Policy | `bucket_policies` | - | - |
| Bucket Notification | `bucket_notifications` | - | - |
| Replication Config | `replication_configurations` | - | - |
| S3 Object | `objects` | - | - |

## Usage

```hcl
module "s3" {
  source = "./aws/s3"

  region      = "us-east-1"
  name_prefix = "mycompany"
  name_suffix = "prod"

  tags = {
    Environment = "production"
  }

  buckets = {
    uploads = {
      versioning = {
        enabled = true
      }

      encryption = {
        sse_algorithm      = "aws:kms"
        kms_master_key_id  = "alias/s3-key"
        bucket_key_enabled = true
      }

      public_access_block = {
        block_public_acls       = true
        block_public_policy     = true
        ignore_public_acls      = true
        restrict_public_buckets = true
      }

      lifecycle_rules = [
        {
          id      = "archive-old"
          enabled = true
          transition = [
            {
              days          = 30
              storage_class = "STANDARD_IA"
            },
            {
              days          = 90
              storage_class = "GLACIER"
            }
          ]
        }
      ]

      cors_rules = [
        {
          allowed_methods = ["GET", "PUT", "POST"]
          allowed_origins = ["https://app.example.com"]
          allowed_headers = ["*"]
        }
      ]
    }

    logs = {
      versioning = { enabled = false }
      encryption = { sse_algorithm = "AES256" }
      
      lifecycle_rules = [
        {
          id      = "expire-logs"
          enabled = true
          expiration = { days = 90 }
        }
      ]
    }

    assets = {
      website = {
        index_document = "index.html"
        error_document = "error.html"
      }
    }
  }

  bucket_policies = {
    assets-policy = {
      bucket_ref_key = "assets"
      policy         = jsonencode({...})
    }
  }

  bucket_notifications = {
    uploads-events = {
      bucket_ref_key = "uploads"
      eventbridge    = true
      lambda_functions = [
        {
          lambda_function_arn = module.lambda.function_arns["processor"]
          events              = ["s3:ObjectCreated:*"]
        }
      ]
    }
  }
}

# Access outputs by ref_key
output "uploads_bucket_arn" {
  value = module.s3.bucket_arns["uploads"]
}

output "uploads_bucket_name" {
  value = module.s3.bucket_names["uploads"]  # "mycompany-uploads-prod"
}
```

## Features

### S3 Buckets
- Versioning configuration
- Server-side encryption (AES256, KMS)
- Public access block
- Object ownership controls
- Logging configuration
- Website hosting
- CORS configuration
- Lifecycle rules with transitions
- Object lock configuration
- Intelligent tiering

### Bucket Policies
- Custom IAM policies
- Cross-account access
- CloudFront OAC integration

### Bucket Notifications
- Lambda function triggers
- SQS queue notifications
- SNS topic notifications
- EventBridge integration

### Replication
- Cross-region replication
- Same-region replication
- Filter by prefix/tags
- Replica KMS encryption

### S3 Objects
- Content from file, string, or base64
- Custom content types
- Storage class selection
- Server-side encryption

## Reference Keys

| Resource | Ref Key Attribute | Direct Value Attribute |
|----------|-------------------|------------------------|
| Bucket | `bucket_ref_key` | `bucket` |
| Logging Target | `target_bucket_ref_key` | `target_bucket` |

## Cross-Module Integration

```hcl
# Lambda module for notification handlers
module "lambda" {
  source = "./aws/lambda"
  # ...
}

# S3 module references Lambda
module "s3" {
  source = "./aws/s3"

  bucket_notifications = {
    uploads-processor = {
      bucket_ref_key = "uploads"
      lambda_functions = [
        {
          lambda_function_arn = module.lambda.function_arns["processor"]
          events              = ["s3:ObjectCreated:*"]
        }
      ]
    }
  }
}

# CloudFront references S3
resource "aws_cloudfront_distribution" "assets" {
  origin {
    domain_name = module.s3.bucket_regional_domain_names["assets"]
    # ...
  }
}
```

## Outputs

### Naming
| Output | Description |
|--------|-------------|
| `name_prefix` | Name prefix used |
| `name_suffix` | Name suffix used |

### S3 Buckets
| Output | Description |
|--------|-------------|
| `buckets` | Full bucket resources |
| `bucket_names` | Names by ref_key |
| `bucket_ids` | IDs by ref_key |
| `bucket_arns` | ARNs by ref_key |
| `bucket_domain_names` | Domain names by ref_key |
| `bucket_regional_domain_names` | Regional domain names by ref_key |
| `bucket_hosted_zone_ids` | Hosted zone IDs by ref_key |

### Website
| Output | Description |
|--------|-------------|
| `website_endpoints` | Website endpoints by ref_key |
| `website_domains` | Website domains by ref_key |

### Configuration
| Output | Description |
|--------|-------------|
| `bucket_versioning` | Versioning configs |
| `bucket_encryption` | Encryption configs |
| `bucket_policies` | Policies created |
| `bucket_notifications` | Notifications created |
| `replication_configurations` | Replication configs |

### Objects
| Output | Description |
|--------|-------------|
| `objects` | Full object resources |
| `object_ids` | Object IDs by ref_key |
| `object_etags` | Object ETags by ref_key |
| `object_version_ids` | Object version IDs by ref_key |

## Validation

Built-in validation ensures:
- Each bucket policy specifies exactly one of `bucket_ref_key` or `bucket`
- Each notification specifies exactly one of `bucket_ref_key` or `bucket`
- Each replication config specifies exactly one of `bucket_ref_key` or `bucket`
- Each object specifies exactly one of `bucket_ref_key` or `bucket`
