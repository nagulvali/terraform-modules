# ==============================================================================
# VPCs
# ==============================================================================
resource "aws_vpc" "this" {
  for_each = var.vpcs

  cidr_block                           = each.value.cidr_block
  instance_tenancy                     = each.value.instance_tenancy
  enable_dns_support                   = each.value.enable_dns_support
  enable_dns_hostnames                 = each.value.enable_dns_hostnames
  ipv4_ipam_pool_id                    = each.value.ipv4_ipam_pool_id
  ipv4_netmask_length                  = each.value.ipv4_netmask_length
  enable_network_address_usage_metrics = each.value.enable_network_address_usage_metrics

  tags = merge(
    { Name = each.key },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Subnets
# ==============================================================================
resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id = each.value.vpc_ref_key != null ? aws_vpc.this[each.value.vpc_ref_key].id : each.value.vpc_id

  cidr_block                          = each.value.cidr_block
  availability_zone                   = each.value.availability_zone
  map_public_ip_on_launch             = each.value.map_public_ip_on_launch
  private_dns_hostname_type_on_launch = each.value.private_dns_hostname_type_on_launch

  tags = merge(
    { Name = each.key },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Internet Gateways
# ==============================================================================
resource "aws_internet_gateway" "this" {
  for_each = var.internet_gateways

  vpc_id = each.value.vpc_ref_key != null ? aws_vpc.this[each.value.vpc_ref_key].id : each.value.vpc_id

  tags = merge(
    { Name = each.key },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# Elastic IPs
# ==============================================================================
resource "aws_eip" "this" {
  for_each = var.elastic_ips

  domain               = each.value.domain
  public_ipv4_pool     = each.value.public_ipv4_pool
  network_border_group = each.value.network_border_group

  tags = merge(
    { Name = each.key },
    each.value.tags,
    var.tags
  )
}

# ==============================================================================
# NAT Gateways
# ==============================================================================
resource "aws_nat_gateway" "this" {
  for_each = var.nat_gateways

  subnet_id = each.value.subnet_ref_key != null ? aws_subnet.this[each.value.subnet_ref_key].id : each.value.subnet_id
  allocation_id = each.value.connectivity_type == "private" ? null : (
    each.value.eip_ref_key != null ? aws_eip.this[each.value.eip_ref_key].id : each.value.allocation_id
  )
  connectivity_type        = each.value.connectivity_type
  private_ip               = each.value.private_ip
  secondary_allocation_ids = each.value.secondary_allocation_ids

  tags = merge(
    { Name = each.key },
    each.value.tags,
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

# ==============================================================================
# Route Tables
# ==============================================================================
resource "aws_route_table" "this" {
  for_each = var.route_tables

  vpc_id = each.value.vpc_ref_key != null ? aws_vpc.this[each.value.vpc_ref_key].id : each.value.vpc_id

  tags = merge(
    { Name = each.key },
    each.value.tags,
    var.tags
  )
}

# ------------------------------------------------------------------------------
# Routes
# ------------------------------------------------------------------------------
locals {
  routes = merge([
    for table_key, table in var.route_tables : {
      for idx, route in table.routes : "${table_key}/${idx}" => {
        route_table_key = table_key
        route           = route
      }
    }
  ]...)
}

resource "aws_route" "this" {
  for_each = local.routes

  route_table_id = aws_route_table.this[each.value.route_table_key].id

  # Destination
  destination_cidr_block      = each.value.route.destination_cidr_block
  destination_ipv6_cidr_block = each.value.route.destination_ipv6_cidr_block
  destination_prefix_list_id  = each.value.route.destination_prefix_list_id

  # Target - resolve ref_keys to actual IDs
  gateway_id = coalesce(
    each.value.route.gateway_id,
    each.value.route.igw_ref_key != null ? aws_internet_gateway.this[each.value.route.igw_ref_key].id : null
  )

  nat_gateway_id = coalesce(
    each.value.route.nat_gateway_id,
    each.value.route.nat_gateway_ref_key != null ? aws_nat_gateway.this[each.value.route.nat_gateway_ref_key].id : null
  )

  transit_gateway_id = each.value.route.transit_gateway_id

  vpc_endpoint_id = coalesce(
    each.value.route.vpc_endpoint_id,
    each.value.route.vpc_endpoint_ref_key != null ? aws_vpc_endpoint.this[each.value.route.vpc_endpoint_ref_key].id : null
  )

  vpc_peering_connection_id = each.value.route.vpc_peering_connection_id
  local_gateway_id          = each.value.route.local_gateway_id
  network_interface_id      = each.value.route.network_interface_id
  core_network_arn          = each.value.route.core_network_arn
  carrier_gateway_id        = each.value.route.carrier_gateway_id
}

# ------------------------------------------------------------------------------
# Route Table Associations
# ------------------------------------------------------------------------------
locals {
  route_table_associations = merge([
    for table_key, table in var.route_tables : {
      for idx, assoc in table.subnet_associations : "${table_key}/${idx}" => {
        route_table_key = table_key
        subnet_ref_key  = assoc.subnet_ref_key
        subnet_id       = assoc.subnet_id
      }
    }
  ]...)
}

resource "aws_route_table_association" "this" {
  for_each = local.route_table_associations

  route_table_id = aws_route_table.this[each.value.route_table_key].id
  subnet_id      = each.value.subnet_ref_key != null ? aws_subnet.this[each.value.subnet_ref_key].id : each.value.subnet_id
}

# ==============================================================================
# VPC Endpoints
# ==============================================================================
resource "aws_vpc_endpoint" "this" {
  for_each = var.vpc_endpoints

  vpc_id            = each.value.vpc_ref_key != null ? aws_vpc.this[each.value.vpc_ref_key].id : each.value.vpc_id
  service_name      = each.value.service_name
  vpc_endpoint_type = each.value.vpc_endpoint_type
  auto_accept       = each.value.auto_accept
  policy            = each.value.policy
  ip_address_type   = each.value.ip_address_type

  # Interface endpoint settings
  private_dns_enabled = each.value.vpc_endpoint_type == "Interface" ? each.value.private_dns_enabled : null

  subnet_ids = each.value.vpc_endpoint_type == "Interface" ? concat(
    [for ref_key in each.value.subnet_ref_keys : aws_subnet.this[ref_key].id],
    each.value.subnet_ids
  ) : null

  security_group_ids = each.value.vpc_endpoint_type == "Interface" ? each.value.security_group_ids : null

  # Gateway endpoint settings
  route_table_ids = each.value.vpc_endpoint_type == "Gateway" ? concat(
    [for ref_key in each.value.route_table_ref_keys : aws_route_table.this[ref_key].id],
    each.value.route_table_ids
  ) : null

  dynamic "dns_options" {
    for_each = each.value.dns_options != null ? [each.value.dns_options] : []
    content {
      dns_record_ip_type                             = dns_options.value.dns_record_ip_type
      private_dns_only_for_inbound_resolver_endpoint = dns_options.value.private_dns_only_for_inbound_resolver_endpoint
    }
  }

  tags = merge(
    { Name = each.key },
    each.value.tags,
    var.tags
  )
}
