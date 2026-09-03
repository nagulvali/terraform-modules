# ==============================================================================
# Naming Convention
# ==============================================================================
output "name_prefix" {
  description = "Name prefix used for all resources"
  value       = var.name_prefix
}

output "name_suffix" {
  description = "Name suffix used for all resources"
  value       = var.name_suffix
}

# ==============================================================================
# VPCs
# ==============================================================================
output "vpcs" {
  description = "Map of all VPCs created, keyed by ref_key"
  value       = aws_vpc.this
}

output "vpc_ids" {
  description = "Map of VPC IDs, keyed by ref_key"
  value       = { for k, v in aws_vpc.this : k => v.id }
}

output "vpc_names" {
  description = "Map of VPC Names (with prefix/suffix applied), keyed by ref_key"
  value       = local.vpc_names
}

# ==============================================================================
# Subnets
# ==============================================================================
output "subnets" {
  description = "Map of all subnets created, keyed by ref_key"
  value       = aws_subnet.this
}

output "subnet_ids" {
  description = "Map of subnet IDs, keyed by ref_key"
  value       = { for k, v in aws_subnet.this : k => v.id }
}

output "subnet_names" {
  description = "Map of subnet Names (with prefix/suffix applied), keyed by ref_key"
  value       = local.subnet_names
}

output "subnets_by_vpc" {
  description = "Map of subnet IDs grouped by VPC ref_key"
  value = {
    for vpc_key in keys(var.vpcs) : vpc_key => {
      for subnet_key, subnet in aws_subnet.this :
      subnet_key => subnet.id
      if try(var.subnets[subnet_key].vpc_ref_key, null) == vpc_key
    }
  }
}

# ==============================================================================
# Internet Gateways
# ==============================================================================
output "internet_gateways" {
  description = "Map of all Internet Gateways created, keyed by ref_key"
  value       = aws_internet_gateway.this
}

output "internet_gateway_ids" {
  description = "Map of Internet Gateway IDs, keyed by ref_key"
  value       = { for k, v in aws_internet_gateway.this : k => v.id }
}

output "internet_gateway_names" {
  description = "Map of Internet Gateway Names (with prefix/suffix applied), keyed by ref_key"
  value       = local.igw_names
}

# ==============================================================================
# Elastic IPs
# ==============================================================================
output "elastic_ips" {
  description = "Map of all Elastic IPs created, keyed by ref_key"
  value       = aws_eip.this
}

output "elastic_ip_ids" {
  description = "Map of Elastic IP allocation IDs, keyed by ref_key"
  value       = { for k, v in aws_eip.this : k => v.id }
}

output "elastic_ip_names" {
  description = "Map of Elastic IP Names (with prefix/suffix applied), keyed by ref_key"
  value       = local.eip_names
}

output "elastic_ip_public_ips" {
  description = "Map of Elastic IP public addresses, keyed by ref_key"
  value       = { for k, v in aws_eip.this : k => v.public_ip }
}

# ==============================================================================
# NAT Gateways
# ==============================================================================
output "nat_gateways" {
  description = "Map of all NAT Gateways created, keyed by ref_key"
  value       = aws_nat_gateway.this
}

output "nat_gateway_ids" {
  description = "Map of NAT Gateway IDs, keyed by ref_key"
  value       = { for k, v in aws_nat_gateway.this : k => v.id }
}

output "nat_gateway_names" {
  description = "Map of NAT Gateway Names (with prefix/suffix applied), keyed by ref_key"
  value       = local.nat_gateway_names
}

output "nat_gateway_public_ips" {
  description = "Map of NAT Gateway public IPs, keyed by ref_key"
  value       = { for k, v in aws_nat_gateway.this : k => v.public_ip }
}

# ==============================================================================
# Route Tables
# ==============================================================================
output "route_tables" {
  description = "Map of all Route Tables created, keyed by ref_key"
  value       = aws_route_table.this
}

output "route_table_ids" {
  description = "Map of Route Table IDs, keyed by ref_key"
  value       = { for k, v in aws_route_table.this : k => v.id }
}

output "route_table_names" {
  description = "Map of Route Table Names (with prefix/suffix applied), keyed by ref_key"
  value       = local.route_table_names
}

output "routes" {
  description = "Map of all routes created"
  value       = aws_route.this
}

output "route_table_associations" {
  description = "Map of all route table associations created"
  value       = aws_route_table_association.this
}

# ==============================================================================
# VPC Endpoints
# ==============================================================================
output "vpc_endpoints" {
  description = "Map of all VPC Endpoints created, keyed by ref_key"
  value       = aws_vpc_endpoint.this
}

output "vpc_endpoint_ids" {
  description = "Map of VPC Endpoint IDs, keyed by ref_key"
  value       = { for k, v in aws_vpc_endpoint.this : k => v.id }
}

output "vpc_endpoint_names" {
  description = "Map of VPC Endpoint Names (with prefix/suffix applied), keyed by ref_key"
  value       = local.vpc_endpoint_names
}

output "vpc_endpoint_dns_entries" {
  description = "Map of VPC Endpoint DNS entries, keyed by ref_key"
  value       = { for k, v in aws_vpc_endpoint.this : k => v.dns_entry }
}
