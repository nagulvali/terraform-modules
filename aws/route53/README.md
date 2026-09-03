# AWS Route53 Module

Terraform module for Route53 hosted zones, records, and health checks using a
key-based reference pattern.

## Design Pattern

1. Resources are maps keyed by `ref_key`
2. Records reference zones/health checks via `zone_ref_key` / `health_check_ref_key`
3. Name tags follow `{name_prefix}_{ref_key}_{name_suffix}`

## Resources Supported

| Resource | Variable | Reference Key |
|----------|----------|---------------|
| Hosted Zone | `zones` | `zone_ref_key` |
| Record | `records` | - |
| Health Check | `health_checks` | `health_check_ref_key` |

## Usage

```hcl
module "route53" {
  source = "./aws/route53"

  region      = "us-east-1"
  name_prefix = "acme"
  name_suffix = "prod"

  zones = {
    public = {
      name    = "example.com"
      comment = "Public zone"
    }
  }

  records = {
    apex = {
      zone_ref_key = "public"
      name         = "example.com"
      type         = "A"
      ttl          = 300
      records      = ["203.0.113.10"]
    }

    www = {
      zone_ref_key = "public"
      name         = "www.example.com"
      type         = "CNAME"
      ttl          = 300
      records      = ["example.com"]
    }
  }
}
```

## Safety

- Public zones expose DNS publicly once delegated.
- `force_destroy = true` deletes all records when the zone is destroyed.
- Alias records require the target hosted zone ID from the AWS service.
- Private zones require at least one VPC association.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.0.0 |

## Outputs

| Output | Description |
|--------|-------------|
| `zone_ids` / `zone_arns` / `name_servers` | Zone identifiers and NS set |
| `record_fqdns` / `record_names` | Record identifiers |
| `health_check_ids` / `health_check_arns` | Health check identifiers |
