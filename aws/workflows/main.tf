locals {
  state_machine_names = {
    for k, v in var.state_machines : k => coalesce(
      v.name,
      join("_", compact([var.name_prefix, k, var.name_suffix]))
    )
  }

  activity_names = {
    for k, v in var.activities : k => coalesce(
      v.name,
      join("_", compact([var.name_prefix, k, var.name_suffix]))
    )
  }
}

# ==============================================================================
# State Machines
# ==============================================================================
resource "aws_sfn_state_machine" "this" {
  for_each = var.state_machines

  name       = local.state_machine_names[each.key]
  definition = each.value.definition
  role_arn   = each.value.role_arn
  type       = each.value.type
  publish    = each.value.publish

  dynamic "logging_configuration" {
    for_each = each.value.logging_configuration != null ? [each.value.logging_configuration] : []
    content {
      log_destination        = logging_configuration.value.log_destination
      include_execution_data = logging_configuration.value.include_execution_data
      level                  = logging_configuration.value.level
    }
  }

  dynamic "tracing_configuration" {
    for_each = each.value.tracing_configuration != null ? [each.value.tracing_configuration] : []
    content {
      enabled = tracing_configuration.value.enabled
    }
  }

  dynamic "encryption_configuration" {
    for_each = each.value.encryption_configuration != null ? [each.value.encryption_configuration] : []
    content {
      type                              = encryption_configuration.value.type
      kms_key_id                        = encryption_configuration.value.kms_key_id
      kms_data_key_reuse_period_seconds = encryption_configuration.value.kms_data_key_reuse_period_seconds
    }
  }

  tags = merge(
    { Name = local.state_machine_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Activities
# ==============================================================================
resource "aws_sfn_activity" "this" {
  for_each = var.activities

  name = local.activity_names[each.key]

  dynamic "encryption_configuration" {
    for_each = each.value.encryption_configuration != null ? [each.value.encryption_configuration] : []
    content {
      type                              = encryption_configuration.value.type
      kms_key_id                        = encryption_configuration.value.kms_key_id
      kms_data_key_reuse_period_seconds = encryption_configuration.value.kms_data_key_reuse_period_seconds
    }
  }

  tags = merge(
    { Name = local.activity_names[each.key] },
    each.value.tags,
    var.tags
  )
}
