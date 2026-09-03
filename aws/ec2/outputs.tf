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
# Key Pairs
# ==============================================================================
output "key_pairs" {
  description = "Map of all key pairs created, keyed by ref_key"
  value       = aws_key_pair.this
}

output "key_pair_names" {
  description = "Map of key pair names (with prefix/suffix applied), keyed by ref_key"
  value       = local.key_pair_names
}

output "key_pair_ids" {
  description = "Map of key pair IDs, keyed by ref_key"
  value       = { for k, v in aws_key_pair.this : k => v.id }
}

output "key_pair_arns" {
  description = "Map of key pair ARNs, keyed by ref_key"
  value       = { for k, v in aws_key_pair.this : k => v.arn }
}

output "key_pair_fingerprints" {
  description = "Map of key pair fingerprints, keyed by ref_key"
  value       = { for k, v in aws_key_pair.this : k => v.fingerprint }
}

output "private_keys" {
  description = "Map of generated private keys (PEM format), keyed by ref_key. Only for key pairs with create_private_key=true"
  value       = { for k, v in tls_private_key.this : k => v.private_key_pem }
  sensitive   = true
}

# ==============================================================================
# Security Groups
# ==============================================================================
output "security_groups" {
  description = "Map of all security groups created, keyed by ref_key"
  value       = aws_security_group.this
}

output "security_group_names" {
  description = "Map of security group names (with prefix/suffix applied), keyed by ref_key"
  value       = local.security_group_names
}

output "security_group_ids" {
  description = "Map of security group IDs, keyed by ref_key"
  value       = { for k, v in aws_security_group.this : k => v.id }
}

output "security_group_arns" {
  description = "Map of security group ARNs, keyed by ref_key"
  value       = { for k, v in aws_security_group.this : k => v.arn }
}

# ==============================================================================
# Instance Profiles
# ==============================================================================
output "instance_profiles" {
  description = "Map of all instance profiles created, keyed by ref_key"
  value       = aws_iam_instance_profile.this
}

output "instance_profile_names" {
  description = "Map of instance profile names (with prefix/suffix applied), keyed by ref_key"
  value       = local.instance_profile_names
}

output "instance_profile_ids" {
  description = "Map of instance profile IDs, keyed by ref_key"
  value       = { for k, v in aws_iam_instance_profile.this : k => v.id }
}

output "instance_profile_arns" {
  description = "Map of instance profile ARNs, keyed by ref_key"
  value       = { for k, v in aws_iam_instance_profile.this : k => v.arn }
}

# ==============================================================================
# Launch Templates
# ==============================================================================
output "launch_templates" {
  description = "Map of all launch templates created, keyed by ref_key"
  value       = aws_launch_template.this
}

output "launch_template_names" {
  description = "Map of launch template names (with prefix/suffix applied), keyed by ref_key"
  value       = local.launch_template_names
}

output "launch_template_ids" {
  description = "Map of launch template IDs, keyed by ref_key"
  value       = { for k, v in aws_launch_template.this : k => v.id }
}

output "launch_template_arns" {
  description = "Map of launch template ARNs, keyed by ref_key"
  value       = { for k, v in aws_launch_template.this : k => v.arn }
}

output "launch_template_latest_versions" {
  description = "Map of launch template latest versions, keyed by ref_key"
  value       = { for k, v in aws_launch_template.this : k => v.latest_version }
}

# ==============================================================================
# EC2 Instances
# ==============================================================================
output "instances" {
  description = "Map of all EC2 instances created, keyed by ref_key"
  value       = aws_instance.this
}

output "instance_names" {
  description = "Map of instance names (with prefix/suffix applied), keyed by ref_key"
  value       = local.instance_names
}

output "instance_ids" {
  description = "Map of instance IDs, keyed by ref_key"
  value       = { for k, v in aws_instance.this : k => v.id }
}

output "instance_arns" {
  description = "Map of instance ARNs, keyed by ref_key"
  value       = { for k, v in aws_instance.this : k => v.arn }
}

output "instance_private_ips" {
  description = "Map of instance private IPs, keyed by ref_key"
  value       = { for k, v in aws_instance.this : k => v.private_ip }
}

output "instance_public_ips" {
  description = "Map of instance public IPs, keyed by ref_key"
  value       = { for k, v in aws_instance.this : k => v.public_ip }
}

output "instance_private_dns" {
  description = "Map of instance private DNS names, keyed by ref_key"
  value       = { for k, v in aws_instance.this : k => v.private_dns }
}

output "instance_public_dns" {
  description = "Map of instance public DNS names, keyed by ref_key"
  value       = { for k, v in aws_instance.this : k => v.public_dns }
}

output "instance_states" {
  description = "Map of instance states, keyed by ref_key"
  value       = { for k, v in aws_instance.this : k => v.instance_state }
}

# ==============================================================================
# EBS Volumes
# ==============================================================================
output "ebs_volumes" {
  description = "Map of all EBS volumes created, keyed by ref_key"
  value       = aws_ebs_volume.this
}

output "ebs_volume_names" {
  description = "Map of EBS volume names (with prefix/suffix applied), keyed by ref_key"
  value       = local.ebs_volume_names
}

output "ebs_volume_ids" {
  description = "Map of EBS volume IDs, keyed by ref_key"
  value       = { for k, v in aws_ebs_volume.this : k => v.id }
}

output "ebs_volume_arns" {
  description = "Map of EBS volume ARNs, keyed by ref_key"
  value       = { for k, v in aws_ebs_volume.this : k => v.arn }
}

# ==============================================================================
# EBS Volume Attachments
# ==============================================================================
output "ebs_volume_attachments" {
  description = "Map of all EBS volume attachments created, keyed by ref_key"
  value       = aws_volume_attachment.this
}
