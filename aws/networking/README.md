# AWS Networking Module

Terraform module for creating AWS networking resources with a consistent key-based reference pattern and flexible naming convention.

## Design Pattern

This module uses a **key-based reference pattern** where:
1. Resources are defined as maps keyed by `ref_key`
2. Downstream resources reference upstream resources using `*_ref_key` attributes
3. Resource names follow the pattern: `{name_prefix}_{ref_key}_{name_suffix}`
4. Other modules reference by `ref_key` and fetch `name`, `id`, or other attributes

## Naming Convention

```
Pattern: {name_prefix}_{ref_key}_{name_suffix}
```

| `name_prefix` | `name_suffix` | `ref_key` | Resulting Name |
|---------------|---------------|-----------|----------------|
| `"acme"` | `"prod"` | `"main"` | `acme_main_prod` |
| `"acme"` | `null` | `"main"` | `acme_main` |
| `null` | `"prod"` | `"main"` | `main_prod` |
| `null` | `null` | `"main"` | `main` |

### Cross-Module Reference Example

```hcl
# In networking module
module "networking" {
  source = "./aws/networking"
  
  name_prefix = "acme"
  name_suffix = "prod"
  
  vpcs = {
    main = { cidr_block = "10.0.0.0/16" }
  }
}

# In another module - reference by ref_key, get computed name
resource "aws_something" "example" {
  vpc_id   = module.networking.vpc_ids["main"]      # Get ID by ref_key
  vpc_name = module.networking.vpc_names["main"]    # "acme_main_prod"
}
```

## Resources Supported

| Resource | Variable | Reference Key | Name Output |
|----------|----------|---------------|-------------|
| VPC | `vpcs` | `vpc_ref_key` | `vpc_names` |
| Subnet | `subnets` | `subnet_ref_key` | `subnet_names` |
| Internet Gateway | `internet_gateways` | `igw_ref_key` | `internet_gateway_names` |
| Elastic IP | `elastic_ips` | `eip_ref_key` | `elastic_ip_names` |
| NAT Gateway | `nat_gateways` | `nat_gateway_ref_key` | `nat_gateway_names` |
| Route Table | `route_tables` | `route_table_ref_keys` | `route_table_names` |
| VPC Endpoint | `vpc_endpoints` | `vpc_endpoint_ref_key` | `vpc_endpoint_names` |

## Usage

```hcl
module "networking" {
  source = "./aws/networking"

  region = "us-east-1"

  # Naming convention
  name_prefix = "mycompany"
  name_suffix = "prod"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }

  # Multiple VPCs - use ref_key to reference downstream
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

  # Subnets reference VPCs by ref_key
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

  # Internet Gateways reference VPCs by ref_key
  internet_gateways = {
    main-igw = {
      vpc_ref_key = "main"
    }
  }

  # Elastic IPs for NAT Gateways
  elastic_ips = {
    nat-eip-1a = {}
  }

  # NAT Gateways reference subnets and EIPs by ref_key
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

# Access outputs by ref_key
output "main_vpc_id" {
  value = module.networking.vpc_ids["main"]
}

output "main_vpc_name" {
  value = module.networking.vpc_names["main"]  # "mycompany_main_prod"
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

### Naming
| Output | Description |
|--------|-------------|
| `name_prefix` | Name prefix used for all resources |
| `name_suffix` | Name suffix used for all resources |

### Resources (by ref_key)
| Output | Description |
|--------|-------------|
| `vpcs` / `vpc_ids` / `vpc_names` | VPC resources, IDs, and computed names |
| `subnets` / `subnet_ids` / `subnet_names` | Subnet resources, IDs, and computed names |
| `internet_gateways` / `internet_gateway_ids` / `internet_gateway_names` | IGW resources, IDs, and computed names |
| `elastic_ips` / `elastic_ip_ids` / `elastic_ip_names` | EIP resources, IDs, and computed names |
| `nat_gateways` / `nat_gateway_ids` / `nat_gateway_names` | NAT Gateway resources, IDs, and computed names |
| `route_tables` / `route_table_ids` / `route_table_names` | Route Table resources, IDs, and computed names |
| `vpc_endpoints` / `vpc_endpoint_ids` / `vpc_endpoint_names` | VPC Endpoint resources, IDs, and computed names |
| `subnets_by_vpc` | Subnet IDs grouped by VPC ref_key |

## Validation

The module includes built-in validation to ensure:
- Each subnet specifies exactly one of `vpc_ref_key` or `vpc_id`
- Each route table specifies exactly one of `vpc_ref_key` or `vpc_id`
- Each NAT gateway specifies exactly one of `subnet_ref_key` or `subnet_id`
- Public NAT gateways specify exactly one of `eip_ref_key` or `allocation_id`
