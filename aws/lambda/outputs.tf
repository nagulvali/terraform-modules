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
# Lambda Layers
# ==============================================================================
output "layers" {
  description = "Map of all Lambda layers created, keyed by ref_key"
  value       = aws_lambda_layer_version.this
}

output "layer_names" {
  description = "Map of layer names (with prefix/suffix applied), keyed by ref_key"
  value       = local.layer_names
}

output "layer_arns" {
  description = "Map of layer ARNs (versioned), keyed by ref_key"
  value       = { for k, v in aws_lambda_layer_version.this : k => v.arn }
}

output "layer_versions" {
  description = "Map of layer versions, keyed by ref_key"
  value       = { for k, v in aws_lambda_layer_version.this : k => v.version }
}

# ==============================================================================
# Lambda Functions
# ==============================================================================
output "functions" {
  description = "Map of all Lambda functions created, keyed by ref_key"
  value       = aws_lambda_function.this
}

output "function_names" {
  description = "Map of function names (with prefix/suffix applied), keyed by ref_key"
  value       = local.function_names
}

output "function_arns" {
  description = "Map of function ARNs, keyed by ref_key"
  value       = { for k, v in aws_lambda_function.this : k => v.arn }
}

output "function_invoke_arns" {
  description = "Map of function invoke ARNs (for API Gateway), keyed by ref_key"
  value       = { for k, v in aws_lambda_function.this : k => v.invoke_arn }
}

output "function_qualified_arns" {
  description = "Map of function qualified ARNs (with version), keyed by ref_key"
  value       = { for k, v in aws_lambda_function.this : k => v.qualified_arn }
}

output "function_versions" {
  description = "Map of function latest versions, keyed by ref_key"
  value       = { for k, v in aws_lambda_function.this : k => v.version }
}

output "function_qualified_invoke_arns" {
  description = "Map of function qualified invoke ARNs, keyed by ref_key"
  value       = { for k, v in aws_lambda_function.this : k => v.qualified_invoke_arn }
}

output "function_signing_job_arns" {
  description = "Map of function signing job ARNs, keyed by ref_key"
  value       = { for k, v in aws_lambda_function.this : k => v.signing_job_arn }
}

output "function_signing_profile_version_arns" {
  description = "Map of function signing profile version ARNs, keyed by ref_key"
  value       = { for k, v in aws_lambda_function.this : k => v.signing_profile_version_arn }
}

# ==============================================================================
# Lambda Aliases
# ==============================================================================
output "aliases" {
  description = "Map of all Lambda aliases created, keyed by ref_key"
  value       = aws_lambda_alias.this
}

output "alias_names" {
  description = "Map of alias names (with prefix/suffix applied), keyed by ref_key"
  value       = local.alias_names
}

output "alias_arns" {
  description = "Map of alias ARNs, keyed by ref_key"
  value       = { for k, v in aws_lambda_alias.this : k => v.arn }
}

output "alias_invoke_arns" {
  description = "Map of alias invoke ARNs (for API Gateway), keyed by ref_key"
  value       = { for k, v in aws_lambda_alias.this : k => v.invoke_arn }
}

# ==============================================================================
# Lambda Permissions
# ==============================================================================
output "permissions" {
  description = "Map of all Lambda permissions created, keyed by ref_key"
  value       = aws_lambda_permission.this
}

# ==============================================================================
# Lambda Function URLs
# ==============================================================================
output "function_urls" {
  description = "Map of all Lambda function URLs created, keyed by ref_key"
  value       = aws_lambda_function_url.this
}

output "function_url_endpoints" {
  description = "Map of function URL endpoints, keyed by ref_key"
  value       = { for k, v in aws_lambda_function_url.this : k => v.function_url }
}

# ==============================================================================
# Lambda Event Source Mappings
# ==============================================================================
output "event_source_mappings" {
  description = "Map of all event source mappings created, keyed by ref_key"
  value       = aws_lambda_event_source_mapping.this
}

output "event_source_mapping_uuids" {
  description = "Map of event source mapping UUIDs, keyed by ref_key"
  value       = { for k, v in aws_lambda_event_source_mapping.this : k => v.uuid }
}

output "event_source_mapping_states" {
  description = "Map of event source mapping states, keyed by ref_key"
  value       = { for k, v in aws_lambda_event_source_mapping.this : k => v.state }
}

# ==============================================================================
# CloudWatch Log Groups
# ==============================================================================
output "log_groups" {
  description = "Map of all CloudWatch log groups created, keyed by ref_key"
  value       = aws_cloudwatch_log_group.this
}

output "log_group_names" {
  description = "Map of log group names, keyed by ref_key"
  value       = local.log_group_names
}

output "log_group_arns" {
  description = "Map of log group ARNs, keyed by ref_key"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
}
