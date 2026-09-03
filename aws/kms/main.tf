locals {
  key_names = {
    for k, v in var.keys : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  alias_names = {
    for k, v in var.aliases : k => coalesce(
      v.name,
      "alias/${join("-", compact([var.name_prefix, k, var.name_suffix]))}"
    )
  }

  grant_names = {
    for k, v in var.grants : k => coalesce(
      v.name,
      join("_", compact([var.name_prefix, k, var.name_suffix]))
    )
  }
}

# ==============================================================================
# KMS Keys
# ==============================================================================
resource "aws_kms_key" "this" {
  for_each = var.keys

  description                        = coalesce(each.value.description, "KMS key ${local.key_names[each.key]}")
  key_usage                          = each.value.key_usage
  customer_master_key_spec           = each.value.customer_master_key_spec
  policy                             = each.value.policy
  bypass_policy_lockout_safety_check = each.value.bypass_policy_lockout_safety_check
  deletion_window_in_days            = each.value.deletion_window_in_days
  is_enabled                         = each.value.is_enabled
  enable_key_rotation                = each.value.enable_key_rotation
  rotation_period_in_days            = each.value.rotation_period_in_days
  multi_region                       = each.value.multi_region

  tags = merge(
    { Name = local.key_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Aliases
# ==============================================================================
resource "aws_kms_alias" "this" {
  for_each = var.aliases

  name          = local.alias_names[each.key]
  target_key_id = each.value.target_key_ref_key != null ? aws_kms_key.this[each.value.target_key_ref_key].key_id : each.value.target_key_id
}

# ==============================================================================
# Grants
# ==============================================================================
resource "aws_kms_grant" "this" {
  for_each = var.grants

  name                  = local.grant_names[each.key]
  key_id                = each.value.key_ref_key != null ? aws_kms_key.this[each.value.key_ref_key].key_id : each.value.key_id
  grantee_principal     = each.value.grantee_principal
  operations            = each.value.operations
  retiring_principal    = each.value.retiring_principal
  grant_creation_tokens = each.value.grant_creation_tokens
  retire_on_delete      = each.value.retire_on_delete

  dynamic "constraints" {
    for_each = each.value.constraints != null ? [each.value.constraints] : []
    content {
      encryption_context_equals = constraints.value.encryption_context_equals
      encryption_context_subset = constraints.value.encryption_context_subset
    }
  }
}
