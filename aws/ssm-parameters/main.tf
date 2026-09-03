locals {
  parameter_names = {
    for k, v in var.parameters : k => coalesce(
      v.name,
      join("/", compact(["", var.name_prefix, k, var.name_suffix]))
    )
  }
}

resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name            = local.parameter_names[each.key]
  description     = each.value.description
  type            = each.value.type
  value           = each.value.value
  insecure_value  = each.value.insecure_value
  tier            = each.value.tier
  key_id          = each.value.key_id
  allowed_pattern = each.value.allowed_pattern
  data_type       = each.value.data_type
  overwrite       = each.value.overwrite

  tags = merge(
    { Name = local.parameter_names[each.key] },
    each.value.tags,
    var.tags
  )
}
