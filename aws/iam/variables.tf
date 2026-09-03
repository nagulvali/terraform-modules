variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# Naming Convention
# ------------------------------------------------------------------------------
variable "name_prefix" {
  description = "Prefix to prepend to all resource names. Pattern: {name_prefix}_{key}_{name_suffix}"
  type        = string
  default     = null
}

variable "name_suffix" {
  description = "Suffix to append to all resource names. Pattern: {name_prefix}_{key}_{name_suffix}"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# IAM Roles
# ------------------------------------------------------------------------------
variable "roles" {
  description = "Map of IAM roles to create, keyed by ref_key. Use the key to reference in role_policies and attachments."
  type = map(object({
    description           = optional(string)
    path                  = optional(string, "/")
    max_session_duration  = optional(number, 3600)
    force_detach_policies = optional(bool, false)
    permissions_boundary  = optional(string)

    assume_role_policy = string

    inline_policies = optional(map(string), {})

    managed_policy_arns = optional(list(string), [])

    tags = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# IAM Policies (Managed/Customer)
# ------------------------------------------------------------------------------
variable "policies" {
  description = "Map of IAM managed policies to create, keyed by ref_key. Use the key as policy_ref_key in attachments."
  type = map(object({
    description = optional(string)
    path        = optional(string, "/")
    policy      = string
    tags        = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# IAM Role Policies (Inline)
# ------------------------------------------------------------------------------
variable "role_policies" {
  description = "Map of inline policies to attach to roles, keyed by ref_key. Use role_ref_key to reference a role created in this module."
  type = map(object({
    role_ref_key = optional(string)
    role_name    = optional(string)
    policy       = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.role_policies : (v.role_ref_key != null) != (v.role_name != null)
    ])
    error_message = "Each role policy must specify exactly one of role_ref_key or role_name."
  }
}

# ------------------------------------------------------------------------------
# IAM Role Policy Attachments
# ------------------------------------------------------------------------------
variable "role_policy_attachments" {
  description = "Map of policy attachments to roles, keyed by ref_key. Use role_ref_key and policy_ref_key to reference resources created in this module."
  type = map(object({
    role_ref_key   = optional(string)
    role_name      = optional(string)
    policy_ref_key = optional(string)
    policy_arn     = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.role_policy_attachments : (v.role_ref_key != null) != (v.role_name != null)
    ])
    error_message = "Each attachment must specify exactly one of role_ref_key or role_name."
  }

  validation {
    condition = alltrue([
      for k, v in var.role_policy_attachments : (v.policy_ref_key != null) != (v.policy_arn != null)
    ])
    error_message = "Each attachment must specify exactly one of policy_ref_key or policy_arn."
  }
}
