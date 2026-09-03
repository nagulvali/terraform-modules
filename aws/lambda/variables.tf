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
# Lambda Layers
# ------------------------------------------------------------------------------
variable "layers" {
  description = "Map of Lambda layers to create, keyed by ref_key."
  type = map(object({
    description              = optional(string)
    compatible_runtimes      = optional(list(string), [])
    compatible_architectures = optional(list(string), [])
    license_info             = optional(string)

    # Source - specify one
    filename          = optional(string)
    s3_bucket         = optional(string)
    s3_key            = optional(string)
    s3_object_version = optional(string)
    source_code_hash  = optional(string)
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Lambda Functions
# ------------------------------------------------------------------------------
variable "functions" {
  description = "Map of Lambda functions to create, keyed by ref_key."
  type = map(object({
    description   = optional(string)
    handler       = optional(string)
    runtime       = optional(string)
    architectures = optional(list(string), ["x86_64"])

    # Code source - specify one
    filename          = optional(string)
    source_code_hash  = optional(string)
    s3_bucket         = optional(string)
    s3_key            = optional(string)
    s3_object_version = optional(string)
    image_uri         = optional(string)
    package_type      = optional(string, "Zip")

    # Execution
    role_arn    = string
    timeout     = optional(number, 3)
    memory_size = optional(number, 128)

    # Environment
    environment_variables = optional(map(string), {})

    # Layers
    layer_ref_keys = optional(list(string), [])
    layer_arns     = optional(list(string), [])

    # VPC
    vpc_config = optional(object({
      subnet_ids         = list(string)
      security_group_ids = list(string)
    }))

    # Concurrency
    reserved_concurrent_executions = optional(number, -1)

    # Tracing
    tracing_mode = optional(string)

    # Dead letter
    dead_letter_target_arn = optional(string)

    # File system
    file_system_config = optional(object({
      arn              = string
      local_mount_path = string
    }))

    # Ephemeral storage
    ephemeral_storage_size = optional(number)

    # Logging
    logging_config = optional(object({
      log_format            = optional(string, "Text")
      application_log_level = optional(string)
      system_log_level      = optional(string)
      log_group             = optional(string)
    }))

    # Code signing
    code_signing_config_arn = optional(string)

    # SnapStart
    snap_start = optional(bool, false)

    # Publish version
    publish = optional(bool, false)

    tags = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Lambda Aliases
# ------------------------------------------------------------------------------
variable "aliases" {
  description = "Map of Lambda aliases to create, keyed by ref_key."
  type = map(object({
    function_ref_key = optional(string)
    function_name    = optional(string)
    function_version = string
    description      = optional(string)

    routing_config = optional(object({
      additional_version_weights = map(number)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.aliases : (v.function_ref_key != null) != (v.function_name != null)
    ])
    error_message = "Each alias must specify exactly one of function_ref_key or function_name."
  }
}

# ------------------------------------------------------------------------------
# Lambda Permissions
# ------------------------------------------------------------------------------
variable "permissions" {
  description = "Map of Lambda permissions to create, keyed by ref_key."
  type = map(object({
    function_ref_key       = optional(string)
    function_name          = optional(string)
    qualifier              = optional(string)
    action                 = optional(string, "lambda:InvokeFunction")
    principal              = string
    source_arn             = optional(string)
    source_account         = optional(string)
    principal_org_id       = optional(string)
    event_source_token     = optional(string)
    function_url_auth_type = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.permissions : (v.function_ref_key != null) != (v.function_name != null)
    ])
    error_message = "Each permission must specify exactly one of function_ref_key or function_name."
  }
}

# ------------------------------------------------------------------------------
# Lambda Function URLs
# ------------------------------------------------------------------------------
variable "function_urls" {
  description = "Map of Lambda function URLs to create, keyed by ref_key."
  type = map(object({
    function_ref_key   = optional(string)
    function_name      = optional(string)
    qualifier          = optional(string)
    authorization_type = optional(string, "NONE")
    invoke_mode        = optional(string, "BUFFERED")

    cors = optional(object({
      allow_credentials = optional(bool, false)
      allow_headers     = optional(list(string), [])
      allow_methods     = optional(list(string), [])
      allow_origins     = optional(list(string), [])
      expose_headers    = optional(list(string), [])
      max_age           = optional(number, 0)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.function_urls : (v.function_ref_key != null) != (v.function_name != null)
    ])
    error_message = "Each function URL must specify exactly one of function_ref_key or function_name."
  }
}

# ------------------------------------------------------------------------------
# Lambda Event Source Mappings
# ------------------------------------------------------------------------------
variable "event_source_mappings" {
  description = "Map of Lambda event source mappings to create, keyed by ref_key."
  type = map(object({
    function_ref_key = optional(string)
    function_name    = optional(string)

    event_source_arn                   = string
    starting_position                  = optional(string)
    starting_position_timestamp        = optional(string)
    batch_size                         = optional(number)
    maximum_batching_window_in_seconds = optional(number)
    parallelization_factor             = optional(number)
    maximum_retry_attempts             = optional(number)
    maximum_record_age_in_seconds      = optional(number)
    bisect_batch_on_function_error     = optional(bool)
    tumbling_window_in_seconds         = optional(number)
    enabled                            = optional(bool, true)

    filter_criteria = optional(object({
      filters = list(object({
        pattern = string
      }))
    }))

    destination_config = optional(object({
      on_failure = optional(object({
        destination_arn = string
      }))
    }))

    scaling_config = optional(object({
      maximum_concurrency = number
    }))

    self_managed_event_source = optional(object({
      endpoints = map(string)
    }))

    source_access_configuration = optional(list(object({
      type = string
      uri  = string
    })), [])

    amazon_managed_kafka_event_source_config = optional(object({
      consumer_group_id = string
    }))

    self_managed_kafka_event_source_config = optional(object({
      consumer_group_id = string
    }))

    document_db_event_source_config = optional(object({
      collection_name = optional(string)
      database_name   = string
      full_document   = optional(string)
    }))

    function_response_types = optional(list(string), [])
    queues                  = optional(list(string), [])
    topics                  = optional(list(string), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.event_source_mappings : (v.function_ref_key != null) != (v.function_name != null)
    ])
    error_message = "Each event source mapping must specify exactly one of function_ref_key or function_name."
  }
}

# ------------------------------------------------------------------------------
# CloudWatch Log Groups
# ------------------------------------------------------------------------------
variable "log_groups" {
  description = "Map of CloudWatch log groups for Lambda functions, keyed by ref_key."
  type = map(object({
    function_ref_key  = optional(string)
    function_name     = optional(string)
    retention_in_days = optional(number, 14)
    kms_key_id        = optional(string)
    skip_destroy      = optional(bool, false)
    tags              = optional(map(string), {})
  }))
  default = {}
}
