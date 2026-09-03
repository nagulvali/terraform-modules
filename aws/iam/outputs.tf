# ==============================================================================
# Naming Convention
# ==============================================================================
output "name_prefix" {
  description = "Name prefix used for all resources"
  value       = var.name_prefix
}

output "name_suffix" {
  description = "Name suffix used for all resources"
  value       = var.name_suffix
}

# ==============================================================================
# IAM Roles
# ==============================================================================
output "roles" {
  description = "Map of all IAM roles created, keyed by ref_key"
  value       = aws_iam_role.this
}

output "role_names" {
  description = "Map of IAM role names (with prefix/suffix applied), keyed by ref_key"
  value       = local.role_names
}

output "role_arns" {
  description = "Map of IAM role ARNs, keyed by ref_key"
  value       = { for k, v in aws_iam_role.this : k => v.arn }
}

output "role_ids" {
  description = "Map of IAM role IDs, keyed by ref_key"
  value       = { for k, v in aws_iam_role.this : k => v.id }
}

output "role_unique_ids" {
  description = "Map of IAM role unique IDs, keyed by ref_key"
  value       = { for k, v in aws_iam_role.this : k => v.unique_id }
}

# ==============================================================================
# IAM Policies (Managed/Customer)
# ==============================================================================
output "policies" {
  description = "Map of all IAM policies created, keyed by ref_key"
  value       = aws_iam_policy.this
}

output "policy_names" {
  description = "Map of IAM policy names (with prefix/suffix applied), keyed by ref_key"
  value       = local.policy_names
}

output "policy_arns" {
  description = "Map of IAM policy ARNs, keyed by ref_key"
  value       = { for k, v in aws_iam_policy.this : k => v.arn }
}

output "policy_ids" {
  description = "Map of IAM policy IDs, keyed by ref_key"
  value       = { for k, v in aws_iam_policy.this : k => v.id }
}

# ==============================================================================
# IAM Role Policies (Inline)
# ==============================================================================
output "role_policies" {
  description = "Map of all IAM role policies (inline) created, keyed by ref_key"
  value       = aws_iam_role_policy.this
}

output "role_policy_names" {
  description = "Map of IAM role policy names (with prefix/suffix applied), keyed by ref_key"
  value       = local.role_policy_names
}

output "role_policy_ids" {
  description = "Map of IAM role policy IDs, keyed by ref_key"
  value       = { for k, v in aws_iam_role_policy.this : k => v.id }
}

# ==============================================================================
# IAM Role Policy Attachments
# ==============================================================================
output "role_policy_attachments" {
  description = "Map of all IAM role policy attachments created, keyed by ref_key"
  value       = aws_iam_role_policy_attachment.this
}
