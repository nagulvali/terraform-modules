# ==============================================================================
# Naming Convention
# ==============================================================================
output "name_prefix" {
  description = "Name prefix used for all resources"
  value       = var.name_prefix
}

output "name_suffix" {
  description = "Name suffix used for all resources"
  value       = var.name_suffix
}

# ==============================================================================
# Volumes
# ==============================================================================
output "volumes" {
  description = "Map of all EBS volumes created, keyed by ref_key"
  value       = aws_ebs_volume.this
}

output "volume_ids" {
  description = "Map of EBS volume IDs, keyed by ref_key"
  value       = { for k, v in aws_ebs_volume.this : k => v.id }
}

output "volume_arns" {
  description = "Map of EBS volume ARNs, keyed by ref_key"
  value       = { for k, v in aws_ebs_volume.this : k => v.arn }
}

output "volume_names" {
  description = "Map of EBS volume Names (with prefix/suffix applied), keyed by ref_key"
  value       = local.volume_names
}

# ==============================================================================
# Volume Attachments
# ==============================================================================
output "volume_attachments" {
  description = "Map of all volume attachments created, keyed by ref_key"
  value       = aws_volume_attachment.this
}

# ==============================================================================
# Snapshots
# ==============================================================================
output "snapshots" {
  description = "Map of all EBS snapshots created, keyed by ref_key"
  value       = aws_ebs_snapshot.this
}

output "snapshot_ids" {
  description = "Map of EBS snapshot IDs, keyed by ref_key"
  value       = { for k, v in aws_ebs_snapshot.this : k => v.id }
}

output "snapshot_arns" {
  description = "Map of EBS snapshot ARNs, keyed by ref_key"
  value       = { for k, v in aws_ebs_snapshot.this : k => v.arn }
}

output "snapshot_names" {
  description = "Map of EBS snapshot Names (with prefix/suffix applied), keyed by ref_key"
  value       = local.snapshot_names
}

# ==============================================================================
# Snapshot Copies
# ==============================================================================
output "snapshot_copies" {
  description = "Map of all EBS snapshot copies created, keyed by ref_key"
  value       = aws_ebs_snapshot_copy.this
}

output "snapshot_copy_ids" {
  description = "Map of EBS snapshot copy IDs, keyed by ref_key"
  value       = { for k, v in aws_ebs_snapshot_copy.this : k => v.id }
}

output "snapshot_copy_arns" {
  description = "Map of EBS snapshot copy ARNs, keyed by ref_key"
  value       = { for k, v in aws_ebs_snapshot_copy.this : k => v.arn }
}

output "snapshot_copy_names" {
  description = "Map of EBS snapshot copy Names (with prefix/suffix applied), keyed by ref_key"
  value       = local.snapshot_copy_names
}

# ==============================================================================
# Default Encryption
# ==============================================================================
output "encryption_by_default_enabled" {
  description = "Whether account-level default EBS encryption is enabled when managed by this module"
  value       = try(aws_ebs_encryption_by_default.this[0].enabled, null)
}

output "default_kms_key_arn" {
  description = "Account-level default KMS key ARN when managed by this module"
  value       = try(aws_ebs_default_kms_key.this[0].key_arn, null)
}
