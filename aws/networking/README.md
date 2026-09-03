# AWS Networking Module

Terraform module for creating AWS networking resources with a consistent key-based reference pattern.

## Design Pattern

This module uses a **key-based reference pattern** where:
1. Resources are defined as maps keyed by name
2. Downstream resources reference upstream resources using `*_ref_key` attributes
3. This allows multiple VPCs and their associated resources to be managed together

## Resources Supported

| Resource | Variable | Reference Key |
|----------|----------|---------------|
| VPC | `vpcs` | Key used as `vpc_ref_key` |
| Subnet | `subnets` | Key used as `subnet_ref_key` |
| Internet Gateway | `internet_gateways` | Key used as `igw_ref_key` |
| Elastic IP | `elastic_ips` | Key used as `eip_ref_key` |
| NAT Gateway | `nat_gateways` | Key used as `nat_gateway_ref_key` |
| Route Table | `route_tables` | Key used as `route_table_ref_keys` |
| VPC Endpoint | `vpc_endpoints` | Key used as `vpc_endpoint_ref_key` |

## Usage

```hcl
module "networking" {
  source = "./aws/networking"

  region = "us-east-1"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }

  # Multiple VPCs
  vpcs = {
    main = {
      cidr_block         = "10.0.0.0/16"
      enable_dns_support = true
    }
    
    secondary = {
      cidr_block         = "10.1.0.0/16"
      enable_dns_support = true
    }
  }

  # Subnets reference VPCs by key
  subnets = {
    main-public-1a = {
      vpc_ref_key             = "main"
      cidr_block              = "10.0.0.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
    }
    
    main-private-1a = {
      vpc_ref_key       = "main"
      cidr_block        = "10.0.10.0/24"
      availability_zone = "us-east-1a"
    }
  }

  # Internet Gateways reference VPCs by key
  internet_gateways = {
    main-igw = {
      vpc_ref_key = "main"
    }
  }

  # Elastic IPs for NAT Gateways
  elastic_ips = {
    nat-eip-1a = {}
  }

  # NAT Gateways reference subnets and EIPs by key
  nat_gateways = {
    main-nat-1a = {
      subnet_ref_key = "main-public-1a"
      eip_ref_key    = "nat-eip-1a"
    }
  }

  # Route Tables with routes and associations
  route_tables = {
    main-public = {
      vpc_ref_key = "main"
      routes = [
        {
          destination_cidr_block = "0.0.0.0/0"
          igw_ref_key            = "main-igw"
        }
      ]
      subnet_associations = [
        { subnet_ref_key = "main-public-1a" }
      ]
    }

    main-private = {
      vpc_ref_key = "main"
      routes = [
        {
          destination_cidr_block = "0.0.0.0/0"
          nat_gateway_ref_key    = "main-nat-1a"
        }
      ]
      subnet_associations = [
        { subnet_ref_key = "main-private-1a" }
      ]
    }
  }

  # VPC Endpoints
  vpc_endpoints = {
    s3 = {
      vpc_ref_key          = "main"
      service_name         = "com.amazonaws.us-east-1.s3"
      vpc_endpoint_type    = "Gateway"
      route_table_ref_keys = ["main-public", "main-private"]
    }
  }
}
```

## Reference Keys vs Direct IDs

Each resource supports both reference keys (for resources in this module) and direct IDs (for external resources):

| Resource | Ref Key Attribute | Direct ID Attribute |
|----------|-------------------|---------------------|
| VPC | `vpc_ref_key` | `vpc_id` |
| Subnet | `subnet_ref_key` | `subnet_id` |
| IGW | `igw_ref_key` | `gateway_id` |
| EIP | `eip_ref_key` | `allocation_id` |
| NAT Gateway | `nat_gateway_ref_key` | `nat_gateway_id` |
| Route Table | `route_table_ref_keys` | `route_table_ids` |
| VPC Endpoint | `vpc_endpoint_ref_key` | `vpc_endpoint_id` |

## Outputs

| Output | Description |
|--------|-------------|
| `vpcs` | Map of all VPCs created |
| `vpc_ids` | Map of VPC IDs by key |
| `subnets` | Map of all subnets created |
| `subnet_ids` | Map of subnet IDs by key |
| `subnets_by_vpc` | Subnet IDs grouped by VPC key |
| `internet_gateways` | Map of all IGWs created |
| `elastic_ips` | Map of all EIPs created |
| `nat_gateways` | Map of all NAT Gateways created |
| `route_tables` | Map of all route tables created |
| `vpc_endpoints` | Map of all VPC endpoints created |

## Validation

The module includes built-in validation to ensure:
- Each subnet specifies exactly one of `vpc_ref_key` or `vpc_id`
- Each route table specifies exactly one of `vpc_ref_key` or `vpc_id`
- Each NAT gateway specifies exactly one of `subnet_ref_key` or `subnet_id`
- Public NAT gateways specify exactly one of `eip_ref_key` or `allocation_id`
