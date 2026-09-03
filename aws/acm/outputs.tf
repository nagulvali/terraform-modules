output "name_prefix" {
  description = "Name prefix used for Name tags"
  value       = var.name_prefix
}

output "name_suffix" {
  description = "Name suffix used for Name tags"
  value       = var.name_suffix
}

output "certificates" {
  description = "Map of requested ACM certificates, keyed by ref_key"
  value       = aws_acm_certificate.this
}

output "certificate_arns" {
  description = "Map of ACM certificate ARNs, keyed by ref_key. Uses validated ARN when validation is waited on."
  value = {
    for k, v in aws_acm_certificate.this :
    k => try(aws_acm_certificate_validation.this[k].certificate_arn, v.arn)
  }
}

output "certificate_ids" {
  description = "Map of ACM certificate IDs, keyed by ref_key"
  value       = { for k, v in aws_acm_certificate.this : k => v.id }
}

output "certificate_names" {
  description = "Map of certificate Name tags, keyed by ref_key"
  value       = local.certificate_names
}

output "certificate_statuses" {
  description = "Map of ACM certificate statuses, keyed by ref_key"
  value       = { for k, v in aws_acm_certificate.this : k => v.status }
}

output "domain_validation_options" {
  description = "Map of domain validation options, keyed by ref_key"
  value       = { for k, v in aws_acm_certificate.this : k => v.domain_validation_options }
}

output "validation_record_fqdns" {
  description = "Map of created validation record FQDNs grouped by certificate ref_key"
  value = {
    for cert_key in keys(var.certificates) : cert_key => [
      for record_key, record in local.validation_records :
      aws_route53_record.validation[record_key].fqdn if record.cert_key == cert_key
    ]
  }
}

output "imported_certificates" {
  description = "Map of imported ACM certificates, keyed by ref_key"
  value       = aws_acm_certificate.imported
  sensitive   = true
}

output "imported_certificate_arns" {
  description = "Map of imported ACM certificate ARNs, keyed by ref_key"
  value       = { for k, v in aws_acm_certificate.imported : k => v.arn }
}

output "imported_certificate_names" {
  description = "Map of imported certificate Name tags, keyed by ref_key"
  value       = local.imported_certificate_names
}
