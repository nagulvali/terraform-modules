variable "region" {
  description = "AWS region where the VPC will be created"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc" {
  description = "VPC configuration block"
  type = object({
    create                               = optional(bool, false)
    cidr_block                           = string
    instance_tenancy                     = string
    enable_dns_support                   = bool
    enable_dns_hostnames                 = bool
    ipv4_ipam_pool_id                    = optional(string)
    ipv4_netmask_length                  = optional(number)
    enable_network_address_usage_metrics = optional(bool)
    tags                                 = optional(map(string))
  })
  default = {
    create                               = false
    cidr_block                           = ""
    instance_tenancy                     = "default"
    enable_dns_support                   = false
    enable_dns_hostnames                 = false
    ipv4_ipam_pool_id                    = null
    ipv4_netmask_length                  = null
    enable_network_address_usage_metrics = null
    tags                                 = {}
  }
}

variable "vpc_id" {
  description = "Optionally provide an existing VPC ID to use incase vpc is not created as part of this module"
  type        = string
  default     = null
}

variable "subnets" {
  description = "AWS VPC Subnets"
  type =  map(object({
      cidr_block                          = string
      availability_zone                   = optional(string)
      map_public_ip_on_launch             = optional(bool, false)
      region                              = optional(string)
      private_dns_hostname_type_on_launch = optional(string, "ip-name")
      tags                                = optional(map(string), {})
    }))

  default = null
}

variable "igw" {
  description = "Internet Gateway configuration block"
  type = object({
    create = optional(bool, false)
    vpc_id = optional(string, null)
    tags   = optional(map(string), {})
  })
  default = {
    create = false
    vpc_id = null
    tags   = {}
  }
}

variable "route_tables" {
  description = "Map of route tables keyed by name. Each defines vpc_id, routes, and optional subnet associations."
  type = map(object({
    vpc_id = optional(string)
    routes = list(object({
      destination_cidr_block      = optional(string)
      destination_ipv6_cidr_block = optional(string)
      destination_prefix_list_id  = optional(string)

      igw    = optional(bool)
      igw_id = optional(string)
      local  = optional(bool)

      nat_gateway_id      = optional(string)
      nat_gateway_ref_key = optional(string)

      transit_gateway_id      = optional(string)
      transit_gateway_ref_key = optional(string)

      vpc_endpoint_id      = optional(string)
      vpc_endpoint_ref_key = optional(string)

      vpc_peering_connection_id       = optional(string)
      virtual_private_gateway_id      = optional(string)
      virtual_private_gateway_ref_key = optional(string)

      local_gateway_id     = optional(string)
      network_interface_id = optional(string)
      core_network_arn     = optional(string)
      carrier_gateway_id   = optional(string)
    }))
    subnet_ref_keys = optional(list(string), [])
    subnet_ids      = optional(list(string), [])
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for table in values(var.route_tables) : [
        for route in table.routes : (
          length(compact([
            tostring(try(route.igw, null)),
            try(route.igw_id, null),
            tostring(try(route.local, null)),

            try(route.nat_gateway_id, null),
            try(route.nat_gateway_ref_key, null),

            try(route.transit_gateway_id, null),
            try(route.transit_gateway_ref_key, null),

            try(route.vpc_endpoint_id, null),
            try(route.vpc_endpoint_ref_key, null),

            try(route.vpc_peering_connection_id, null),
            try(route.virtual_private_gateway_id, null),
            try(route.virtual_private_gateway_ref_key, null),

            try(route.local_gateway_id, null),
            try(route.network_interface_id, null),
            try(route.core_network_arn, null),
            try(route.carrier_gateway_id, null)
          ])) == 1
        )
      ]
    ]))
    error_message = "Each route must specify exactly ONE route target (e.g., igw, nat_gateway_ref_key, transit_gateway_id, etc.)."
  }
}