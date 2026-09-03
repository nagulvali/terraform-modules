# ==============================================================================
# Naming Convention
# ==============================================================================
locals {
  volume_names = {
    for k, v in var.volumes : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  snapshot_names = {
    for k, v in var.snapshots : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  snapshot_copy_names = {
    for k, v in var.snapshot_copies : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }
}

# ==============================================================================
# Default EBS Encryption
# ==============================================================================
resource "aws_ebs_encryption_by_default" "this" {
  count = var.encryption_by_default != null ? 1 : 0

  enabled = var.encryption_by_default.enabled
}

resource "aws_ebs_default_kms_key" "this" {
  count = var.default_kms_key != null ? 1 : 0

  key_arn = var.default_kms_key.key_arn
}

# ==============================================================================
# Snapshots
# ==============================================================================
resource "aws_ebs_snapshot" "this" {
  for_each = var.snapshots

  volume_id = each.value.volume_ref_key != null ? aws_ebs_volume.this[each.value.volume_ref_key].id : each.value.volume_id

  description            = each.value.description
  storage_tier           = each.value.storage_tier
  permanent_restore      = each.value.permanent_restore
  temporary_restore_days = each.value.temporary_restore_days
  outpost_arn            = each.value.outpost_arn

  tags = merge(
    { Name = local.snapshot_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Snapshot Copies
# ==============================================================================
resource "aws_ebs_snapshot_copy" "this" {
  for_each = var.snapshot_copies

  source_snapshot_id = each.value.source_snapshot_ref_key != null ? aws_ebs_snapshot.this[each.value.source_snapshot_ref_key].id : each.value.source_snapshot_id
  source_region      = coalesce(each.value.source_region, var.region)

  description            = each.value.description
  encrypted              = each.value.encrypted
  kms_key_id             = each.value.kms_key_id
  storage_tier           = each.value.storage_tier
  permanent_restore      = each.value.permanent_restore
  temporary_restore_days = each.value.temporary_restore_days

  tags = merge(
    { Name = local.snapshot_copy_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Volumes
# ==============================================================================
resource "aws_ebs_volume" "this" {
  for_each = var.volumes

  availability_zone    = each.value.availability_zone
  size                 = each.value.size
  type                 = each.value.type
  iops                 = each.value.iops
  throughput           = each.value.throughput
  encrypted            = each.value.encrypted
  kms_key_id           = each.value.kms_key_id
  snapshot_id          = each.value.snapshot_id
  multi_attach_enabled = each.value.multi_attach_enabled
  final_snapshot       = each.value.final_snapshot
  outpost_arn          = each.value.outpost_arn

  tags = merge(
    { Name = local.volume_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Volume Attachments
# ==============================================================================
resource "aws_volume_attachment" "this" {
  for_each = var.volume_attachments

  device_name                    = each.value.device_name
  instance_id                    = each.value.instance_id
  volume_id                      = each.value.volume_ref_key != null ? aws_ebs_volume.this[each.value.volume_ref_key].id : each.value.volume_id
  force_detach                   = each.value.force_detach
  skip_destroy                   = each.value.skip_destroy
  stop_instance_before_detaching = each.value.stop_instance_before_detaching
}
