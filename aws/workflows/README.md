# AWS Workflows (Step Functions) Module

Terraform module for AWS Step Functions state machines and activities using a
key-based reference pattern.

## Design Pattern

1. Resources are maps keyed by `ref_key`
2. Names follow `{name_prefix}_{ref_key}_{name_suffix}` unless overridden
3. Consumers supply the execution role ARN and ASL definition JSON

## Resources Supported

| Resource | Variable |
|----------|----------|
| State Machine | `state_machines` |
| Activity | `activities` |

## Usage

```hcl
module "workflows" {
  source = "./aws/workflows"

  region      = "us-east-1"
  name_prefix = "acme"
  name_suffix = "prod"

  state_machines = {
    order = {
      role_arn = aws_iam_role.sfn.arn
      type     = "STANDARD"
      definition = jsonencode({
        Comment = "Example"
        StartAt = "Pass"
        States = {
          Pass = {
            Type = "Pass"
            End  = true
          }
        }
      })
    }
  }
}
```

## Safety

- State machine definitions can invoke other AWS APIs; keep IAM roles
  least-privilege.
- EXPRESS workflows have different logging/retention and pricing behavior than
  STANDARD.
- Enabling logging requires a valid CloudWatch Logs destination ARN.
- Review definitions carefully; bad ASL still validates as a string in Terraform.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.0.0 |

## Outputs

| Output | Description |
|--------|-------------|
| `state_machine_arns` / `state_machine_names` | State machine identifiers |
| `activity_arns` / `activity_names` | Activity identifiers |
