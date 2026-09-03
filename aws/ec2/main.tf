# ==============================================================================
# Naming Convention
# ==============================================================================
locals {
  # Build resource name based on prefix/suffix pattern
  # Pattern: {name_prefix}_{key}_{name_suffix}
  # If prefix exists: add it, if suffix exists: add it, if neither: plain key

  key_pair_names = {
    for k, v in var.key_pairs : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  security_group_names = {
    for k, v in var.security_groups : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  instance_profile_names = {
    for k, v in var.instance_profiles : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  launch_template_names = {
    for k, v in var.launch_templates : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  instance_names = {
    for k, v in var.instances : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  ebs_volume_names = {
    for k, v in var.ebs_volumes : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }
}

# ==============================================================================
# TLS Private Key (for key pairs with create_private_key=true)
# ==============================================================================
resource "tls_private_key" "this" {
  for_each = {
    for k, v in var.key_pairs : k => v if v.create_private_key == true
  }

  algorithm = "RSA"
  rsa_bits  = 4096
}

# ==============================================================================
# Key Pairs
# ==============================================================================
resource "aws_key_pair" "this" {
  for_each = var.key_pairs

  key_name   = local.key_pair_names[each.key]
  public_key = each.value.create_private_key ? tls_private_key.this[each.key].public_key_openssh : each.value.public_key

  tags = merge(
    { Name = local.key_pair_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Security Groups
# ==============================================================================
resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = local.security_group_names[each.key]
  description = each.value.description
  vpc_id      = each.value.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      security_groups  = ingress.value.security_groups
      self             = ingress.value.self
    }
  }

  dynamic "egress" {
    for_each = each.value.egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      security_groups  = egress.value.security_groups
      self             = egress.value.self
    }
  }

  tags = merge(
    { Name = local.security_group_names[each.key] },
    each.value.tags,
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# Instance Profiles
# ==============================================================================
resource "aws_iam_instance_profile" "this" {
  for_each = var.instance_profiles

  name = local.instance_profile_names[each.key]
  path = each.value.path
  role = each.value.role_name

  tags = merge(
    { Name = local.instance_profile_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Launch Templates
# ==============================================================================
resource "aws_launch_template" "this" {
  for_each = var.launch_templates

  name                   = local.launch_template_names[each.key]
  description            = each.value.description
  default_version        = each.value.default_version
  update_default_version = each.value.update_default_version

  image_id      = each.value.image_id
  instance_type = each.value.instance_type
  key_name      = each.value.key_pair_ref_key != null ? aws_key_pair.this[each.value.key_pair_ref_key].key_name : each.value.key_name
  user_data = each.value.user_data_base64 != null ? each.value.user_data_base64 : (
    each.value.user_data != null ? base64encode(each.value.user_data) : null
  )

  ebs_optimized = each.value.ebs_optimized

  vpc_security_group_ids = concat(
    each.value.vpc_security_group_ids,
    [for ref_key in each.value.security_group_ref_keys : aws_security_group.this[ref_key].id]
  )

  dynamic "iam_instance_profile" {
    for_each = each.value.instance_profile_ref_key != null || each.value.instance_profile_name != null || each.value.instance_profile_arn != null ? [1] : []
    content {
      name = each.value.instance_profile_ref_key != null ? aws_iam_instance_profile.this[each.value.instance_profile_ref_key].name : each.value.instance_profile_name
      arn  = each.value.instance_profile_arn
    }
  }

  dynamic "block_device_mappings" {
    for_each = each.value.block_device_mappings
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = block_device_mappings.value.no_device
      virtual_name = block_device_mappings.value.virtual_name

      dynamic "ebs" {
        for_each = block_device_mappings.value.ebs != null ? [block_device_mappings.value.ebs] : []
        content {
          delete_on_termination = ebs.value.delete_on_termination
          encrypted             = ebs.value.encrypted
          iops                  = ebs.value.iops
          kms_key_id            = ebs.value.kms_key_id
          snapshot_id           = ebs.value.snapshot_id
          throughput            = ebs.value.throughput
          volume_size           = ebs.value.volume_size
          volume_type           = ebs.value.volume_type
        }
      }
    }
  }

  dynamic "metadata_options" {
    for_each = each.value.metadata_options != null ? [each.value.metadata_options] : []
    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_tokens                 = metadata_options.value.http_tokens
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      instance_metadata_tags      = metadata_options.value.instance_metadata_tags
    }
  }

  dynamic "monitoring" {
    for_each = each.value.monitoring_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "placement" {
    for_each = each.value.placement != null ? [each.value.placement] : []
    content {
      availability_zone = placement.value.availability_zone
      tenancy           = placement.value.tenancy
    }
  }

  tags = merge(
    { Name = local.launch_template_names[each.key] },
    each.value.tags,
    var.tags
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      { Name = local.launch_template_names[each.key] },
      each.value.tags,
      var.tags
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      { Name = local.launch_template_names[each.key] },
      each.value.tags,
      var.tags
    )
  }
}

# ==============================================================================
# EC2 Instances
# ==============================================================================
resource "aws_instance" "this" {
  for_each = var.instances

  # Launch template (if specified)
  dynamic "launch_template" {
    for_each = each.value.launch_template_ref_key != null || each.value.launch_template_id != null ? [1] : []
    content {
      id      = each.value.launch_template_ref_key != null ? aws_launch_template.this[each.value.launch_template_ref_key].id : each.value.launch_template_id
      version = each.value.launch_template_version
    }
  }

  # Direct configuration (when not using launch template)
  ami           = each.value.launch_template_ref_key == null && each.value.launch_template_id == null ? each.value.ami : null
  instance_type = each.value.launch_template_ref_key == null && each.value.launch_template_id == null ? each.value.instance_type : null
  key_name = each.value.launch_template_ref_key == null && each.value.launch_template_id == null ? (
    each.value.key_pair_ref_key != null ? aws_key_pair.this[each.value.key_pair_ref_key].key_name : each.value.key_name
  ) : null

  user_data                   = each.value.user_data
  user_data_base64            = each.value.user_data_base64
  user_data_replace_on_change = each.value.user_data_replace_on_change

  # Network
  subnet_id                   = each.value.subnet_id
  associate_public_ip_address = each.value.associate_public_ip_address
  private_ip                  = each.value.private_ip
  secondary_private_ips       = each.value.secondary_private_ips
  source_dest_check           = each.value.source_dest_check

  vpc_security_group_ids = each.value.launch_template_ref_key == null && each.value.launch_template_id == null ? concat(
    each.value.vpc_security_group_ids,
    [for ref_key in each.value.security_group_ref_keys : aws_security_group.this[ref_key].id]
  ) : null

  # IAM
  iam_instance_profile = each.value.launch_template_ref_key == null && each.value.launch_template_id == null ? (
    each.value.instance_profile_ref_key != null ? aws_iam_instance_profile.this[each.value.instance_profile_ref_key].name : each.value.iam_instance_profile
  ) : null

  # Storage
  ebs_optimized = each.value.ebs_optimized

  dynamic "root_block_device" {
    for_each = each.value.root_block_device != null ? [each.value.root_block_device] : []
    content {
      delete_on_termination = root_block_device.value.delete_on_termination
      encrypted             = root_block_device.value.encrypted
      iops                  = root_block_device.value.iops
      kms_key_id            = root_block_device.value.kms_key_id
      throughput            = root_block_device.value.throughput
      volume_size           = root_block_device.value.volume_size
      volume_type           = root_block_device.value.volume_type
    }
  }

  # Metadata
  dynamic "metadata_options" {
    for_each = each.value.metadata_options != null ? [each.value.metadata_options] : []
    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_tokens                 = metadata_options.value.http_tokens
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      instance_metadata_tags      = metadata_options.value.instance_metadata_tags
    }
  }

  # Monitoring
  monitoring = each.value.monitoring

  # Lifecycle
  disable_api_termination = each.value.disable_api_termination
  disable_api_stop        = each.value.disable_api_stop

  # Placement
  availability_zone = each.value.availability_zone
  placement_group   = each.value.placement_group
  tenancy           = each.value.tenancy
  host_id           = each.value.host_id

  tags = merge(
    { Name = local.instance_names[each.key] },
    each.value.tags,
    var.tags
  )

  volume_tags = merge(
    { Name = local.instance_names[each.key] },
    each.value.volume_tags,
    var.tags
  )
}

# ==============================================================================
# EBS Volumes
# ==============================================================================
resource "aws_ebs_volume" "this" {
  for_each = var.ebs_volumes

  availability_zone = each.value.availability_zone
  size              = each.value.size
  type              = each.value.type
  iops              = each.value.iops
  throughput        = each.value.throughput
  encrypted         = each.value.encrypted
  kms_key_id        = each.value.kms_key_id
  snapshot_id       = each.value.snapshot_id
  final_snapshot    = each.value.final_snapshot

  tags = merge(
    { Name = local.ebs_volume_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# EBS Volume Attachments
# ==============================================================================
resource "aws_volume_attachment" "this" {
  for_each = var.ebs_volume_attachments

  device_name = each.value.device_name
  instance_id = each.value.instance_ref_key != null ? aws_instance.this[each.value.instance_ref_key].id : each.value.instance_id
  volume_id   = each.value.volume_ref_key != null ? aws_ebs_volume.this[each.value.volume_ref_key].id : each.value.volume_id

  force_detach                   = each.value.force_detach
  skip_destroy                   = each.value.skip_destroy
  stop_instance_before_detaching = each.value.stop_instance_before_detaching
}
