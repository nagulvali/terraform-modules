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
# S3 Buckets
# ==============================================================================
output "buckets" {
  description = "Map of all S3 buckets created, keyed by ref_key"
  value       = aws_s3_bucket.this
}

output "bucket_names" {
  description = "Map of S3 bucket names (with prefix/suffix applied), keyed by ref_key"
  value       = local.bucket_names
}

output "bucket_ids" {
  description = "Map of S3 bucket IDs, keyed by ref_key"
  value       = { for k, v in aws_s3_bucket.this : k => v.id }
}

output "bucket_arns" {
  description = "Map of S3 bucket ARNs, keyed by ref_key"
  value       = { for k, v in aws_s3_bucket.this : k => v.arn }
}

output "bucket_domain_names" {
  description = "Map of S3 bucket domain names, keyed by ref_key"
  value       = { for k, v in aws_s3_bucket.this : k => v.bucket_domain_name }
}

output "bucket_regional_domain_names" {
  description = "Map of S3 bucket regional domain names, keyed by ref_key"
  value       = { for k, v in aws_s3_bucket.this : k => v.bucket_regional_domain_name }
}

output "bucket_hosted_zone_ids" {
  description = "Map of S3 bucket hosted zone IDs (for Route53 alias records), keyed by ref_key"
  value       = { for k, v in aws_s3_bucket.this : k => v.hosted_zone_id }
}

# ==============================================================================
# Website Endpoints
# ==============================================================================
output "website_endpoints" {
  description = "Map of S3 website endpoints, keyed by ref_key"
  value = {
    for k, v in aws_s3_bucket_website_configuration.this : k => v.website_endpoint
  }
}

output "website_domains" {
  description = "Map of S3 website domains, keyed by ref_key"
  value = {
    for k, v in aws_s3_bucket_website_configuration.this : k => v.website_domain
  }
}

# ==============================================================================
# Versioning
# ==============================================================================
output "bucket_versioning" {
  description = "Map of bucket versioning configurations, keyed by ref_key"
  value       = aws_s3_bucket_versioning.this
}

# ==============================================================================
# Encryption
# ==============================================================================
output "bucket_encryption" {
  description = "Map of bucket encryption configurations, keyed by ref_key"
  value       = aws_s3_bucket_server_side_encryption_configuration.this
}

# ==============================================================================
# Bucket Policies
# ==============================================================================
output "bucket_policies" {
  description = "Map of bucket policies created, keyed by ref_key"
  value       = aws_s3_bucket_policy.this
}

# ==============================================================================
# Bucket Notifications
# ==============================================================================
output "bucket_notifications" {
  description = "Map of bucket notifications created, keyed by ref_key"
  value       = aws_s3_bucket_notification.this
}

# ==============================================================================
# Replication Configurations
# ==============================================================================
output "replication_configurations" {
  description = "Map of replication configurations created, keyed by ref_key"
  value       = aws_s3_bucket_replication_configuration.this
}

# ==============================================================================
# S3 Objects
# ==============================================================================
output "objects" {
  description = "Map of S3 objects created, keyed by ref_key"
  value       = aws_s3_object.this
}

output "object_ids" {
  description = "Map of S3 object IDs, keyed by ref_key"
  value       = { for k, v in aws_s3_object.this : k => v.id }
}

output "object_etags" {
  description = "Map of S3 object ETags, keyed by ref_key"
  value       = { for k, v in aws_s3_object.this : k => v.etag }
}

output "object_version_ids" {
  description = "Map of S3 object version IDs, keyed by ref_key"
  value       = { for k, v in aws_s3_object.this : k => v.version_id }
}
