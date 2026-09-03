# AWS EventBridge Module

Terraform module for creating AWS EventBridge resources with a consistent key-based reference pattern and flexible naming convention.

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
| `"acme"` | `"prod"` | `"app-events"` | `acme_app-events_prod` |

## Resources Supported

| Resource | Variable | Reference Key | Name Output |
|----------|----------|---------------|-------------|
| Event Bus | `buses` | `bus_ref_key` | `bus_names` |
| Event Rule | `rules` | `rule_ref_key` | `rule_names` |
| Event Target | `targets` | - | - |
| Event Archive | `archives` | - | `archive_names` |
| Connection | `connections` | `connection_ref_key` | `connection_names` |
| API Destination | `api_destinations` | - | `api_destination_names` |
| Schedule Group | `schedule_groups` | `group_ref_key` | `schedule_group_names` |
| Schedule | `schedules` | - | `schedule_names` |

## Usage

```hcl
module "eventbridge" {
  source = "./aws/eventbridge"

  region      = "us-east-1"
  name_prefix = "mycompany"
  name_suffix = "prod"

  tags = {
    Environment = "production"
  }

  # Event Buses
  buses = {
    app-events = {
      tags = { Purpose = "application" }
    }
  }

  # Event Rules
  rules = {
    order-created = {
      description = "Capture order events"
      bus_ref_key = "app-events"
      event_pattern = jsonencode({
        source      = ["com.mycompany.orders"]
        detail-type = ["Order Created"]
      })
    }

    hourly-task = {
      description         = "Hourly scheduled task"
      schedule_expression = "rate(1 hour)"
    }
  }

  # Event Targets
  targets = {
    order-lambda = {
      rule_ref_key = "order-created"
      bus_ref_key  = "app-events"
      target_id    = "order-handler"
      arn          = module.lambda.function_arns["order-processor"]

      retry_policy = {
        maximum_retry_attempts = 3
      }
    }

    hourly-lambda = {
      rule_ref_key = "hourly-task"
      target_id    = "hourly-handler"
      arn          = module.lambda.function_arns["hourly-task"]
    }
  }

  # Event Archives
  archives = {
    app-archive = {
      bus_ref_key    = "app-events"
      retention_days = 30
    }
  }

  # Connections for API Destinations
  connections = {
    webhook = {
      authorization_type = "API_KEY"
      auth_parameters = {
        api_key = {
          key   = "x-api-key"
          value = "secret-key"
        }
      }
    }
  }

  # API Destinations
  api_destinations = {
    external-webhook = {
      connection_ref_key  = "webhook"
      invocation_endpoint = "https://api.example.com/webhook"
      http_method         = "POST"
    }
  }

  # EventBridge Scheduler
  schedule_groups = {
    maintenance = {}
  }

  schedules = {
    health-check = {
      group_ref_key       = "maintenance"
      schedule_expression = "rate(5 minutes)"
      flexible_time_window = { mode = "OFF" }
      target = {
        arn      = module.lambda.function_arns["health-check"]
        role_arn = module.iam.role_arns["scheduler-exec"]
      }
    }
  }
}
```

## Reference Keys

| Resource | Ref Key Attribute | Direct Value Attribute |
|----------|-------------------|------------------------|
| Bus | `bus_ref_key` | `event_bus_name` |
| Rule | `rule_ref_key` | `rule_name` |
| Connection | `connection_ref_key` | `connection_arn` |
| Schedule Group | `group_ref_key` | `group_name` |

## Features

### Event Buses
- Custom event buses for application events
- Cross-account permissions with conditions

### Event Rules
- Event pattern matching (AWS events, custom events)
- Schedule expressions (rate, cron)
- Managed rules with role ARN

### Event Targets
- Lambda, SNS, SQS, Step Functions, ECS, Batch, Kinesis
- Input transformers for event transformation
- Retry policies and dead letter queues
- HTTP targets with API destinations

### Event Archives
- Archive events for replay
- Pattern filtering
- Configurable retention

### Connections & API Destinations
- API Key, Basic, OAuth authentication
- Custom HTTP parameters
- Rate limiting

### EventBridge Scheduler
- Schedule groups for organization
- Flexible time windows
- Timezone support
- One-time and recurring schedules
- ECS, Lambda, Step Functions targets

## Cross-Module Integration

```hcl
# IAM module for EventBridge roles
module "iam" {
  source = "./aws/iam"
  # ...
}

# Lambda module for targets
module "lambda" {
  source = "./aws/lambda"
  # ...
}

# EventBridge references both
module "eventbridge" {
  source = "./aws/eventbridge"

  targets = {
    order-handler = {
      rule_ref_key = "order-created"
      target_id    = "lambda"
      arn          = module.lambda.function_arns["order-processor"]
    }
  }

  schedules = {
    daily-task = {
      schedule_expression = "rate(1 day)"
      target = {
        arn      = module.lambda.function_arns["daily-task"]
        role_arn = module.iam.role_arns["scheduler-exec"]
      }
      # ...
    }
  }
}
```

## Outputs

### Naming
| Output | Description |
|--------|-------------|
| `name_prefix` | Name prefix used |
| `name_suffix` | Name suffix used |

### Event Buses
| Output | Description |
|--------|-------------|
| `buses` | Full bus resources |
| `bus_names` | Names by ref_key |
| `bus_arns` | ARNs by ref_key |

### Event Rules
| Output | Description |
|--------|-------------|
| `rules` | Full rule resources |
| `rule_names` | Names by ref_key |
| `rule_arns` | ARNs by ref_key |

### Event Targets
| Output | Description |
|--------|-------------|
| `targets` | Full target resources |

### Event Archives
| Output | Description |
|--------|-------------|
| `archives` | Full archive resources |
| `archive_names` | Names by ref_key |
| `archive_arns` | ARNs by ref_key |

### Connections
| Output | Description |
|--------|-------------|
| `connections` | Full connection resources |
| `connection_names` | Names by ref_key |
| `connection_arns` | ARNs by ref_key |

### API Destinations
| Output | Description |
|--------|-------------|
| `api_destinations` | Full API destination resources |
| `api_destination_names` | Names by ref_key |
| `api_destination_arns` | ARNs by ref_key |

### Schedule Groups
| Output | Description |
|--------|-------------|
| `schedule_groups` | Full schedule group resources |
| `schedule_group_names` | Names by ref_key |
| `schedule_group_arns` | ARNs by ref_key |

### Schedules
| Output | Description |
|--------|-------------|
| `schedules` | Full schedule resources |
| `schedule_names` | Names by ref_key |
| `schedule_arns` | ARNs by ref_key |

## Validation

Built-in validation ensures:
- Each target specifies exactly one of `rule_ref_key` or `rule_name`
- Each API destination specifies exactly one of `connection_ref_key` or `connection_arn`
