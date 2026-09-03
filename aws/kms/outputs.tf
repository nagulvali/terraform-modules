output "name_prefix" {
  description = "Name prefix used for resources"
  value       = var.name_prefix
}

output "name_suffix" {
  description = "Name suffix used for resources"
  value       = var.name_suffix
}

output "keys" {
  description = "Map of all KMS keys created, keyed by ref_key"
  value       = aws_kms_key.this
}

output "key_ids" {
  description = "Map of KMS key IDs, keyed by ref_key"
  value       = { for k, v in aws_kms_key.this : k => v.key_id }
}

output "key_arns" {
  description = "Map of KMS key ARNs, keyed by ref_key"
  value       = { for k, v in aws_kms_key.this : k => v.arn }
}

output "key_names" {
  description = "Map of KMS key Name tags, keyed by ref_key"
  value       = local.key_names
}

output "aliases" {
  description = "Map of all KMS aliases created, keyed by ref_key"
  value       = aws_kms_alias.this
}

output "alias_names" {
  description = "Map of KMS alias names, keyed by ref_key"
  value       = local.alias_names
}

output "alias_arns" {
  description = "Map of KMS alias ARNs, keyed by ref_key"
  value       = { for k, v in aws_kms_alias.this : k => v.arn }
}

output "alias_target_key_arns" {
  description = "Map of alias target key ARNs, keyed by ref_key"
  value       = { for k, v in aws_kms_alias.this : k => v.target_key_arn }
}

output "grants" {
  description = "Map of all KMS grants created, keyed by ref_key"
  value       = aws_kms_grant.this
}

output "grant_ids" {
  description = "Map of KMS grant IDs, keyed by ref_key"
  value       = { for k, v in aws_kms_grant.this : k => v.grant_id }
}

output "grant_tokens" {
  description = "Map of KMS grant tokens, keyed by ref_key"
  value       = { for k, v in aws_kms_grant.this : k => v.grant_token }
  sensitive   = true
}
