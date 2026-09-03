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
# S3 Buckets
# ------------------------------------------------------------------------------
variable "buckets" {
  description = "Map of S3 buckets to create, keyed by ref_key."
  type = map(object({
    force_destroy       = optional(bool, false)
    object_lock_enabled = optional(bool, false)
    tags                = optional(map(string), {})

    # Versioning
    versioning = optional(object({
      enabled    = optional(bool, true)
      mfa_delete = optional(bool, false)
    }))

    # Server-side encryption
    encryption = optional(object({
      sse_algorithm      = optional(string, "AES256")
      kms_master_key_id  = optional(string)
      bucket_key_enabled = optional(bool, true)
    }))

    # Public access block
    public_access_block = optional(object({
      block_public_acls       = optional(bool, true)
      block_public_policy     = optional(bool, true)
      ignore_public_acls      = optional(bool, true)
      restrict_public_buckets = optional(bool, true)
    }))

    # Object ownership
    object_ownership = optional(string, "BucketOwnerEnforced")

    # Logging
    logging = optional(object({
      target_bucket_ref_key = optional(string)
      target_bucket         = optional(string)
      target_prefix         = optional(string, "")
    }))

    # Website configuration
    website = optional(object({
      index_document = optional(string)
      error_document = optional(string)
      redirect_all_requests_to = optional(object({
        host_name = string
        protocol  = optional(string)
      }))
      routing_rules = optional(string)
    }))

    # CORS configuration
    cors_rules = optional(list(object({
      allowed_headers = optional(list(string), [])
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = optional(list(string), [])
      max_age_seconds = optional(number)
    })), [])

    # Lifecycle rules
    lifecycle_rules = optional(list(object({
      id      = string
      enabled = optional(bool, true)
      prefix  = optional(string)
      tags    = optional(map(string), {})

      filter = optional(object({
        prefix                   = optional(string)
        object_size_greater_than = optional(number)
        object_size_less_than    = optional(number)
        tags                     = optional(map(string), {})
      }))

      expiration = optional(object({
        days                         = optional(number)
        date                         = optional(string)
        expired_object_delete_marker = optional(bool)
      }))

      transition = optional(list(object({
        days          = optional(number)
        date          = optional(string)
        storage_class = string
      })), [])

      noncurrent_version_expiration = optional(object({
        noncurrent_days           = optional(number)
        newer_noncurrent_versions = optional(number)
      }))

      noncurrent_version_transition = optional(list(object({
        noncurrent_days           = optional(number)
        newer_noncurrent_versions = optional(number)
        storage_class             = string
      })), [])

      abort_incomplete_multipart_upload = optional(object({
        days_after_initiation = number
      }))
    })), [])

    # Object lock configuration
    object_lock_configuration = optional(object({
      mode  = string
      days  = optional(number)
      years = optional(number)
    }))

    # Intelligent tiering
    intelligent_tiering = optional(list(object({
      name   = string
      status = optional(string, "Enabled")
      filter = optional(object({
        prefix = optional(string)
        tags   = optional(map(string), {})
      }))
      tierings = list(object({
        access_tier = string
        days        = number
      }))
    })), [])
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Bucket Policies
# ------------------------------------------------------------------------------
variable "bucket_policies" {
  description = "Map of S3 bucket policies to create, keyed by ref_key."
  type = map(object({
    bucket_ref_key = optional(string)
    bucket         = optional(string)
    policy         = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.bucket_policies : (v.bucket_ref_key != null) != (v.bucket != null)
    ])
    error_message = "Each bucket policy must specify exactly one of bucket_ref_key or bucket."
  }
}

# ------------------------------------------------------------------------------
# Bucket Notifications
# ------------------------------------------------------------------------------
variable "bucket_notifications" {
  description = "Map of S3 bucket notifications to create, keyed by ref_key."
  type = map(object({
    bucket_ref_key = optional(string)
    bucket         = optional(string)
    eventbridge    = optional(bool, false)

    lambda_functions = optional(list(object({
      id                  = optional(string)
      lambda_function_arn = string
      events              = list(string)
      filter_prefix       = optional(string)
      filter_suffix       = optional(string)
    })), [])

    queues = optional(list(object({
      id            = optional(string)
      queue_arn     = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })), [])

    topics = optional(list(object({
      id            = optional(string)
      topic_arn     = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.bucket_notifications : (v.bucket_ref_key != null) != (v.bucket != null)
    ])
    error_message = "Each bucket notification must specify exactly one of bucket_ref_key or bucket."
  }
}

# ------------------------------------------------------------------------------
# Replication Configuration
# ------------------------------------------------------------------------------
variable "replication_configurations" {
  description = "Map of S3 replication configurations to create, keyed by ref_key."
  type = map(object({
    bucket_ref_key = optional(string)
    bucket         = optional(string)
    role_arn       = string

    rules = list(object({
      id       = string
      status   = optional(string, "Enabled")
      priority = optional(number)

      filter = optional(object({
        prefix = optional(string)
        tags   = optional(map(string), {})
      }))

      destination = object({
        bucket_arn         = string
        storage_class      = optional(string)
        account_id         = optional(string)
        replica_kms_key_id = optional(string)

        access_control_translation = optional(object({
          owner = string
        }))

        replication_time = optional(object({
          status  = string
          minutes = number
        }))

        metrics = optional(object({
          status  = string
          minutes = optional(number)
        }))
      })

      source_selection_criteria = optional(object({
        replica_modifications = optional(object({
          status = string
        }))
        sse_kms_encrypted_objects = optional(object({
          status = string
        }))
      }))

      delete_marker_replication = optional(object({
        status = string
      }))

      existing_object_replication = optional(object({
        status = string
      }))
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.replication_configurations : (v.bucket_ref_key != null) != (v.bucket != null)
    ])
    error_message = "Each replication configuration must specify exactly one of bucket_ref_key or bucket."
  }
}

# ------------------------------------------------------------------------------
# S3 Bucket Objects
# ------------------------------------------------------------------------------
variable "objects" {
  description = "Map of S3 objects to create, keyed by ref_key."
  type = map(object({
    bucket_ref_key   = optional(string)
    bucket           = optional(string)
    key              = string
    source           = optional(string)
    content          = optional(string)
    content_base64   = optional(string)
    content_type     = optional(string)
    etag             = optional(string)
    cache_control    = optional(string)
    content_encoding = optional(string)
    content_language = optional(string)
    storage_class    = optional(string)
    acl              = optional(string)
    kms_key_id       = optional(string)
    tags             = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.objects : (v.bucket_ref_key != null) != (v.bucket != null)
    ])
    error_message = "Each object must specify exactly one of bucket_ref_key or bucket."
  }
}
