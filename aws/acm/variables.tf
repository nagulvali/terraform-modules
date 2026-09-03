variable "region" {
  description = "AWS region where certificates will be created. Use us-east-1 for CloudFront certificates."
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix for Name tags. Pattern: {name_prefix}_{key}_{name_suffix}"
  type        = string
  default     = null
}

variable "name_suffix" {
  description = "Suffix for Name tags. Pattern: {name_prefix}_{key}_{name_suffix}"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# Certificates
# ------------------------------------------------------------------------------
variable "certificates" {
  description = "Map of ACM certificates to create, keyed by ref_key."
  type = map(object({
    domain_name                                 = string
    subject_alternative_names                   = optional(list(string), [])
    validation_method                           = optional(string, "DNS")
    key_algorithm                               = optional(string)
    certificate_transparency_logging_preference = optional(string, "ENABLED")

    options = optional(object({
      certificate_transparency_logging_preference = optional(string)
    }))

    validation_option = optional(list(object({
      domain_name       = string
      validation_domain = string
    })), [])

    create_route53_records = optional(bool, false)
    zone_id                = optional(string)
    zone_name              = optional(string)
    wait_for_validation    = optional(bool, true)
    validation_timeout     = optional(string, "45m")

    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.certificates :
      contains(["DNS", "EMAIL", "NONE"], v.validation_method)
    ])
    error_message = "validation_method must be DNS, EMAIL, or NONE."
  }

  validation {
    condition = alltrue([
      for k, v in var.certificates :
      !v.create_route53_records || v.validation_method == "DNS"
    ])
    error_message = "create_route53_records requires validation_method = DNS."
  }

  validation {
    condition = alltrue([
      for k, v in var.certificates :
      !v.create_route53_records || (v.zone_id != null) != (v.zone_name != null)
    ])
    error_message = "When create_route53_records is true, specify exactly one of zone_id or zone_name."
  }
}

# ------------------------------------------------------------------------------
# Imported Certificates
# ------------------------------------------------------------------------------
variable "imported_certificates" {
  description = "Map of certificates to import into ACM, keyed by ref_key."
  type = map(object({
    private_key       = string
    certificate_body  = string
    certificate_chain = optional(string)
    tags              = optional(map(string), {})
  }))
  default = {}
}
