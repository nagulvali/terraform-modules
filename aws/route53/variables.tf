variable "region" {
  description = "AWS region used by the module provider configuration"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all taggable resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix to prepend to resource Name tags. Pattern: {name_prefix}_{key}_{name_suffix}"
  type        = string
  default     = null
}

variable "name_suffix" {
  description = "Suffix to append to resource Name tags. Pattern: {name_prefix}_{key}_{name_suffix}"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# Hosted Zones
# ------------------------------------------------------------------------------
variable "zones" {
  description = "Map of Route53 hosted zones to create, keyed by ref_key."
  type = map(object({
    name          = string
    comment       = optional(string)
    force_destroy = optional(bool, false)
    private_zone  = optional(bool, false)
    vpc = optional(list(object({
      vpc_id     = string
      vpc_region = optional(string)
    })), [])
    delegation_set_id = optional(string)
    tags              = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.zones :
      v.private_zone == false || length(v.vpc) > 0
    ])
    error_message = "Private hosted zones must include at least one VPC association."
  }
}

# ------------------------------------------------------------------------------
# Records
# ------------------------------------------------------------------------------
variable "records" {
  description = "Map of Route53 records to create, keyed by ref_key."
  type = map(object({
    zone_ref_key                     = optional(string)
    zone_id                          = optional(string)
    name                             = string
    type                             = string
    ttl                              = optional(number)
    records                          = optional(list(string))
    set_identifier                   = optional(string)
    health_check_ref_key             = optional(string)
    health_check_id                  = optional(string)
    allow_overwrite                  = optional(bool, false)
    multivalue_answer_routing_policy = optional(bool)

    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, false)
    }))

    weighted_routing_policy = optional(object({
      weight = number
    }))

    latency_routing_policy = optional(object({
      region = string
    }))

    geolocation_routing_policy = optional(object({
      continent   = optional(string)
      country     = optional(string)
      subdivision = optional(string)
    }))

    failover_routing_policy = optional(object({
      type = string
    }))

    cidr_routing_policy = optional(object({
      collection_id = string
      location_name = string
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.records : (v.zone_ref_key != null) != (v.zone_id != null)
    ])
    error_message = "Each record must specify exactly one of zone_ref_key or zone_id."
  }

  validation {
    condition = alltrue([
      for k, v in var.records :
      (v.alias != null) != (v.records != null)
    ])
    error_message = "Each record must specify exactly one of alias or records."
  }

  validation {
    condition = alltrue([
      for k, v in var.records :
      !(v.health_check_ref_key != null && v.health_check_id != null)
    ])
    error_message = "Each record may specify at most one of health_check_ref_key or health_check_id."
  }
}

# ------------------------------------------------------------------------------
# Health Checks
# ------------------------------------------------------------------------------
variable "health_checks" {
  description = "Map of Route53 health checks to create, keyed by ref_key."
  type = map(object({
    type                            = string
    ip_address                      = optional(string)
    fqdn                            = optional(string)
    port                            = optional(number)
    resource_path                   = optional(string)
    search_string                   = optional(string)
    request_interval                = optional(number, 30)
    failure_threshold               = optional(number, 3)
    measure_latency                 = optional(bool, false)
    invert_healthcheck              = optional(bool, false)
    disabled                        = optional(bool, false)
    enable_sni                      = optional(bool)
    child_healthchecks              = optional(list(string), [])
    child_health_threshold          = optional(number)
    cloudwatch_alarm_name           = optional(string)
    cloudwatch_alarm_region         = optional(string)
    insufficient_data_health_status = optional(string)
    regions                         = optional(list(string), [])
    tags                            = optional(map(string), {})
  }))
  default = {}
}
