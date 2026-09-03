# ==============================================================================
# Naming Convention
# ==============================================================================
locals {
  # Build resource name based on prefix/suffix pattern
  # Pattern: {name_prefix}_{key}_{name_suffix}
  # If prefix exists: add it, if suffix exists: add it, if neither: plain key

  # Pre-compute names for all resources (allows lookup by ref_key)
  role_names = {
    for k, v in var.roles : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  policy_names = {
    for k, v in var.policies : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  role_policy_names = {
    for k, v in var.role_policies : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }
}

# ==============================================================================
# IAM Roles
# ==============================================================================
resource "aws_iam_role" "this" {
  for_each = var.roles

  name                  = local.role_names[each.key]
  description           = each.value.description
  path                  = each.value.path
  max_session_duration  = each.value.max_session_duration
  force_detach_policies = each.value.force_detach_policies
  permissions_boundary  = each.value.permissions_boundary
  assume_role_policy    = each.value.assume_role_policy

  managed_policy_arns = each.value.managed_policy_arns

  dynamic "inline_policy" {
    for_each = each.value.inline_policies
    content {
      name   = inline_policy.key
      policy = inline_policy.value
    }
  }

  tags = merge(
    { Name = local.role_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# IAM Policies (Managed/Customer)
# ==============================================================================
resource "aws_iam_policy" "this" {
  for_each = var.policies

  name        = local.policy_names[each.key]
  description = each.value.description
  path        = each.value.path
  policy      = each.value.policy

  tags = merge(
    { Name = local.policy_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# IAM Role Policies (Inline - Standalone)
# ==============================================================================
resource "aws_iam_role_policy" "this" {
  for_each = var.role_policies

  name = local.role_policy_names[each.key]
  role = each.value.role_ref_key != null ? aws_iam_role.this[each.value.role_ref_key].name : each.value.role_name

  policy = each.value.policy
}

# ==============================================================================
# IAM Role Policy Attachments
# ==============================================================================
resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.role_policy_attachments

  role = each.value.role_ref_key != null ? aws_iam_role.this[each.value.role_ref_key].name : each.value.role_name

  policy_arn = each.value.policy_ref_key != null ? aws_iam_policy.this[each.value.policy_ref_key].arn : each.value.policy_arn
}
