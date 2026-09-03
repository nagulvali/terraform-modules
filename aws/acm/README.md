# AWS ACM Module

Terraform module for ACM certificates with optional Route53 DNS validation
using a key-based reference pattern.

## Design Pattern

1. Certificates are maps keyed by `ref_key`
2. Name tags follow `{name_prefix}_{ref_key}_{name_suffix}`
3. Optional Route53 validation records can be created when `create_route53_records = true`

## Resources Supported

| Resource | Variable |
|----------|----------|
| ACM Certificate (request) | `certificates` |
| Route53 validation records | via `create_route53_records` |
| Certificate validation waiter | via `wait_for_validation` |
| Imported certificate | `imported_certificates` |

## Usage

```hcl
module "acm" {
  source = "./aws/acm"

  region      = "us-east-1"
  name_prefix = "acme"
  name_suffix = "prod"

  certificates = {
    app = {
      domain_name               = "example.com"
      subject_alternative_names = ["www.example.com"]
      validation_method         = "DNS"
      create_route53_records    = true
      zone_id                   = "Z1234567890"
      wait_for_validation       = true
    }
  }
}

output "app_cert_arn" {
  value = module.acm.certificate_arns["app"]
}
```

## Safety

- CloudFront requires certificates in `us-east-1`.
- `wait_for_validation` only runs when `create_route53_records = true`.
- Imported private keys are sensitive; do not commit them.
- Certificate replacement uses `create_before_destroy`.
- EMAIL validation is supported but Route53 automation is DNS-only.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.0.0 |

## Outputs

| Output | Description |
|--------|-------------|
| `certificate_arns` | Prefer validated ARN when waiter is enabled |
| `domain_validation_options` | DNS/email validation details |
| `validation_record_fqdns` | Created validation FQDNs |
| `imported_certificate_arns` | Imported certificate ARNs |
