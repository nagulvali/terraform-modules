# ==============================================================================
# Naming Convention
# ==============================================================================
locals {
  # Build resource name based on prefix/suffix pattern
  # Pattern: {name_prefix}_{key}_{name_suffix}

  bus_names = {
    for k, v in var.buses : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  rule_names = {
    for k, v in var.rules : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  archive_names = {
    for k, v in var.archives : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  connection_names = {
    for k, v in var.connections : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  api_destination_names = {
    for k, v in var.api_destinations : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  schedule_group_names = {
    for k, v in var.schedule_groups : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }

  schedule_names = {
    for k, v in var.schedules : k => join("_", compact([var.name_prefix, k, var.name_suffix]))
  }
}

# ==============================================================================
# Event Buses
# ==============================================================================
resource "aws_cloudwatch_event_bus" "this" {
  for_each = var.buses

  name              = local.bus_names[each.key]
  event_source_name = each.value.event_source_name

  tags = merge(
    { Name = local.bus_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Event Bus Permissions
# ==============================================================================
resource "aws_cloudwatch_event_permission" "this" {
  for_each = var.bus_permissions

  event_bus_name = each.value.bus_ref_key != null ? aws_cloudwatch_event_bus.this[each.value.bus_ref_key].name : each.value.event_bus_name
  principal      = each.value.principal
  statement_id   = each.value.statement_id
  action         = each.value.action

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      key   = condition.value.key
      type  = condition.value.type
      value = condition.value.value
    }
  }
}

# ==============================================================================
# Event Rules
# ==============================================================================
resource "aws_cloudwatch_event_rule" "this" {
  for_each = var.rules

  name                = local.rule_names[each.key]
  description         = each.value.description
  event_bus_name      = each.value.bus_ref_key != null ? aws_cloudwatch_event_bus.this[each.value.bus_ref_key].name : each.value.event_bus_name
  event_pattern       = each.value.event_pattern
  schedule_expression = each.value.schedule_expression
  role_arn            = each.value.role_arn
  is_enabled          = each.value.is_enabled

  tags = merge(
    { Name = local.rule_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Event Targets
# ==============================================================================
resource "aws_cloudwatch_event_target" "this" {
  for_each = var.targets

  rule           = each.value.rule_ref_key != null ? aws_cloudwatch_event_rule.this[each.value.rule_ref_key].name : each.value.rule_name
  event_bus_name = each.value.bus_ref_key != null ? aws_cloudwatch_event_bus.this[each.value.bus_ref_key].name : each.value.event_bus_name
  target_id      = each.value.target_id
  arn            = each.value.arn
  role_arn       = each.value.role_arn
  input          = each.value.input
  input_path     = each.value.input_path

  dynamic "input_transformer" {
    for_each = each.value.input_transformer != null ? [each.value.input_transformer] : []
    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }

  dynamic "retry_policy" {
    for_each = each.value.retry_policy != null ? [each.value.retry_policy] : []
    content {
      maximum_event_age_in_seconds = retry_policy.value.maximum_event_age_in_seconds
      maximum_retry_attempts       = retry_policy.value.maximum_retry_attempts
    }
  }

  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_config != null ? [each.value.dead_letter_config] : []
    content {
      arn = dead_letter_config.value.arn
    }
  }

  dynamic "run_command_targets" {
    for_each = each.value.run_command_targets
    content {
      key    = run_command_targets.value.key
      values = run_command_targets.value.values
    }
  }

  dynamic "ecs_target" {
    for_each = each.value.ecs_target != null ? [each.value.ecs_target] : []
    content {
      task_definition_arn     = ecs_target.value.task_definition_arn
      task_count              = ecs_target.value.task_count
      launch_type             = ecs_target.value.launch_type
      platform_version        = ecs_target.value.platform_version
      group                   = ecs_target.value.group
      enable_execute_command  = ecs_target.value.enable_execute_command
      enable_ecs_managed_tags = ecs_target.value.enable_ecs_managed_tags
      propagate_tags          = ecs_target.value.propagate_tags
      tags                    = ecs_target.value.tags

      dynamic "network_configuration" {
        for_each = ecs_target.value.network_configuration != null ? [ecs_target.value.network_configuration] : []
        content {
          subnets          = network_configuration.value.subnets
          security_groups  = network_configuration.value.security_groups
          assign_public_ip = network_configuration.value.assign_public_ip
        }
      }

      dynamic "capacity_provider_strategy" {
        for_each = ecs_target.value.capacity_provider_strategy
        content {
          capacity_provider = capacity_provider_strategy.value.capacity_provider
          weight            = capacity_provider_strategy.value.weight
          base              = capacity_provider_strategy.value.base
        }
      }

      dynamic "placement_constraint" {
        for_each = ecs_target.value.placement_constraint
        content {
          type       = placement_constraint.value.type
          expression = placement_constraint.value.expression
        }
      }
    }
  }

  dynamic "batch_target" {
    for_each = each.value.batch_target != null ? [each.value.batch_target] : []
    content {
      job_definition = batch_target.value.job_definition
      job_name       = batch_target.value.job_name
      array_size     = batch_target.value.array_size
      job_attempts   = batch_target.value.job_attempts
    }
  }

  dynamic "kinesis_target" {
    for_each = each.value.kinesis_target != null ? [each.value.kinesis_target] : []
    content {
      partition_key_path = kinesis_target.value.partition_key_path
    }
  }

  dynamic "sqs_target" {
    for_each = each.value.sqs_target != null ? [each.value.sqs_target] : []
    content {
      message_group_id = sqs_target.value.message_group_id
    }
  }

  dynamic "http_target" {
    for_each = each.value.http_target != null ? [each.value.http_target] : []
    content {
      path_parameter_values   = http_target.value.path_parameter_values
      query_string_parameters = http_target.value.query_string_parameters
      header_parameters       = http_target.value.header_parameters
    }
  }

  dynamic "redshift_target" {
    for_each = each.value.redshift_target != null ? [each.value.redshift_target] : []
    content {
      database            = redshift_target.value.database
      db_user             = redshift_target.value.db_user
      secrets_manager_arn = redshift_target.value.secrets_manager_arn
      sql                 = redshift_target.value.sql
      statement_name      = redshift_target.value.statement_name
      with_event          = redshift_target.value.with_event
    }
  }

  dynamic "sagemaker_pipeline_target" {
    for_each = each.value.sagemaker_pipeline_target != null ? [each.value.sagemaker_pipeline_target] : []
    content {
      dynamic "pipeline_parameter_list" {
        for_each = sagemaker_pipeline_target.value.pipeline_parameter_list
        content {
          name  = pipeline_parameter_list.value.name
          value = pipeline_parameter_list.value.value
        }
      }
    }
  }
}

# ==============================================================================
# Event Archives
# ==============================================================================
resource "aws_cloudwatch_event_archive" "this" {
  for_each = var.archives

  name             = local.archive_names[each.key]
  description      = each.value.description
  event_source_arn = each.value.bus_ref_key != null ? aws_cloudwatch_event_bus.this[each.value.bus_ref_key].arn : each.value.event_source_arn
  event_pattern    = each.value.event_pattern
  retention_days   = each.value.retention_days
}

# ==============================================================================
# Connections (for API Destinations)
# ==============================================================================
resource "aws_cloudwatch_event_connection" "this" {
  for_each = var.connections

  name               = local.connection_names[each.key]
  description        = each.value.description
  authorization_type = each.value.authorization_type

  auth_parameters {
    dynamic "api_key" {
      for_each = each.value.auth_parameters.api_key != null ? [each.value.auth_parameters.api_key] : []
      content {
        key   = api_key.value.key
        value = api_key.value.value
      }
    }

    dynamic "basic" {
      for_each = each.value.auth_parameters.basic != null ? [each.value.auth_parameters.basic] : []
      content {
        username = basic.value.username
        password = basic.value.password
      }
    }

    dynamic "oauth" {
      for_each = each.value.auth_parameters.oauth != null ? [each.value.auth_parameters.oauth] : []
      content {
        authorization_endpoint = oauth.value.authorization_endpoint
        http_method            = oauth.value.http_method

        dynamic "client_parameters" {
          for_each = oauth.value.client_parameters != null ? [oauth.value.client_parameters] : []
          content {
            client_id     = client_parameters.value.client_id
            client_secret = client_parameters.value.client_secret
          }
        }

        dynamic "oauth_http_parameters" {
          for_each = oauth.value.oauth_http_parameters != null ? [oauth.value.oauth_http_parameters] : []
          content {
            dynamic "body" {
              for_each = oauth_http_parameters.value.body
              content {
                key             = body.value.key
                value           = body.value.value
                is_value_secret = body.value.is_value_secret
              }
            }
            dynamic "header" {
              for_each = oauth_http_parameters.value.header
              content {
                key             = header.value.key
                value           = header.value.value
                is_value_secret = header.value.is_value_secret
              }
            }
            dynamic "query_string" {
              for_each = oauth_http_parameters.value.query_string
              content {
                key             = query_string.value.key
                value           = query_string.value.value
                is_value_secret = query_string.value.is_value_secret
              }
            }
          }
        }
      }
    }

    dynamic "invocation_http_parameters" {
      for_each = each.value.auth_parameters.invocation_http_parameters != null ? [each.value.auth_parameters.invocation_http_parameters] : []
      content {
        dynamic "body" {
          for_each = invocation_http_parameters.value.body
          content {
            key             = body.value.key
            value           = body.value.value
            is_value_secret = body.value.is_value_secret
          }
        }
        dynamic "header" {
          for_each = invocation_http_parameters.value.header
          content {
            key             = header.value.key
            value           = header.value.value
            is_value_secret = header.value.is_value_secret
          }
        }
        dynamic "query_string" {
          for_each = invocation_http_parameters.value.query_string
          content {
            key             = query_string.value.key
            value           = query_string.value.value
            is_value_secret = query_string.value.is_value_secret
          }
        }
      }
    }
  }
}

# ==============================================================================
# API Destinations
# ==============================================================================
resource "aws_cloudwatch_event_api_destination" "this" {
  for_each = var.api_destinations

  name                             = local.api_destination_names[each.key]
  description                      = each.value.description
  connection_arn                   = each.value.connection_ref_key != null ? aws_cloudwatch_event_connection.this[each.value.connection_ref_key].arn : each.value.connection_arn
  invocation_endpoint              = each.value.invocation_endpoint
  http_method                      = each.value.http_method
  invocation_rate_limit_per_second = each.value.invocation_rate_limit_per_second
}

# ==============================================================================
# EventBridge Scheduler - Schedule Groups
# ==============================================================================
resource "aws_scheduler_schedule_group" "this" {
  for_each = var.schedule_groups

  name = local.schedule_group_names[each.key]

  tags = merge(
    { Name = local.schedule_group_names[each.key] },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# EventBridge Scheduler - Schedules
# ==============================================================================
resource "aws_scheduler_schedule" "this" {
  for_each = var.schedules

  name                         = local.schedule_names[each.key]
  description                  = each.value.description
  group_name                   = each.value.group_ref_key != null ? aws_scheduler_schedule_group.this[each.value.group_ref_key].name : each.value.group_name
  schedule_expression          = each.value.schedule_expression
  schedule_expression_timezone = each.value.schedule_expression_timezone
  state                        = each.value.state
  start_date                   = each.value.start_date
  end_date                     = each.value.end_date

  flexible_time_window {
    mode                      = each.value.flexible_time_window.mode
    maximum_window_in_minutes = each.value.flexible_time_window.maximum_window_in_minutes
  }

  target {
    arn      = each.value.target.arn
    role_arn = each.value.target.role_arn
    input    = each.value.target.input

    dynamic "retry_policy" {
      for_each = each.value.target.retry_policy != null ? [each.value.target.retry_policy] : []
      content {
        maximum_event_age_in_seconds = retry_policy.value.maximum_event_age_in_seconds
        maximum_retry_attempts       = retry_policy.value.maximum_retry_attempts
      }
    }

    dynamic "dead_letter_config" {
      for_each = each.value.target.dead_letter_config != null ? [each.value.target.dead_letter_config] : []
      content {
        arn = dead_letter_config.value.arn
      }
    }

    dynamic "ecs_parameters" {
      for_each = each.value.target.ecs_parameters != null ? [each.value.target.ecs_parameters] : []
      content {
        task_definition_arn     = ecs_parameters.value.task_definition_arn
        task_count              = ecs_parameters.value.task_count
        launch_type             = ecs_parameters.value.launch_type
        platform_version        = ecs_parameters.value.platform_version
        group                   = ecs_parameters.value.group
        enable_execute_command  = ecs_parameters.value.enable_execute_command
        enable_ecs_managed_tags = ecs_parameters.value.enable_ecs_managed_tags
        propagate_tags          = ecs_parameters.value.propagate_tags
        tags                    = ecs_parameters.value.tags

        dynamic "network_configuration" {
          for_each = ecs_parameters.value.network_configuration != null ? [ecs_parameters.value.network_configuration] : []
          content {
            subnets          = network_configuration.value.subnets
            security_groups  = network_configuration.value.security_groups
            assign_public_ip = network_configuration.value.assign_public_ip
          }
        }

        dynamic "capacity_provider_strategy" {
          for_each = ecs_parameters.value.capacity_provider_strategy
          content {
            capacity_provider = capacity_provider_strategy.value.capacity_provider
            weight            = capacity_provider_strategy.value.weight
            base              = capacity_provider_strategy.value.base
          }
        }

        dynamic "placement_constraints" {
          for_each = ecs_parameters.value.placement_constraint
          content {
            type       = placement_constraints.value.type
            expression = placement_constraints.value.expression
          }
        }

        dynamic "placement_strategy" {
          for_each = ecs_parameters.value.placement_strategy != null ? ecs_parameters.value.placement_strategy : []
          content {
            type  = placement_strategy.value.type
            field = placement_strategy.value.field
          }
        }
      }
    }

    dynamic "eventbridge_parameters" {
      for_each = each.value.target.eventbridge_parameters != null ? [each.value.target.eventbridge_parameters] : []
      content {
        detail_type = eventbridge_parameters.value.detail_type
        source      = eventbridge_parameters.value.source
      }
    }

    dynamic "kinesis_parameters" {
      for_each = each.value.target.kinesis_parameters != null ? [each.value.target.kinesis_parameters] : []
      content {
        partition_key = kinesis_parameters.value.partition_key
      }
    }

    dynamic "sagemaker_pipeline_parameters" {
      for_each = each.value.target.sagemaker_pipeline_parameters != null ? [each.value.target.sagemaker_pipeline_parameters] : []
      content {
        dynamic "pipeline_parameter" {
          for_each = sagemaker_pipeline_parameters.value.pipeline_parameter_list
          content {
            name  = pipeline_parameter.value.name
            value = pipeline_parameter.value.value
          }
        }
      }
    }

    dynamic "sqs_parameters" {
      for_each = each.value.target.sqs_parameters != null ? [each.value.target.sqs_parameters] : []
      content {
        message_group_id = sqs_parameters.value.message_group_id
      }
    }
  }
}
