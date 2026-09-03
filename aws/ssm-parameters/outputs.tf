output "name_prefix" {
  description = "Name prefix used for parameters"
  value       = var.name_prefix
}

output "name_suffix" {
  description = "Name suffix used for parameters"
  value       = var.name_suffix
}

output "parameters" {
  description = "Map of all SSM parameters created, keyed by ref_key"
  value       = aws_ssm_parameter.this
  sensitive   = true
}

output "parameter_names" {
  description = "Map of SSM parameter names, keyed by ref_key"
  value       = local.parameter_names
}

output "parameter_arns" {
  description = "Map of SSM parameter ARNs, keyed by ref_key"
  value       = { for k, v in aws_ssm_parameter.this : k => v.arn }
}

output "parameter_versions" {
  description = "Map of SSM parameter versions, keyed by ref_key"
  value       = { for k, v in aws_ssm_parameter.this : k => v.version }
}

output "parameter_types" {
  description = "Map of SSM parameter types, keyed by ref_key"
  value       = { for k, v in aws_ssm_parameter.this : k => v.type }
}
