# ==============================================================================
# Naming Convention
# ==============================================================================
locals {
  # Build resource name based on prefix/suffix pattern
  # Pattern: {name_prefix}_{key}_{name_suffix}
  # Note: S3 bucket names use hyphens instead of underscores for DNS compliance

  bucket_names = {
    for k, v in var.buckets : k => replace(join("-", compact([var.name_prefix, k, var.name_suffix])), "_", "-")
  }
}

# ==============================================================================
# S3 Buckets
# ==============================================================================
resource "aws_s3_bucket" "this" {
  for_each = var.buckets

  bucket              = local.bucket_names[each.key]
  force_destroy       = each.value.force_destroy
  object_lock_enabled = each.value.object_lock_enabled

  tags = merge(
    { Name = local.bucket_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Bucket Versioning
# ==============================================================================
resource "aws_s3_bucket_versioning" "this" {
  for_each = {
    for k, v in var.buckets : k => v if v.versioning != null
  }

  bucket = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status     = each.value.versioning.enabled ? "Enabled" : "Suspended"
    mfa_delete = each.value.versioning.mfa_delete ? "Enabled" : "Disabled"
  }
}

# ==============================================================================
# Bucket Encryption
# ==============================================================================
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = {
    for k, v in var.buckets : k => v if v.encryption != null
  }

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = each.value.encryption.sse_algorithm
      kms_master_key_id = each.value.encryption.kms_master_key_id
    }
    bucket_key_enabled = each.value.encryption.bucket_key_enabled
  }
}

# ==============================================================================
# Public Access Block
# ==============================================================================
resource "aws_s3_bucket_public_access_block" "this" {
  for_each = {
    for k, v in var.buckets : k => v if v.public_access_block != null
  }

  bucket = aws_s3_bucket.this[each.key].id

  block_public_acls       = each.value.public_access_block.block_public_acls
  block_public_policy     = each.value.public_access_block.block_public_policy
  ignore_public_acls      = each.value.public_access_block.ignore_public_acls
  restrict_public_buckets = each.value.public_access_block.restrict_public_buckets
}

# ==============================================================================
# Object Ownership
# ==============================================================================
resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = {
    for k, v in var.buckets : k => v if v.object_ownership != null
  }

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    object_ownership = each.value.object_ownership
  }

  depends_on = [aws_s3_bucket_public_access_block.this]
}

# ==============================================================================
# Bucket Logging
# ==============================================================================
resource "aws_s3_bucket_logging" "this" {
  for_each = {
    for k, v in var.buckets : k => v if v.logging != null
  }

  bucket = aws_s3_bucket.this[each.key].id

  target_bucket = each.value.logging.target_bucket_ref_key != null ? aws_s3_bucket.this[each.value.logging.target_bucket_ref_key].id : each.value.logging.target_bucket
  target_prefix = each.value.logging.target_prefix
}

# ==============================================================================
# Website Configuration
# ==============================================================================
resource "aws_s3_bucket_website_configuration" "this" {
  for_each = {
    for k, v in var.buckets : k => v if v.website != null
  }

  bucket = aws_s3_bucket.this[each.key].id

  dynamic "index_document" {
    for_each = each.value.website.index_document != null ? [1] : []
    content {
      suffix = each.value.website.index_document
    }
  }

  dynamic "error_document" {
    for_each = each.value.website.error_document != null ? [1] : []
    content {
      key = each.value.website.error_document
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = each.value.website.redirect_all_requests_to != null ? [each.value.website.redirect_all_requests_to] : []
    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = redirect_all_requests_to.value.protocol
    }
  }

  routing_rules = each.value.website.routing_rules
}

# ==============================================================================
# CORS Configuration
# ==============================================================================
resource "aws_s3_bucket_cors_configuration" "this" {
  for_each = {
    for k, v in var.buckets : k => v if length(v.cors_rules) > 0
  }

  bucket = aws_s3_bucket.this[each.key].id

  dynamic "cors_rule" {
    for_each = each.value.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

# ==============================================================================
# Lifecycle Configuration
# ==============================================================================
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = {
    for k, v in var.buckets : k => v if length(v.lifecycle_rules) > 0
  }

  bucket = aws_s3_bucket.this[each.key].id

  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : (rule.value.prefix != null ? [{ prefix = rule.value.prefix }] : [])
        content {
          prefix                   = filter.value.prefix
          object_size_greater_than = try(filter.value.object_size_greater_than, null)
          object_size_less_than    = try(filter.value.object_size_less_than, null)

          dynamic "tag" {
            for_each = try(filter.value.tags, {})
            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days                         = expiration.value.days
          date                         = expiration.value.date
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      dynamic "transition" {
        for_each = rule.value.transition
        content {
          days          = transition.value.days
          date          = transition.value.date
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days           = noncurrent_version_expiration.value.noncurrent_days
          newer_noncurrent_versions = noncurrent_version_expiration.value.newer_noncurrent_versions
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition
        content {
          noncurrent_days           = noncurrent_version_transition.value.noncurrent_days
          newer_noncurrent_versions = noncurrent_version_transition.value.newer_noncurrent_versions
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload != null ? [rule.value.abort_incomplete_multipart_upload] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

# ==============================================================================
# Object Lock Configuration
# ==============================================================================
resource "aws_s3_bucket_object_lock_configuration" "this" {
  for_each = {
    for k, v in var.buckets : k => v if v.object_lock_configuration != null && v.object_lock_enabled
  }

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    default_retention {
      mode  = each.value.object_lock_configuration.mode
      days  = each.value.object_lock_configuration.days
      years = each.value.object_lock_configuration.years
    }
  }
}

# ==============================================================================
# Intelligent Tiering Configuration
# ==============================================================================
resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  for_each = merge([
    for bucket_key, bucket in var.buckets : {
      for tiering in bucket.intelligent_tiering :
      "${bucket_key}/${tiering.name}" => {
        bucket_key = bucket_key
        tiering    = tiering
      }
    }
  ]...)

  bucket = aws_s3_bucket.this[each.value.bucket_key].id
  name   = each.value.tiering.name
  status = each.value.tiering.status

  dynamic "filter" {
    for_each = each.value.tiering.filter != null ? [each.value.tiering.filter] : []
    content {
      prefix = filter.value.prefix
    }
  }

  dynamic "tiering" {
    for_each = each.value.tiering.tierings
    content {
      access_tier = tiering.value.access_tier
      days        = tiering.value.days
    }
  }
}

# ==============================================================================
# Bucket Policies
# ==============================================================================
resource "aws_s3_bucket_policy" "this" {
  for_each = var.bucket_policies

  bucket = each.value.bucket_ref_key != null ? aws_s3_bucket.this[each.value.bucket_ref_key].id : each.value.bucket
  policy = each.value.policy

  depends_on = [aws_s3_bucket_public_access_block.this]
}

# ==============================================================================
# Bucket Notifications
# ==============================================================================
resource "aws_s3_bucket_notification" "this" {
  for_each = var.bucket_notifications

  bucket      = each.value.bucket_ref_key != null ? aws_s3_bucket.this[each.value.bucket_ref_key].id : each.value.bucket
  eventbridge = each.value.eventbridge

  dynamic "lambda_function" {
    for_each = each.value.lambda_functions
    content {
      id                  = lambda_function.value.id
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lambda_function.value.filter_prefix
      filter_suffix       = lambda_function.value.filter_suffix
    }
  }

  dynamic "queue" {
    for_each = each.value.queues
    content {
      id            = queue.value.id
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = queue.value.filter_prefix
      filter_suffix = queue.value.filter_suffix
    }
  }

  dynamic "topic" {
    for_each = each.value.topics
    content {
      id            = topic.value.id
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = topic.value.filter_prefix
      filter_suffix = topic.value.filter_suffix
    }
  }
}

# ==============================================================================
# Replication Configuration
# ==============================================================================
resource "aws_s3_bucket_replication_configuration" "this" {
  for_each = var.replication_configurations

  bucket = each.value.bucket_ref_key != null ? aws_s3_bucket.this[each.value.bucket_ref_key].id : each.value.bucket
  role   = each.value.role_arn

  dynamic "rule" {
    for_each = each.value.rules
    content {
      id       = rule.value.id
      status   = rule.value.status
      priority = rule.value.priority

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix = filter.value.prefix

          dynamic "tag" {
            for_each = filter.value.tags != null ? filter.value.tags : {}
            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      destination {
        bucket        = rule.value.destination.bucket_arn
        storage_class = rule.value.destination.storage_class
        account       = rule.value.destination.account_id

        dynamic "encryption_configuration" {
          for_each = rule.value.destination.replica_kms_key_id != null ? [1] : []
          content {
            replica_kms_key_id = rule.value.destination.replica_kms_key_id
          }
        }

        dynamic "access_control_translation" {
          for_each = rule.value.destination.access_control_translation != null ? [rule.value.destination.access_control_translation] : []
          content {
            owner = access_control_translation.value.owner
          }
        }

        dynamic "replication_time" {
          for_each = rule.value.destination.replication_time != null ? [rule.value.destination.replication_time] : []
          content {
            status = replication_time.value.status
            time {
              minutes = replication_time.value.minutes
            }
          }
        }

        dynamic "metrics" {
          for_each = rule.value.destination.metrics != null ? [rule.value.destination.metrics] : []
          content {
            status = metrics.value.status
            event_threshold {
              minutes = metrics.value.minutes
            }
          }
        }
      }

      dynamic "source_selection_criteria" {
        for_each = rule.value.source_selection_criteria != null ? [rule.value.source_selection_criteria] : []
        content {
          dynamic "replica_modifications" {
            for_each = source_selection_criteria.value.replica_modifications != null ? [source_selection_criteria.value.replica_modifications] : []
            content {
              status = replica_modifications.value.status
            }
          }
          dynamic "sse_kms_encrypted_objects" {
            for_each = source_selection_criteria.value.sse_kms_encrypted_objects != null ? [source_selection_criteria.value.sse_kms_encrypted_objects] : []
            content {
              status = sse_kms_encrypted_objects.value.status
            }
          }
        }
      }

      dynamic "delete_marker_replication" {
        for_each = rule.value.delete_marker_replication != null ? [rule.value.delete_marker_replication] : []
        content {
          status = delete_marker_replication.value.status
        }
      }

      dynamic "existing_object_replication" {
        for_each = rule.value.existing_object_replication != null ? [rule.value.existing_object_replication] : []
        content {
          status = existing_object_replication.value.status
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

# ==============================================================================
# S3 Objects
# ==============================================================================
resource "aws_s3_object" "this" {
  for_each = var.objects

  bucket           = each.value.bucket_ref_key != null ? aws_s3_bucket.this[each.value.bucket_ref_key].id : each.value.bucket
  key              = each.value.key
  source           = each.value.source
  content          = each.value.content
  content_base64   = each.value.content_base64
  content_type     = each.value.content_type
  etag             = each.value.etag
  cache_control    = each.value.cache_control
  content_encoding = each.value.content_encoding
  content_language = each.value.content_language
  storage_class    = each.value.storage_class
  acl              = each.value.acl
  kms_key_id       = each.value.kms_key_id

  tags = merge(
    each.value.tags,
    var.tags
  )
}
