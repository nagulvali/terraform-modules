# VPC
resource "aws_vpc" "this" {
  count    = var.vpc.create ? 1 : 0
  cidr_block                           = var.vpc.cidr_block
  instance_tenancy                     = var.vpc.instance_tenancy
  enable_dns_support                   = var.vpc.enable_dns_support
  enable_dns_hostnames                 = var.vpc.enable_dns_hostnames
  ipv4_ipam_pool_id                    = var.vpc.ipv4_ipam_pool_id
  ipv4_netmask_length                  = var.vpc.ipv4_netmask_length
  enable_network_address_usage_metrics = var.vpc.enable_network_address_usage_metrics
  tags                                 = merge(var.vpc.tags, var.tags)
}

locals {
  vpc_id = var.vpc_id != null ? var.vpc_id : aws_vpc.this[0].id
}

# Subnets
resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = local.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = lookup(each.value, "availability_zone", null)
  map_public_ip_on_launch = lookup(each.value, "map_public_ip_on_launch", false)

  private_dns_hostname_type_on_launch = lookup(each.value, "private_dns_hostname_type_on_launch", "ip-name")

  tags = merge({
    Name = each.key
  }, lookup(each.value, "tags", {}))
}

# internet gateway
resource "aws_internet_gateway" "this" {
  count = var.igw.create ? 1 : 0

  vpc_id = try(lookup(var.igw, "vpc_id", local.vpc_id), null)

  tags = merge({
    Name = "${aws_vpc.this[0].tags["Name"]}-igw"
  }, var.tags)
}

# route tables
resource "aws_route_table" "this" {
  for_each = var.route_tables

  vpc_id = each.value.vpc_id != null ? each.value.vpc_id : local.vpc_id # fallback logic

  tags = merge(
    {
      Name = each.key
    },
    try(each.value.tags, {}),
    var.tags
  )
}

locals {
  routes = merge([
    for table_name, table in var.route_tables : {
      for idx, route in table.routes : "${table_name}-${idx}" => {
        table_name = table_name
        route      = route
      }
    }
  ]...)

  igw = aws_internet_gateway.this[0].id
}




## routes and route associations implement last

# # routes
# resource "aws_route" "this" {
#   for_each = local.routes
#
#   route_table_id = aws_route_table.this[each.value.table_name].id
#
#   # Destination preference
#   destination_cidr_block      = try(each.value.route.destination_cidr_block, null)
#   destination_ipv6_cidr_block = try(each.value.route.destination_ipv6_cidr_block, null)
#   destination_prefix_list_id = (
#     !contains(keys(each.value.route), "destination_cidr_block") &&
#     contains(keys(each.value.route), "destination_prefix_list_id")
#   ) ? each.value.route.destination_prefix_list_id : null
#
#   # Target preference resolution
#   gateway_id = (
#     try(each.value.route.local, false) == true ? "local" :
#     try(each.value.route.igw_id, null) != null ? each.value.route.igw_id :
#     try(each.value.route.igw, false) == true ? local.igw :
#     try(each.value.route.virtual_private_gateway_id, null) != null ? each.value.route.virtual_private_gateway_id :
#     try(each.value.route.virtual_private_gateway_ref_key, null) != null ? lookup(local.vpg_map, each.value.route.virtual_private_gateway_ref_key, null) :
#     null
#   )
#
#   nat_gateway_id = try(each.value.route.nat_gateway_id, null) != null ? each.value.route.nat_gateway_id : (
#     try(each.value.route.nat_gateway_ref_key, null) != null ? lookup(local.nat_gateway_map, each.value.route.nat_gateway_ref_key, null) : null
#   )
#
#   transit_gateway_id = try(each.value.route.transit_gateway_id, null) != null ? each.value.route.transit_gateway_id : try(each.value.route.transit_gateway_ref_key, null) != null ? lookup(local.transit_gateway_map, each.value.route.transit_gateway_ref_key, null) : null
#
#   vpc_endpoint_id = try(each.value.route.vpc_endpoint_id, null) != null ? each.value.route.vpc_endpoint_id : try(each.value.route.vpc_endpoint_ref_key, null) != null ? lookup(local.vpc_endpoint_map, each.value.route.vpc_endpoint_ref_key, null) : null
#
#   vpc_peering_connection_id = try(each.value.route.vpc_peering_connection_id, null)
#   local_gateway_id          = try(each.value.route.local_gateway_id, null)
#   network_interface_id      = try(each.value.route.network_interface_id, null)
#   core_network_arn          = try(each.value.route.core_network_arn, null)
#   carrier_gateway_id        = try(each.value.route.carrier_gateway_id, null)
# }
#
# locals {
#   route_table_associations = flatten([
#     for rt_name, rt in var.route_tables : [
#       for subnet_id in rt.subnet_ids : {
#         rt_name   = rt_name
#         subnet_id = subnet_id
#       }
#       ] + [
#       for ref_key in rt.subnet_ref_keys : {
#         rt_name   = rt_name
#         subnet_id = aws_subnet.this[ref_key].id
#       }
#     ]
#   ])
# }
#
# # route associations
# resource "aws_route_table_association" "this" {
#   for_each = {
#     for assoc in local.route_table_associations :
#     "${assoc.rt_name}-${assoc.subnet_id}" => assoc
#   }
#
#   subnet_id      = each.value.subnet_id
#   route_table_id = aws_route_table.this[each.value.rt_name].id
# }