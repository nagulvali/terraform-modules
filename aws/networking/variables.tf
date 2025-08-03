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

variable "subnets" {
  description = "AWS VPC Subnets"
  type = object({
    create = optional(bool, false)
    vpc_id = optional(string, null)
    subnet_configs = map(object({
      cidr_block                          = string
      availability_zone                   = optional(string)
      map_public_ip_on_launch             = optional(bool, false)
      region                              = optional(string)
      private_dns_hostname_type_on_launch = optional(string, "ip-name")
      tags                                = optional(map(string), {})
    }))
  })
  default = {
    create         = false
    subnet_configs = {}
  }
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