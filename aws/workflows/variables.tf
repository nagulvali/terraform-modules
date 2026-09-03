variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix to prepend to resource names. Pattern: {name_prefix}_{key}_{name_suffix}"
  type        = string
  default     = null
}

variable "name_suffix" {
  description = "Suffix to append to resource names. Pattern: {name_prefix}_{key}_{name_suffix}"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# State Machines
# ------------------------------------------------------------------------------
variable "state_machines" {
  description = "Map of Step Functions state machines to create, keyed by ref_key."
  type = map(object({
    name       = optional(string)
    definition = string
    role_arn   = string
    type       = optional(string, "STANDARD")

    logging_configuration = optional(object({
      log_destination        = optional(string)
      include_execution_data = optional(bool, false)
      level                  = optional(string, "OFF")
    }))

    tracing_configuration = optional(object({
      enabled = optional(bool, false)
    }))

    publish = optional(bool, false)
    encryption_configuration = optional(object({
      type                              = string
      kms_key_id                        = optional(string)
      kms_data_key_reuse_period_seconds = optional(number)
    }))

    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.state_machines :
      contains(["STANDARD", "EXPRESS"], v.type)
    ])
    error_message = "state machine type must be STANDARD or EXPRESS."
  }
}

# ------------------------------------------------------------------------------
# Activities
# ------------------------------------------------------------------------------
variable "activities" {
  description = "Map of Step Functions activities to create, keyed by ref_key."
  type = map(object({
    name = optional(string)
    encryption_configuration = optional(object({
      type                              = string
      kms_key_id                        = optional(string)
      kms_data_key_reuse_period_seconds = optional(number)
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}
