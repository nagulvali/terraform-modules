output "name_prefix" {
  description = "Name prefix used for Name tags"
  value       = var.name_prefix
}

output "name_suffix" {
  description = "Name suffix used for Name tags"
  value       = var.name_suffix
}

output "zones" {
  description = "Map of all hosted zones created, keyed by ref_key"
  value       = aws_route53_zone.this
}

output "zone_ids" {
  description = "Map of hosted zone IDs, keyed by ref_key"
  value       = { for k, v in aws_route53_zone.this : k => v.zone_id }
}

output "zone_arns" {
  description = "Map of hosted zone ARNs, keyed by ref_key"
  value       = { for k, v in aws_route53_zone.this : k => v.arn }
}

output "zone_names" {
  description = "Map of hosted zone Name tags, keyed by ref_key"
  value       = local.zone_names
}

output "name_servers" {
  description = "Map of hosted zone name servers, keyed by ref_key"
  value       = { for k, v in aws_route53_zone.this : k => v.name_servers }
}

output "records" {
  description = "Map of all records created, keyed by ref_key"
  value       = aws_route53_record.this
}

output "record_fqdns" {
  description = "Map of record FQDNs, keyed by ref_key"
  value       = { for k, v in aws_route53_record.this : k => v.fqdn }
}

output "record_names" {
  description = "Map of record names, keyed by ref_key"
  value       = { for k, v in aws_route53_record.this : k => v.name }
}

output "health_checks" {
  description = "Map of all health checks created, keyed by ref_key"
  value       = aws_route53_health_check.this
}

output "health_check_ids" {
  description = "Map of health check IDs, keyed by ref_key"
  value       = { for k, v in aws_route53_health_check.this : k => v.id }
}

output "health_check_arns" {
  description = "Map of health check ARNs, keyed by ref_key"
  value       = { for k, v in aws_route53_health_check.this : k => v.arn }
}

output "health_check_names" {
  description = "Map of health check Name tags, keyed by ref_key"
  value       = local.health_check_names
}
