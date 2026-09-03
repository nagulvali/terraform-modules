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
# Event Buses
# ------------------------------------------------------------------------------
variable "buses" {
  description = "Map of EventBridge event buses to create, keyed by ref_key."
  type = map(object({
    event_source_name = optional(string)
    tags              = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Event Bus Permissions
# ------------------------------------------------------------------------------
variable "bus_permissions" {
  description = "Map of event bus permissions to create, keyed by ref_key."
  type = map(object({
    bus_ref_key    = optional(string)
    event_bus_name = optional(string)
    principal      = optional(string)
    statement_id   = string
    action         = optional(string, "events:PutEvents")

    condition = optional(object({
      key   = string
      type  = string
      value = string
    }))
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Event Rules
# ------------------------------------------------------------------------------
variable "rules" {
  description = "Map of EventBridge rules to create, keyed by ref_key."
  type = map(object({
    description         = optional(string)
    bus_ref_key         = optional(string)
    event_bus_name      = optional(string)
    event_pattern       = optional(string)
    schedule_expression = optional(string)
    role_arn            = optional(string)
    is_enabled          = optional(bool, true)
    tags                = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Event Targets
# ------------------------------------------------------------------------------
variable "targets" {
  description = "Map of EventBridge targets to create, keyed by ref_key."
  type = map(object({
    rule_ref_key   = optional(string)
    rule_name      = optional(string)
    bus_ref_key    = optional(string)
    event_bus_name = optional(string)
    target_id      = string
    arn            = string
    role_arn       = optional(string)
    input          = optional(string)
    input_path     = optional(string)

    input_transformer = optional(object({
      input_paths    = optional(map(string), {})
      input_template = string
    }))

    retry_policy = optional(object({
      maximum_event_age_in_seconds = optional(number)
      maximum_retry_attempts       = optional(number)
    }))

    dead_letter_config = optional(object({
      arn = string
    }))

    run_command_targets = optional(list(object({
      key    = string
      values = list(string)
    })), [])

    ecs_target = optional(object({
      task_definition_arn     = string
      task_count              = optional(number, 1)
      launch_type             = optional(string)
      platform_version        = optional(string)
      group                   = optional(string)
      enable_execute_command  = optional(bool, false)
      enable_ecs_managed_tags = optional(bool, false)
      propagate_tags          = optional(string)
      tags                    = optional(map(string), {})

      network_configuration = optional(object({
        subnets          = list(string)
        security_groups  = optional(list(string), [])
        assign_public_ip = optional(bool, false)
      }))

      capacity_provider_strategy = optional(list(object({
        capacity_provider = string
        weight            = optional(number, 1)
        base              = optional(number, 0)
      })), [])

      placement_constraint = optional(list(object({
        type       = string
        expression = optional(string)
      })), [])
    }))

    batch_target = optional(object({
      job_definition = string
      job_name       = string
      array_size     = optional(number)
      job_attempts   = optional(number)
    }))

    kinesis_target = optional(object({
      partition_key_path = optional(string)
    }))

    sqs_target = optional(object({
      message_group_id = optional(string)
    }))

    http_target = optional(object({
      path_parameter_values   = optional(list(string), [])
      query_string_parameters = optional(map(string), {})
      header_parameters       = optional(map(string), {})
    }))

    redshift_target = optional(object({
      database            = string
      db_user             = optional(string)
      secrets_manager_arn = optional(string)
      sql                 = optional(string)
      statement_name      = optional(string)
      with_event          = optional(bool, false)
    }))

    sagemaker_pipeline_target = optional(object({
      pipeline_parameter_list = optional(list(object({
        name  = string
        value = string
      })), [])
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.targets : (v.rule_ref_key != null) != (v.rule_name != null)
    ])
    error_message = "Each target must specify exactly one of rule_ref_key or rule_name."
  }
}

# ------------------------------------------------------------------------------
# Event Archives
# ------------------------------------------------------------------------------
variable "archives" {
  description = "Map of EventBridge archives to create, keyed by ref_key."
  type = map(object({
    description      = optional(string)
    bus_ref_key      = optional(string)
    event_source_arn = optional(string)
    event_pattern    = optional(string)
    retention_days   = optional(number, 0)
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Connections (for API Destinations)
# ------------------------------------------------------------------------------
variable "connections" {
  description = "Map of EventBridge connections to create, keyed by ref_key."
  type = map(object({
    description        = optional(string)
    authorization_type = string

    auth_parameters = object({
      api_key = optional(object({
        key   = string
        value = string
      }))

      basic = optional(object({
        username = string
        password = string
      }))

      oauth = optional(object({
        authorization_endpoint = string
        http_method            = string
        client_parameters = optional(object({
          client_id     = string
          client_secret = string
        }))
        oauth_http_parameters = optional(object({
          body = optional(list(object({
            key             = string
            value           = optional(string)
            is_value_secret = optional(bool, false)
          })), [])
          header = optional(list(object({
            key             = string
            value           = optional(string)
            is_value_secret = optional(bool, false)
          })), [])
          query_string = optional(list(object({
            key             = string
            value           = optional(string)
            is_value_secret = optional(bool, false)
          })), [])
        }))
      }))

      invocation_http_parameters = optional(object({
        body = optional(list(object({
          key             = string
          value           = optional(string)
          is_value_secret = optional(bool, false)
        })), [])
        header = optional(list(object({
          key             = string
          value           = optional(string)
          is_value_secret = optional(bool, false)
        })), [])
        query_string = optional(list(object({
          key             = string
          value           = optional(string)
          is_value_secret = optional(bool, false)
        })), [])
      }))
    })
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# API Destinations
# ------------------------------------------------------------------------------
variable "api_destinations" {
  description = "Map of EventBridge API destinations to create, keyed by ref_key."
  type = map(object({
    description                      = optional(string)
    connection_ref_key               = optional(string)
    connection_arn                   = optional(string)
    invocation_endpoint              = string
    http_method                      = string
    invocation_rate_limit_per_second = optional(number, 300)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.api_destinations : (v.connection_ref_key != null) != (v.connection_arn != null)
    ])
    error_message = "Each API destination must specify exactly one of connection_ref_key or connection_arn."
  }
}

# ------------------------------------------------------------------------------
# EventBridge Scheduler - Schedule Groups
# ------------------------------------------------------------------------------
variable "schedule_groups" {
  description = "Map of EventBridge Scheduler schedule groups to create, keyed by ref_key."
  type = map(object({
    tags = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# EventBridge Scheduler - Schedules
# ------------------------------------------------------------------------------
variable "schedules" {
  description = "Map of EventBridge Scheduler schedules to create, keyed by ref_key."
  type = map(object({
    description                  = optional(string)
    group_ref_key                = optional(string)
    group_name                   = optional(string)
    schedule_expression          = string
    schedule_expression_timezone = optional(string, "UTC")
    state                        = optional(string, "ENABLED")
    start_date                   = optional(string)
    end_date                     = optional(string)

    flexible_time_window = object({
      mode                      = string
      maximum_window_in_minutes = optional(number)
    })

    target = object({
      arn      = string
      role_arn = string
      input    = optional(string)

      retry_policy = optional(object({
        maximum_event_age_in_seconds = optional(number)
        maximum_retry_attempts       = optional(number)
      }))

      dead_letter_config = optional(object({
        arn = string
      }))

      ecs_parameters = optional(object({
        task_definition_arn     = string
        task_count              = optional(number, 1)
        launch_type             = optional(string)
        platform_version        = optional(string)
        group                   = optional(string)
        enable_execute_command  = optional(bool, false)
        enable_ecs_managed_tags = optional(bool, false)
        propagate_tags          = optional(string)
        tags                    = optional(map(string), {})

        network_configuration = optional(object({
          subnets          = list(string)
          security_groups  = optional(list(string), [])
          assign_public_ip = optional(bool, false)
        }))

        capacity_provider_strategy = optional(list(object({
          capacity_provider = string
          weight            = optional(number, 1)
          base              = optional(number, 0)
        })), [])

        placement_constraint = optional(list(object({
          type       = string
          expression = optional(string)
        })), [])

        placement_strategy = optional(list(object({
          type  = string
          field = optional(string)
        })), [])
      }))

      eventbridge_parameters = optional(object({
        detail_type = string
        source      = string
      }))

      kinesis_parameters = optional(object({
        partition_key = string
      }))

      sagemaker_pipeline_parameters = optional(object({
        pipeline_parameter_list = optional(list(object({
          name  = string
          value = string
        })), [])
      }))

      sqs_parameters = optional(object({
        message_group_id = optional(string)
      }))
    })
  }))
  default = {}
}
