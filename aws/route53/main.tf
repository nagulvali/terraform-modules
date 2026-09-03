locals {
  zone_names = {
    for k, v in var.zones : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  health_check_names = {
    for k, v in var.health_checks : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }
}

# ==============================================================================
# Hosted Zones
# ==============================================================================
resource "aws_route53_zone" "this" {
  for_each = var.zones

  name              = each.value.name
  comment           = each.value.comment
  force_destroy     = each.value.force_destroy
  delegation_set_id = each.value.delegation_set_id

  dynamic "vpc" {
    for_each = each.value.private_zone ? each.value.vpc : []
    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = vpc.value.vpc_region
    }
  }

  tags = merge(
    { Name = local.zone_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Health Checks
# ==============================================================================
resource "aws_route53_health_check" "this" {
  for_each = var.health_checks

  type                            = each.value.type
  ip_address                      = each.value.ip_address
  fqdn                            = each.value.fqdn
  port                            = each.value.port
  resource_path                   = each.value.resource_path
  search_string                   = each.value.search_string
  request_interval                = each.value.request_interval
  failure_threshold               = each.value.failure_threshold
  measure_latency                 = each.value.measure_latency
  invert_healthcheck              = each.value.invert_healthcheck
  disabled                        = each.value.disabled
  enable_sni                      = each.value.enable_sni
  child_healthchecks              = each.value.child_healthchecks
  child_health_threshold          = each.value.child_health_threshold
  cloudwatch_alarm_name           = each.value.cloudwatch_alarm_name
  cloudwatch_alarm_region         = each.value.cloudwatch_alarm_region
  insufficient_data_health_status = each.value.insufficient_data_health_status
  regions                         = each.value.regions

  tags = merge(
    { Name = local.health_check_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Records
# ==============================================================================
resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id        = each.value.zone_ref_key != null ? aws_route53_zone.this[each.value.zone_ref_key].zone_id : each.value.zone_id
  name           = each.value.name
  type           = each.value.type
  ttl            = each.value.alias == null ? each.value.ttl : null
  records        = each.value.alias == null ? each.value.records : null
  set_identifier = each.value.set_identifier
  health_check_id = (
    each.value.health_check_ref_key != null ? aws_route53_health_check.this[each.value.health_check_ref_key].id :
    each.value.health_check_id
  )
  allow_overwrite                  = each.value.allow_overwrite
  multivalue_answer_routing_policy = each.value.multivalue_answer_routing_policy

  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = each.value.weighted_routing_policy != null ? [each.value.weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  dynamic "latency_routing_policy" {
    for_each = each.value.latency_routing_policy != null ? [each.value.latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation_routing_policy != null ? [each.value.geolocation_routing_policy] : []
    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.failover_routing_policy != null ? [each.value.failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  dynamic "cidr_routing_policy" {
    for_each = each.value.cidr_routing_policy != null ? [each.value.cidr_routing_policy] : []
    content {
      collection_id = cidr_routing_policy.value.collection_id
      location_name = cidr_routing_policy.value.location_name
    }
  }
}
