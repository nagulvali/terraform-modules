# AWS KMS Module

Terraform module for KMS customer managed keys, aliases, and grants using a
key-based reference pattern.

## Design Pattern

1. Resources are maps keyed by `ref_key`
2. Aliases and grants reference keys via `target_key_ref_key` / `key_ref_key`
3. Key Name tags follow `{name_prefix}_{ref_key}_{name_suffix}`
4. Alias names default to `alias/{name_prefix}-{ref_key}-{name_suffix}`

## Resources Supported

| Resource | Variable | Reference Key |
|----------|----------|---------------|
| KMS Key | `keys` | `key_ref_key` / `target_key_ref_key` |
| Alias | `aliases` | - |
| Grant | `grants` | - |

## Usage

```hcl
module "kms" {
  source = "./aws/kms"

  region      = "us-east-1"
  name_prefix = "acme"
  name_suffix = "prod"

  keys = {
    app = {
      description         = "Application encryption key"
      enable_key_rotation = true
    }
  }

  aliases = {
    app = {
      target_key_ref_key = "app"
    }
  }
}

output "app_key_arn" {
  value = module.kms.key_arns["app"]
}
```

## Safety

- Key rotation defaults to enabled for symmetric keys.
- `deletion_window_in_days` defaults to 30 (range 7–30).
- Avoid `bypass_policy_lockout_safety_check` unless you accept lockout risk.
- Grants can expose decrypt/encrypt operations; keep principals least-privilege.
- Destroying a key schedules deletion; ciphertext encrypted with it becomes
  unrecoverable after deletion completes.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.0.0 |

## Outputs

| Output | Description |
|--------|-------------|
| `key_ids` / `key_arns` / `key_names` | Key identifiers |
| `alias_names` / `alias_arns` | Alias identifiers |
| `grant_ids` / `grant_tokens` | Grant identifiers (`grant_tokens` sensitive) |
