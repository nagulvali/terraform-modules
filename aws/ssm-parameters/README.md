# AWS SSM Parameters Module

Terraform module for Systems Manager Parameter Store parameters using a
key-based reference pattern.

## Design Pattern

1. Parameters are a map keyed by `ref_key`
2. Names default to `/{name_prefix}/{ref_key}/{name_suffix}` when `name` is omitted
3. Other modules reference by `ref_key` and fetch `name` or `arn`

## Usage

```hcl
module "ssm" {
  source = "./aws/ssm-parameters"

  region      = "us-east-1"
  name_prefix = "acme"
  name_suffix = "prod"

  parameters = {
    db-password = {
      type  = "SecureString"
      value = var.db_password
      key_id = "alias/aws/ssm"
    }

    app-url = {
      type           = "String"
      insecure_value = "https://example.com"
    }
  }
}

output "db_password_arn" {
  value = module.ssm.parameter_arns["db-password"]
}
```

## Safety

- Default type is `SecureString`.
- Prefer `value` (sensitive) over `insecure_value` for secrets.
- Do not commit real secret values in examples or tfvars.
- `overwrite = true` can clobber existing parameters with the same name.
- The `parameters` output is marked sensitive because values may be secrets.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.0.0 |

## Outputs

| Output | Description |
|--------|-------------|
| `parameter_names` | Resolved parameter names |
| `parameter_arns` | Parameter ARNs |
| `parameter_versions` | Parameter versions |
| `parameter_types` | Parameter types |
| `parameters` | Full resources (sensitive) |
