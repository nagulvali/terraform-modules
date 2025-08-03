locals {
  # Determine final VPC ID to use
  final_vpc_id = (
    var.subnets.vpc_id != null && var.subnets.vpc_id != "" ? var.subnets.vpc_id :
    (try(aws_vpc.this[0].id, null) != null ? aws_vpc.this[0].id : null)
  )
}

# Validation - throw error if final_vpc_id is still null
resource "null_resource" "fail_if_no_vpc_id" {
  count = local.final_vpc_id == null ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'Error: VPC ID must be provided via var.subnets.vpc_id or created via aws_vpc.this' && exit 1"
  }
}

resource "aws_vpc" "this" {
  count                                = var.vpc.create ? 1 : 0
  cidr_block                           = var.vpc.cidr_block
  instance_tenancy                     = var.vpc.instance_tenancy
  enable_dns_support                   = var.vpc.enable_dns_support
  enable_dns_hostnames                 = var.vpc.enable_dns_hostnames
  ipv4_ipam_pool_id                    = var.vpc.ipv4_ipam_pool_id
  ipv4_netmask_length                  = var.vpc.ipv4_netmask_length
  enable_network_address_usage_metrics = var.vpc.enable_network_address_usage_metrics
  tags                                 = merge(var.vpc.tags, var.tags)
}


resource "aws_subnet" "this" {
  for_each = var.subnets.create ? var.subnets.subnet_configs : {}

  vpc_id                  = local.final_vpc_id
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

  vpc_id = try(lookup(var.igw, "vpc_id", aws_vpc.this[0].id), null)

  tags = merge({
    Name = "${aws_vpc.this[0].tags["Name"]}-igw"
  }, var.tags)
}

# route tables
resource "aws_route_table" "this" {
  for_each = var.route_tables.create ? var.route_tables.tables : {}

  vpc_id = try(lookup(var.route_tables, "vpc_id", aws_vpc.this[0].id), null)

  tags = merge(
    {
      Name = each.key
    }
  )
}

resource "aws_route" "this" {
  for_each = {
    for rt in var.route_tables : rt.name => rt
  }

  count = length(each.value.routes)

  route_table_id = aws_route_table.this[each.key].id

  # Routing options - only one should be set per route
  destination_cidr_block              = try(each.value.routes[count.index].destination_cidr_block, null)
  destination_ipv6_cidr_block        = try(each.value.routes[count.index].destination_ipv6_cidr_block, null)
  destination_prefix_list_id         = try(each.value.routes[count.index].destination_prefix_list_id, null)

  carrier_gateway_id                 = try(each.value.routes[count.index].carrier_gateway_id, null)
  core_network_arn                   = try(each.value.routes[count.index].core_network_arn, null)
  egress_only_gateway_id             = try(each.value.routes[count.index].egress_only_gateway_id, null)
  gateway_id                         = try(each.value.routes[count.index].gateway_id, null)
  local_gateway_id                   = try(each.value.routes[count.index].local_gateway_id, null)
  nat_gateway_id                     = try(each.value.routes[count.index].nat_gateway_id, null)
  network_interface_id               = try(each.value.routes[count.index].network_interface_id, null)
  transit_gateway_id                 = try(each.value.routes[count.index].transit_gateway_id, null)
  vpc_endpoint_id                    = try(each.value.routes[count.index].vpc_endpoint_id, null)
  vpc_peering_connection_id          = try(each.value.routes[count.index].vpc_peering_connection_id, null)
}
