# AWS Lambda Module

Terraform module for creating AWS Lambda resources with a consistent key-based reference pattern and flexible naming convention.

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
| `"acme"` | `"prod"` | `"api-handler"` | `acme_api-handler_prod` |

## Resources Supported

| Resource | Variable | Reference Key | Name Output |
|----------|----------|---------------|-------------|
| Lambda Layer | `layers` | `layer_ref_keys` | `layer_names` |
| Lambda Function | `functions` | `function_ref_key` | `function_names` |
| Lambda Alias | `aliases` | - | `alias_names` |
| Lambda Permission | `permissions` | - | - |
| Lambda Function URL | `function_urls` | - | - |
| Event Source Mapping | `event_source_mappings` | - | - |
| CloudWatch Log Group | `log_groups` | - | `log_group_names` |

## Usage

```hcl
module "lambda" {
  source = "./aws/lambda"

  region      = "us-east-1"
  name_prefix = "mycompany"
  name_suffix = "prod"

  tags = {
    Environment = "production"
  }

  # Lambda Layers
  layers = {
    utils = {
      description         = "Utility functions"
      compatible_runtimes = ["python3.12"]
      filename            = "layers/utils.zip"
    }
  }

  # Lambda Functions
  functions = {
    api-handler = {
      description = "API request handler"
      handler     = "index.handler"
      runtime     = "python3.12"
      filename    = "functions/api-handler.zip"
      
      role_arn    = module.iam.role_arns["lambda-exec"]
      timeout     = 30
      memory_size = 256

      environment_variables = {
        LOG_LEVEL = "INFO"
      }

      layer_ref_keys = ["utils"]
      tracing_mode   = "Active"
    }

    processor = {
      description = "SQS message processor"
      handler     = "processor.handler"
      runtime     = "python3.12"
      filename    = "functions/processor.zip"
      
      role_arn    = module.iam.role_arns["lambda-exec"]
      timeout     = 60
      memory_size = 512

      reserved_concurrent_executions = 10
    }
  }

  # Lambda Aliases
  aliases = {
    api-live = {
      function_ref_key = "api-handler"
      function_version = "$LATEST"
      description      = "Production alias"
    }
  }

  # Lambda Permissions
  permissions = {
    api-gateway = {
      function_ref_key = "api-handler"
      principal        = "apigateway.amazonaws.com"
      source_arn       = "arn:aws:execute-api:us-east-1:123456789012:xxx/*/*/*"
    }
  }

  # Lambda Function URLs
  function_urls = {
    api-url = {
      function_ref_key   = "api-handler"
      authorization_type = "NONE"
      cors = {
        allow_origins = ["https://example.com"]
        allow_methods = ["GET", "POST"]
      }
    }
  }

  # Event Source Mappings
  event_source_mappings = {
    processor-sqs = {
      function_ref_key = "processor"
      event_source_arn = "arn:aws:sqs:us-east-1:123456789012:my-queue"
      batch_size       = 10
    }
  }

  # CloudWatch Log Groups
  log_groups = {
    api-handler = {
      function_ref_key  = "api-handler"
      retention_in_days = 30
    }
    processor = {
      function_ref_key  = "processor"
      retention_in_days = 14
    }
  }
}

# Access outputs by ref_key
output "api_function_arn" {
  value = module.lambda.function_arns["api-handler"]
}

output "api_invoke_arn" {
  value = module.lambda.function_invoke_arns["api-handler"]
}

output "api_url" {
  value = module.lambda.function_url_endpoints["api-url"]
}
```

## Reference Keys

| Resource | Ref Key Attribute | Direct Value Attribute |
|----------|-------------------|------------------------|
| Layer | `layer_ref_keys` | `layer_arns` |
| Function | `function_ref_key` | `function_name` |

## Features

### Lambda Layers
- Local file or S3 deployment
- Compatible runtimes and architectures
- Reference in functions via `layer_ref_keys`

### Lambda Functions
- Zip or Container image deployment
- VPC configuration support
- Environment variables
- Tracing (X-Ray)
- Dead letter queues
- Ephemeral storage
- SnapStart support
- Reserved concurrency
- Logging configuration (JSON format)

### Lambda Aliases
- Version aliases with descriptions
- Weighted routing for canary deployments

### Lambda Permissions
- API Gateway invocation
- S3 bucket notifications
- EventBridge rules
- SNS topics
- Custom principals

### Lambda Function URLs
- Public HTTPS endpoints
- CORS configuration
- IAM or no authorization

### Event Source Mappings
- SQS queues
- DynamoDB Streams
- Kinesis streams
- Apache Kafka (MSK and self-managed)
- DocumentDB
- Filter criteria
- Failure destinations
- Scaling configuration

### CloudWatch Log Groups
- Auto-created before functions
- Configurable retention
- KMS encryption support

## Cross-Module Integration

```hcl
# IAM module for execution role
module "iam" {
  source = "./aws/iam"
  # ...
}

# Lambda module references IAM role
module "lambda" {
  source = "./aws/lambda"

  functions = {
    api-handler = {
      role_arn = module.iam.role_arns["lambda-exec"]
      # ...
    }
  }
}

# API Gateway references Lambda
resource "aws_apigatewayv2_integration" "lambda" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_uri    = module.lambda.function_invoke_arns["api-handler"]
}
```

## Outputs

### Naming
| Output | Description |
|--------|-------------|
| `name_prefix` | Name prefix used |
| `name_suffix` | Name suffix used |

### Lambda Layers
| Output | Description |
|--------|-------------|
| `layers` | Full layer resources |
| `layer_names` | Names by ref_key |
| `layer_arns` | Versioned ARNs by ref_key |

### Lambda Functions
| Output | Description |
|--------|-------------|
| `functions` | Full function resources |
| `function_names` | Names by ref_key |
| `function_arns` | ARNs by ref_key |
| `function_invoke_arns` | Invoke ARNs (for API Gateway) |
| `function_qualified_arns` | Qualified ARNs with version |
| `function_versions` | Latest versions |

### Lambda Aliases
| Output | Description |
|--------|-------------|
| `aliases` | Full alias resources |
| `alias_names` | Names by ref_key |
| `alias_arns` | ARNs by ref_key |
| `alias_invoke_arns` | Invoke ARNs |

### Lambda Function URLs
| Output | Description |
|--------|-------------|
| `function_urls` | Full function URL resources |
| `function_url_endpoints` | URL endpoints by ref_key |

### Event Source Mappings
| Output | Description |
|--------|-------------|
| `event_source_mappings` | Full ESM resources |
| `event_source_mapping_uuids` | UUIDs by ref_key |

### CloudWatch Log Groups
| Output | Description |
|--------|-------------|
| `log_groups` | Full log group resources |
| `log_group_names` | Names by ref_key |
| `log_group_arns` | ARNs by ref_key |

## Validation

Built-in validation ensures:
- Each alias specifies exactly one of `function_ref_key` or `function_name`
- Each permission specifies exactly one of `function_ref_key` or `function_name`
- Each function URL specifies exactly one of `function_ref_key` or `function_name`
- Each event source mapping specifies exactly one of `function_ref_key` or `function_name`
