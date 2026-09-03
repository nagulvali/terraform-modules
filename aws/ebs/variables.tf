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
# EBS Volumes
# ------------------------------------------------------------------------------
variable "volumes" {
  description = "Map of EBS volumes to create, keyed by ref_key. Use snapshot_id to restore from an existing snapshot."
  type = map(object({
    availability_zone    = string
    size                 = optional(number)
    type                 = optional(string, "gp3")
    iops                 = optional(number)
    throughput           = optional(number)
    encrypted            = optional(bool, true)
    kms_key_id           = optional(string)
    snapshot_id          = optional(string)
    multi_attach_enabled = optional(bool, false)
    final_snapshot       = optional(bool, false)
    outpost_arn          = optional(string)
    tags                 = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Volume Attachments
# ------------------------------------------------------------------------------
variable "volume_attachments" {
  description = "Map of EBS volume attachments to external EC2 instances, keyed by ref_key."
  type = map(object({
    device_name                    = string
    instance_id                    = string
    volume_ref_key                 = optional(string)
    volume_id                      = optional(string)
    force_detach                   = optional(bool, false)
    skip_destroy                   = optional(bool, false)
    stop_instance_before_detaching = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.volume_attachments : (v.volume_ref_key != null) != (v.volume_id != null)
    ])
    error_message = "Each attachment must specify exactly one of volume_ref_key or volume_id."
  }
}

# ------------------------------------------------------------------------------
# Snapshots
# ------------------------------------------------------------------------------
variable "snapshots" {
  description = "Map of EBS snapshots to create, keyed by ref_key."
  type = map(object({
    volume_ref_key         = optional(string)
    volume_id              = optional(string)
    description            = optional(string)
    storage_tier           = optional(string)
    permanent_restore      = optional(bool)
    temporary_restore_days = optional(number)
    outpost_arn            = optional(string)
    tags                   = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.snapshots : (v.volume_ref_key != null) != (v.volume_id != null)
    ])
    error_message = "Each snapshot must specify exactly one of volume_ref_key or volume_id."
  }
}

# ------------------------------------------------------------------------------
# Snapshot Copies
# ------------------------------------------------------------------------------
variable "snapshot_copies" {
  description = "Map of EBS snapshot copies to create, keyed by ref_key."
  type = map(object({
    source_snapshot_ref_key = optional(string)
    source_snapshot_id      = optional(string)
    source_region           = optional(string)
    description             = optional(string)
    encrypted               = optional(bool, true)
    kms_key_id              = optional(string)
    storage_tier            = optional(string)
    permanent_restore       = optional(bool)
    temporary_restore_days  = optional(number)
    tags                    = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.snapshot_copies : (v.source_snapshot_ref_key != null) != (v.source_snapshot_id != null)
    ])
    error_message = "Each snapshot copy must specify exactly one of source_snapshot_ref_key or source_snapshot_id."
  }
}

# ------------------------------------------------------------------------------
# Default EBS Encryption
# ------------------------------------------------------------------------------
variable "encryption_by_default" {
  description = "Configure account-level default EBS encryption. Set enabled to manage the setting."
  type = object({
    enabled = bool
  })
  default = null
}

variable "default_kms_key" {
  description = "Account-level default KMS key ARN/ID/alias for EBS encryption."
  type = object({
    key_arn = string
  })
  default = null
}
