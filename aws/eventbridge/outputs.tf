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
# Event Buses
# ==============================================================================
output "buses" {
  description = "Map of all event buses created, keyed by ref_key"
  value       = aws_cloudwatch_event_bus.this
}

output "bus_names" {
  description = "Map of event bus names (with prefix/suffix applied), keyed by ref_key"
  value       = local.bus_names
}

output "bus_arns" {
  description = "Map of event bus ARNs, keyed by ref_key"
  value       = { for k, v in aws_cloudwatch_event_bus.this : k => v.arn }
}

# ==============================================================================
# Event Bus Permissions
# ==============================================================================
output "bus_permissions" {
  description = "Map of all event bus permissions created, keyed by ref_key"
  value       = aws_cloudwatch_event_permission.this
}

# ==============================================================================
# Event Rules
# ==============================================================================
output "rules" {
  description = "Map of all event rules created, keyed by ref_key"
  value       = aws_cloudwatch_event_rule.this
}

output "rule_names" {
  description = "Map of event rule names (with prefix/suffix applied), keyed by ref_key"
  value       = local.rule_names
}

output "rule_arns" {
  description = "Map of event rule ARNs, keyed by ref_key"
  value       = { for k, v in aws_cloudwatch_event_rule.this : k => v.arn }
}

output "rule_ids" {
  description = "Map of event rule IDs, keyed by ref_key"
  value       = { for k, v in aws_cloudwatch_event_rule.this : k => v.id }
}

# ==============================================================================
# Event Targets
# ==============================================================================
output "targets" {
  description = "Map of all event targets created, keyed by ref_key"
  value       = aws_cloudwatch_event_target.this
}

# ==============================================================================
# Event Archives
# ==============================================================================
output "archives" {
  description = "Map of all event archives created, keyed by ref_key"
  value       = aws_cloudwatch_event_archive.this
}

output "archive_names" {
  description = "Map of event archive names (with prefix/suffix applied), keyed by ref_key"
  value       = local.archive_names
}

output "archive_arns" {
  description = "Map of event archive ARNs, keyed by ref_key"
  value       = { for k, v in aws_cloudwatch_event_archive.this : k => v.arn }
}

# ==============================================================================
# Connections
# ==============================================================================
output "connections" {
  description = "Map of all connections created, keyed by ref_key"
  value       = aws_cloudwatch_event_connection.this
}

output "connection_names" {
  description = "Map of connection names (with prefix/suffix applied), keyed by ref_key"
  value       = local.connection_names
}

output "connection_arns" {
  description = "Map of connection ARNs, keyed by ref_key"
  value       = { for k, v in aws_cloudwatch_event_connection.this : k => v.arn }
}

output "connection_secret_arns" {
  description = "Map of connection secret ARNs, keyed by ref_key"
  value       = { for k, v in aws_cloudwatch_event_connection.this : k => v.secret_arn }
}

# ==============================================================================
# API Destinations
# ==============================================================================
output "api_destinations" {
  description = "Map of all API destinations created, keyed by ref_key"
  value       = aws_cloudwatch_event_api_destination.this
}

output "api_destination_names" {
  description = "Map of API destination names (with prefix/suffix applied), keyed by ref_key"
  value       = local.api_destination_names
}

output "api_destination_arns" {
  description = "Map of API destination ARNs, keyed by ref_key"
  value       = { for k, v in aws_cloudwatch_event_api_destination.this : k => v.arn }
}

# ==============================================================================
# EventBridge Scheduler - Schedule Groups
# ==============================================================================
output "schedule_groups" {
  description = "Map of all schedule groups created, keyed by ref_key"
  value       = aws_scheduler_schedule_group.this
}

output "schedule_group_names" {
  description = "Map of schedule group names (with prefix/suffix applied), keyed by ref_key"
  value       = local.schedule_group_names
}

output "schedule_group_arns" {
  description = "Map of schedule group ARNs, keyed by ref_key"
  value       = { for k, v in aws_scheduler_schedule_group.this : k => v.arn }
}

# ==============================================================================
# EventBridge Scheduler - Schedules
# ==============================================================================
output "schedules" {
  description = "Map of all schedules created, keyed by ref_key"
  value       = aws_scheduler_schedule.this
}

output "schedule_names" {
  description = "Map of schedule names (with prefix/suffix applied), keyed by ref_key"
  value       = local.schedule_names
}

output "schedule_arns" {
  description = "Map of schedule ARNs, keyed by ref_key"
  value       = { for k, v in aws_scheduler_schedule.this : k => v.arn }
}
