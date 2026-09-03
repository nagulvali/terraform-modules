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
# KMS Keys
# ------------------------------------------------------------------------------
variable "keys" {
  description = "Map of KMS keys to create, keyed by ref_key."
  type = map(object({
    description                        = optional(string)
    key_usage                          = optional(string, "ENCRYPT_DECRYPT")
    customer_master_key_spec           = optional(string, "SYMMETRIC_DEFAULT")
    policy                             = optional(string)
    bypass_policy_lockout_safety_check = optional(bool, false)
    deletion_window_in_days            = optional(number, 30)
    is_enabled                         = optional(bool, true)
    enable_key_rotation                = optional(bool, true)
    rotation_period_in_days            = optional(number)
    multi_region                       = optional(bool, false)
    tags                               = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.keys :
      v.deletion_window_in_days >= 7 && v.deletion_window_in_days <= 30
    ])
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------
variable "aliases" {
  description = "Map of KMS aliases to create, keyed by ref_key. Alias name uses naming convention unless name is set."
  type = map(object({
    name               = optional(string)
    target_key_ref_key = optional(string)
    target_key_id      = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.aliases : (v.target_key_ref_key != null) != (v.target_key_id != null)
    ])
    error_message = "Each alias must specify exactly one of target_key_ref_key or target_key_id."
  }
}

# ------------------------------------------------------------------------------
# Grants
# ------------------------------------------------------------------------------
variable "grants" {
  description = "Map of KMS grants to create, keyed by ref_key."
  type = map(object({
    name                  = optional(string)
    key_ref_key           = optional(string)
    key_id                = optional(string)
    grantee_principal     = string
    operations            = list(string)
    retiring_principal    = optional(string)
    grant_creation_tokens = optional(list(string), [])
    retire_on_delete      = optional(bool, false)

    constraints = optional(object({
      encryption_context_equals = optional(map(string))
      encryption_context_subset = optional(map(string))
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.grants : (v.key_ref_key != null) != (v.key_id != null)
    ])
    error_message = "Each grant must specify exactly one of key_ref_key or key_id."
  }
}
