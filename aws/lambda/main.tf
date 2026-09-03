# ==============================================================================
# Naming Convention
# ==============================================================================
locals {
  # Build resource name based on prefix/suffix pattern
  # Pattern: {name_prefix}_{key}_{name_suffix}

  layer_names = {
    for k, v in var.layers : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  function_names = {
    for k, v in var.functions : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  alias_names = {
    for k, v in var.aliases : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  log_group_names = {
    for k, v in var.log_groups : k => "/aws/lambda/${
      v.function_ref_key != null ? local.function_names[v.function_ref_key] : v.function_name
    }"
  }
}

# ==============================================================================
# Lambda Layers
# ==============================================================================
resource "aws_lambda_layer_version" "this" {
  for_each = var.layers

  layer_name               = local.layer_names[each.key]
  description              = each.value.description
  compatible_runtimes      = each.value.compatible_runtimes
  compatible_architectures = each.value.compatible_architectures
  license_info             = each.value.license_info

  filename          = each.value.filename
  source_code_hash  = each.value.source_code_hash
  s3_bucket         = each.value.s3_bucket
  s3_key            = each.value.s3_key
  s3_object_version = each.value.s3_object_version
}

# ==============================================================================
# CloudWatch Log Groups (created before functions for proper dependency)
# ==============================================================================
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.log_groups

  name              = local.log_group_names[each.key]
  retention_in_days = each.value.retention_in_days
  kms_key_id        = each.value.kms_key_id
  skip_destroy      = each.value.skip_destroy

  tags = merge(
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Lambda Functions
# ==============================================================================
resource "aws_lambda_function" "this" {
  for_each = var.functions

  function_name = local.function_names[each.key]
  description   = each.value.description
  role          = each.value.role_arn

  handler       = each.value.package_type == "Zip" ? each.value.handler : null
  runtime       = each.value.package_type == "Zip" ? each.value.runtime : null
  architectures = each.value.architectures
  package_type  = each.value.package_type

  # Code source
  filename          = each.value.filename
  source_code_hash  = each.value.source_code_hash
  s3_bucket         = each.value.s3_bucket
  s3_key            = each.value.s3_key
  s3_object_version = each.value.s3_object_version
  image_uri         = each.value.image_uri

  # Execution
  timeout     = each.value.timeout
  memory_size = each.value.memory_size

  # Environment
  dynamic "environment" {
    for_each = length(each.value.environment_variables) > 0 ? [1] : []
    content {
      variables = each.value.environment_variables
    }
  }

  # Layers
  layers = concat(
    [for ref_key in each.value.layer_ref_keys : aws_lambda_layer_version.this[ref_key].arn],
    each.value.layer_arns
  )

  # VPC
  dynamic "vpc_config" {
    for_each = each.value.vpc_config != null ? [each.value.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # Concurrency
  reserved_concurrent_executions = each.value.reserved_concurrent_executions

  # Tracing
  dynamic "tracing_config" {
    for_each = each.value.tracing_mode != null ? [1] : []
    content {
      mode = each.value.tracing_mode
    }
  }

  # Dead letter
  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = each.value.dead_letter_target_arn
    }
  }

  # File system
  dynamic "file_system_config" {
    for_each = each.value.file_system_config != null ? [each.value.file_system_config] : []
    content {
      arn              = file_system_config.value.arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }

  # Ephemeral storage
  dynamic "ephemeral_storage" {
    for_each = each.value.ephemeral_storage_size != null ? [1] : []
    content {
      size = each.value.ephemeral_storage_size
    }
  }

  # Logging
  dynamic "logging_config" {
    for_each = each.value.logging_config != null ? [each.value.logging_config] : []
    content {
      log_format            = logging_config.value.log_format
      application_log_level = logging_config.value.application_log_level
      system_log_level      = logging_config.value.system_log_level
      log_group             = logging_config.value.log_group
    }
  }

  # Code signing
  code_signing_config_arn = each.value.code_signing_config_arn

  # SnapStart
  dynamic "snap_start" {
    for_each = each.value.snap_start ? [1] : []
    content {
      apply_on = "PublishedVersions"
    }
  }

  # Publish version
  publish = each.value.publish

  tags = merge(
    { Name = local.function_names[each.key] },
    each.value.tags,
    var.tags
  )

  depends_on = [aws_cloudwatch_log_group.this]
}

# ==============================================================================
# Lambda Aliases
# ==============================================================================
resource "aws_lambda_alias" "this" {
  for_each = var.aliases

  name             = local.alias_names[each.key]
  function_name    = each.value.function_ref_key != null ? aws_lambda_function.this[each.value.function_ref_key].function_name : each.value.function_name
  function_version = each.value.function_version
  description      = each.value.description

  dynamic "routing_config" {
    for_each = each.value.routing_config != null ? [each.value.routing_config] : []
    content {
      additional_version_weights = routing_config.value.additional_version_weights
    }
  }
}

# ==============================================================================
# Lambda Permissions
# ==============================================================================
resource "aws_lambda_permission" "this" {
  for_each = var.permissions

  statement_id           = each.key
  function_name          = each.value.function_ref_key != null ? aws_lambda_function.this[each.value.function_ref_key].function_name : each.value.function_name
  qualifier              = each.value.qualifier
  action                 = each.value.action
  principal              = each.value.principal
  source_arn             = each.value.source_arn
  source_account         = each.value.source_account
  principal_org_id       = each.value.principal_org_id
  event_source_token     = each.value.event_source_token
  function_url_auth_type = each.value.function_url_auth_type
}

# ==============================================================================
# Lambda Function URLs
# ==============================================================================
resource "aws_lambda_function_url" "this" {
  for_each = var.function_urls

  function_name      = each.value.function_ref_key != null ? aws_lambda_function.this[each.value.function_ref_key].function_name : each.value.function_name
  qualifier          = each.value.qualifier
  authorization_type = each.value.authorization_type
  invoke_mode        = each.value.invoke_mode

  dynamic "cors" {
    for_each = each.value.cors != null ? [each.value.cors] : []
    content {
      allow_credentials = cors.value.allow_credentials
      allow_headers     = cors.value.allow_headers
      allow_methods     = cors.value.allow_methods
      allow_origins     = cors.value.allow_origins
      expose_headers    = cors.value.expose_headers
      max_age           = cors.value.max_age
    }
  }
}

# ==============================================================================
# Lambda Event Source Mappings
# ==============================================================================
resource "aws_lambda_event_source_mapping" "this" {
  for_each = var.event_source_mappings

  function_name = each.value.function_ref_key != null ? aws_lambda_function.this[each.value.function_ref_key].arn : each.value.function_name

  event_source_arn                   = each.value.event_source_arn
  starting_position                  = each.value.starting_position
  starting_position_timestamp        = each.value.starting_position_timestamp
  batch_size                         = each.value.batch_size
  maximum_batching_window_in_seconds = each.value.maximum_batching_window_in_seconds
  parallelization_factor             = each.value.parallelization_factor
  maximum_retry_attempts             = each.value.maximum_retry_attempts
  maximum_record_age_in_seconds      = each.value.maximum_record_age_in_seconds
  bisect_batch_on_function_error     = each.value.bisect_batch_on_function_error
  tumbling_window_in_seconds         = each.value.tumbling_window_in_seconds
  enabled                            = each.value.enabled
  function_response_types            = each.value.function_response_types
  queues                             = each.value.queues
  topics                             = each.value.topics

  dynamic "filter_criteria" {
    for_each = each.value.filter_criteria != null ? [each.value.filter_criteria] : []
    content {
      dynamic "filter" {
        for_each = filter_criteria.value.filters
        content {
          pattern = filter.value.pattern
        }
      }
    }
  }

  dynamic "destination_config" {
    for_each = each.value.destination_config != null ? [each.value.destination_config] : []
    content {
      dynamic "on_failure" {
        for_each = destination_config.value.on_failure != null ? [destination_config.value.on_failure] : []
        content {
          destination_arn = on_failure.value.destination_arn
        }
      }
    }
  }

  dynamic "scaling_config" {
    for_each = each.value.scaling_config != null ? [each.value.scaling_config] : []
    content {
      maximum_concurrency = scaling_config.value.maximum_concurrency
    }
  }

  dynamic "self_managed_event_source" {
    for_each = each.value.self_managed_event_source != null ? [each.value.self_managed_event_source] : []
    content {
      endpoints = self_managed_event_source.value.endpoints
    }
  }

  dynamic "source_access_configuration" {
    for_each = each.value.source_access_configuration
    content {
      type = source_access_configuration.value.type
      uri  = source_access_configuration.value.uri
    }
  }

  dynamic "amazon_managed_kafka_event_source_config" {
    for_each = each.value.amazon_managed_kafka_event_source_config != null ? [each.value.amazon_managed_kafka_event_source_config] : []
    content {
      consumer_group_id = amazon_managed_kafka_event_source_config.value.consumer_group_id
    }
  }

  dynamic "self_managed_kafka_event_source_config" {
    for_each = each.value.self_managed_kafka_event_source_config != null ? [each.value.self_managed_kafka_event_source_config] : []
    content {
      consumer_group_id = self_managed_kafka_event_source_config.value.consumer_group_id
    }
  }

  dynamic "document_db_event_source_config" {
    for_each = each.value.document_db_event_source_config != null ? [each.value.document_db_event_source_config] : []
    content {
      collection_name = document_db_event_source_config.value.collection_name
      database_name   = document_db_event_source_config.value.database_name
      full_document   = document_db_event_source_config.value.full_document
    }
  }
}
