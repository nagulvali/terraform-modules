output "name_prefix" {
  description = "Name prefix used for resources"
  value       = var.name_prefix
}

output "name_suffix" {
  description = "Name suffix used for resources"
  value       = var.name_suffix
}

output "state_machines" {
  description = "Map of all state machines created, keyed by ref_key"
  value       = aws_sfn_state_machine.this
}

output "state_machine_arns" {
  description = "Map of state machine ARNs, keyed by ref_key"
  value       = { for k, v in aws_sfn_state_machine.this : k => v.arn }
}

output "state_machine_ids" {
  description = "Map of state machine IDs, keyed by ref_key"
  value       = { for k, v in aws_sfn_state_machine.this : k => v.id }
}

output "state_machine_names" {
  description = "Map of state machine names, keyed by ref_key"
  value       = local.state_machine_names
}

output "state_machine_status" {
  description = "Map of state machine statuses, keyed by ref_key"
  value       = { for k, v in aws_sfn_state_machine.this : k => v.status }
}

output "activities" {
  description = "Map of all activities created, keyed by ref_key"
  value       = aws_sfn_activity.this
}

output "activity_arns" {
  description = "Map of activity ARNs, keyed by ref_key"
  value       = { for k, v in aws_sfn_activity.this : k => v.id }
}

output "activity_names" {
  description = "Map of activity names, keyed by ref_key"
  value       = local.activity_names
}
