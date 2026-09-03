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
# Key Pairs
# ------------------------------------------------------------------------------
variable "key_pairs" {
  description = "Map of key pairs to create, keyed by ref_key. Set create_private_key=true to generate new key pair."
  type = map(object({
    public_key         = optional(string)
    create_private_key = optional(bool, false)
    tags               = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.key_pairs : (v.public_key != null) != (v.create_private_key == true)
    ])
    error_message = "Each key pair must specify exactly one of public_key or create_private_key=true."
  }
}

# ------------------------------------------------------------------------------
# Security Groups
# ------------------------------------------------------------------------------
variable "security_groups" {
  description = "Map of security groups to create, keyed by ref_key. Use vpc_ref_key to reference VPC from networking module output."
  type = map(object({
    description = optional(string, "Managed by Terraform")
    vpc_id      = string

    ingress_rules = optional(list(object({
      description      = optional(string)
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      security_groups  = optional(list(string), [])
      self             = optional(bool, false)
    })), [])

    egress_rules = optional(list(object({
      description      = optional(string)
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      security_groups  = optional(list(string), [])
      self             = optional(bool, false)
    })), [])

    tags = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Instance Profiles
# ------------------------------------------------------------------------------
variable "instance_profiles" {
  description = "Map of instance profiles to create, keyed by ref_key. Use role_name to reference IAM role."
  type = map(object({
    role_name = string
    path      = optional(string, "/")
    tags      = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Launch Templates
# ------------------------------------------------------------------------------
variable "launch_templates" {
  description = "Map of launch templates to create, keyed by ref_key."
  type = map(object({
    description            = optional(string)
    default_version        = optional(number)
    update_default_version = optional(bool, true)

    # Instance configuration
    image_id         = optional(string)
    instance_type    = optional(string)
    key_pair_ref_key = optional(string)
    key_name         = optional(string)
    user_data        = optional(string)
    user_data_base64 = optional(string)

    # Network
    vpc_security_group_ids  = optional(list(string), [])
    security_group_ref_keys = optional(list(string), [])

    # IAM
    instance_profile_ref_key = optional(string)
    instance_profile_name    = optional(string)
    instance_profile_arn     = optional(string)

    # Storage
    ebs_optimized = optional(bool)
    block_device_mappings = optional(list(object({
      device_name  = string
      no_device    = optional(string)
      virtual_name = optional(string)
      ebs = optional(object({
        delete_on_termination = optional(bool, true)
        encrypted             = optional(bool, true)
        iops                  = optional(number)
        kms_key_id            = optional(string)
        snapshot_id           = optional(string)
        throughput            = optional(number)
        volume_size           = optional(number)
        volume_type           = optional(string, "gp3")
      }))
    })), [])

    # Metadata
    metadata_options = optional(object({
      http_endpoint               = optional(string, "enabled")
      http_tokens                 = optional(string, "required")
      http_put_response_hop_limit = optional(number, 1)
      instance_metadata_tags      = optional(string, "disabled")
    }))

    # Monitoring
    monitoring_enabled = optional(bool, false)

    # Placement
    placement = optional(object({
      availability_zone = optional(string)
      tenancy           = optional(string)
    }))

    tags = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# EC2 Instances
# ------------------------------------------------------------------------------
variable "instances" {
  description = "Map of EC2 instances to create, keyed by ref_key."
  type = map(object({
    # Launch configuration (use either launch_template or direct config)
    launch_template_ref_key = optional(string)
    launch_template_id      = optional(string)
    launch_template_version = optional(string, "$Latest")

    # Direct instance configuration (when not using launch template)
    ami                         = optional(string)
    instance_type               = optional(string)
    key_pair_ref_key            = optional(string)
    key_name                    = optional(string)
    user_data                   = optional(string)
    user_data_base64            = optional(string)
    user_data_replace_on_change = optional(bool, false)

    # Network
    subnet_id                   = string
    vpc_security_group_ids      = optional(list(string), [])
    security_group_ref_keys     = optional(list(string), [])
    associate_public_ip_address = optional(bool)
    private_ip                  = optional(string)
    secondary_private_ips       = optional(list(string), [])
    source_dest_check           = optional(bool, true)

    # IAM
    instance_profile_ref_key = optional(string)
    iam_instance_profile     = optional(string)

    # Storage
    ebs_optimized = optional(bool)
    root_block_device = optional(object({
      delete_on_termination = optional(bool, true)
      encrypted             = optional(bool, true)
      iops                  = optional(number)
      kms_key_id            = optional(string)
      throughput            = optional(number)
      volume_size           = optional(number)
      volume_type           = optional(string, "gp3")
    }))

    # Metadata
    metadata_options = optional(object({
      http_endpoint               = optional(string, "enabled")
      http_tokens                 = optional(string, "required")
      http_put_response_hop_limit = optional(number, 1)
      instance_metadata_tags      = optional(string, "disabled")
    }))

    # Monitoring
    monitoring = optional(bool, false)

    # Lifecycle
    disable_api_termination = optional(bool, false)
    disable_api_stop        = optional(bool, false)

    # Placement
    availability_zone = optional(string)
    placement_group   = optional(string)
    tenancy           = optional(string)
    host_id           = optional(string)

    tags        = optional(map(string), {})
    volume_tags = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# EBS Volumes
# ------------------------------------------------------------------------------
variable "ebs_volumes" {
  description = "Map of EBS volumes to create, keyed by ref_key."
  type = map(object({
    availability_zone = string
    size              = optional(number)
    type              = optional(string, "gp3")
    iops              = optional(number)
    throughput        = optional(number)
    encrypted         = optional(bool, true)
    kms_key_id        = optional(string)
    snapshot_id       = optional(string)
    final_snapshot    = optional(bool, false)
    tags              = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# EBS Volume Attachments
# ------------------------------------------------------------------------------
variable "ebs_volume_attachments" {
  description = "Map of EBS volume attachments, keyed by ref_key."
  type = map(object({
    device_name                    = string
    instance_ref_key               = optional(string)
    instance_id                    = optional(string)
    volume_ref_key                 = optional(string)
    volume_id                      = optional(string)
    force_detach                   = optional(bool, false)
    skip_destroy                   = optional(bool, false)
    stop_instance_before_detaching = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.ebs_volume_attachments : (v.instance_ref_key != null) != (v.instance_id != null)
    ])
    error_message = "Each attachment must specify exactly one of instance_ref_key or instance_id."
  }

  validation {
    condition = alltrue([
      for k, v in var.ebs_volume_attachments : (v.volume_ref_key != null) != (v.volume_id != null)
    ])
    error_message = "Each attachment must specify exactly one of volume_ref_key or volume_id."
  }
}
