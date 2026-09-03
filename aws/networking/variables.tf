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
# VPCs
# ------------------------------------------------------------------------------
variable "vpcs" {
  description = "Map of VPCs to create, keyed by name. Use the key to reference in downstream resources."
  type = map(object({
    cidr_block                           = string
    instance_tenancy                     = optional(string, "default")
    enable_dns_support                   = optional(bool, true)
    enable_dns_hostnames                 = optional(bool, true)
    ipv4_ipam_pool_id                    = optional(string)
    ipv4_netmask_length                  = optional(number)
    enable_network_address_usage_metrics = optional(bool, false)
    tags                                 = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Subnets
# ------------------------------------------------------------------------------
variable "subnets" {
  description = "Map of subnets to create, keyed by name. Use vpc_ref_key to reference a VPC created in this module, or vpc_id for external VPC."
  type = map(object({
    vpc_ref_key                         = optional(string)
    vpc_id                              = optional(string)
    cidr_block                          = string
    availability_zone                   = optional(string)
    map_public_ip_on_launch             = optional(bool, false)
    private_dns_hostname_type_on_launch = optional(string, "ip-name")
    tags                                = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.subnets : (v.vpc_ref_key != null) != (v.vpc_id != null)
    ])
    error_message = "Each subnet must specify exactly one of vpc_ref_key or vpc_id."
  }
}

# ------------------------------------------------------------------------------
# Internet Gateways
# ------------------------------------------------------------------------------
variable "internet_gateways" {
  description = "Map of Internet Gateways to create, keyed by name. Use vpc_ref_key to reference a VPC created in this module, or vpc_id for external VPC."
  type = map(object({
    vpc_ref_key = optional(string)
    vpc_id      = optional(string)
    tags        = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.internet_gateways : (v.vpc_ref_key != null) != (v.vpc_id != null)
    ])
    error_message = "Each internet gateway must specify exactly one of vpc_ref_key or vpc_id."
  }
}

# ------------------------------------------------------------------------------
# Elastic IPs
# ------------------------------------------------------------------------------
variable "elastic_ips" {
  description = "Map of Elastic IPs to create, keyed by name. Typically used for NAT Gateways."
  type = map(object({
    domain               = optional(string, "vpc")
    public_ipv4_pool     = optional(string)
    network_border_group = optional(string)
    tags                 = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# NAT Gateways
# ------------------------------------------------------------------------------
variable "nat_gateways" {
  description = "Map of NAT Gateways to create, keyed by name. Use subnet_ref_key and eip_ref_key to reference resources created in this module."
  type = map(object({
    subnet_ref_key           = optional(string)
    subnet_id                = optional(string)
    eip_ref_key              = optional(string)
    allocation_id            = optional(string)
    connectivity_type        = optional(string, "public")
    private_ip               = optional(string)
    secondary_allocation_ids = optional(list(string), [])
    tags                     = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.nat_gateways : (v.subnet_ref_key != null) != (v.subnet_id != null)
    ])
    error_message = "Each NAT gateway must specify exactly one of subnet_ref_key or subnet_id."
  }

  validation {
    condition = alltrue([
      for k, v in var.nat_gateways :
      v.connectivity_type == "private" || (v.eip_ref_key != null) != (v.allocation_id != null)
    ])
    error_message = "Each public NAT gateway must specify exactly one of eip_ref_key or allocation_id."
  }
}

# ------------------------------------------------------------------------------
# Route Tables
# ------------------------------------------------------------------------------
variable "route_tables" {
  description = "Map of route tables keyed by name. Use vpc_ref_key to reference a VPC created in this module."
  type = map(object({
    vpc_ref_key = optional(string)
    vpc_id      = optional(string)
    tags        = optional(map(string), {})

    routes = optional(list(object({
      destination_cidr_block      = optional(string)
      destination_ipv6_cidr_block = optional(string)
      destination_prefix_list_id  = optional(string)

      # Target - specify exactly one
      gateway_id                = optional(string)
      igw_ref_key               = optional(string)
      nat_gateway_id            = optional(string)
      nat_gateway_ref_key       = optional(string)
      transit_gateway_id        = optional(string)
      vpc_endpoint_id           = optional(string)
      vpc_endpoint_ref_key      = optional(string)
      vpc_peering_connection_id = optional(string)
      local_gateway_id          = optional(string)
      network_interface_id      = optional(string)
      core_network_arn          = optional(string)
      carrier_gateway_id        = optional(string)
    })), [])

    subnet_associations = optional(list(object({
      subnet_ref_key = optional(string)
      subnet_id      = optional(string)
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.route_tables : (v.vpc_ref_key != null) != (v.vpc_id != null)
    ])
    error_message = "Each route table must specify exactly one of vpc_ref_key or vpc_id."
  }
}

# ------------------------------------------------------------------------------
# VPC Endpoints
# ------------------------------------------------------------------------------
variable "vpc_endpoints" {
  description = "Map of VPC Endpoints to create, keyed by name. Use vpc_ref_key, subnet_ref_keys, and route_table_ref_keys to reference resources created in this module."
  type = map(object({
    vpc_ref_key         = optional(string)
    vpc_id              = optional(string)
    service_name        = string
    vpc_endpoint_type   = optional(string, "Gateway")
    auto_accept         = optional(bool, true)
    private_dns_enabled = optional(bool, false)
    ip_address_type     = optional(string)
    policy              = optional(string)

    # For Interface endpoints
    subnet_ref_keys    = optional(list(string), [])
    subnet_ids         = optional(list(string), [])
    security_group_ids = optional(list(string), [])

    # For Gateway endpoints
    route_table_ref_keys = optional(list(string), [])
    route_table_ids      = optional(list(string), [])

    dns_options = optional(object({
      dns_record_ip_type                             = optional(string)
      private_dns_only_for_inbound_resolver_endpoint = optional(bool)
    }))

    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.vpc_endpoints : (v.vpc_ref_key != null) != (v.vpc_id != null)
    ])
    error_message = "Each VPC endpoint must specify exactly one of vpc_ref_key or vpc_id."
  }
}
