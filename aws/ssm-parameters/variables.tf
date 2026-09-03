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
  description = "Prefix prepended to parameter names when name is omitted. Pattern: /{name_prefix}/{key}/{name_suffix}"
  type        = string
  default     = null
}

variable "name_suffix" {
  description = "Suffix appended to parameter names when name is omitted"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------
variable "parameters" {
  description = "Map of SSM parameters to create, keyed by ref_key."
  type = map(object({
    name            = optional(string)
    description     = optional(string)
    type            = optional(string, "SecureString")
    value           = optional(string)
    insecure_value  = optional(string)
    tier            = optional(string, "Standard")
    key_id          = optional(string)
    allowed_pattern = optional(string)
    data_type       = optional(string)
    overwrite       = optional(bool, false)
    tags            = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.parameters :
      contains(["String", "StringList", "SecureString"], v.type)
    ])
    error_message = "parameter type must be String, StringList, or SecureString."
  }

  validation {
    condition = alltrue([
      for k, v in var.parameters :
      (v.value != null) != (v.insecure_value != null)
    ])
    error_message = "Each parameter must specify exactly one of value or insecure_value."
  }
}
