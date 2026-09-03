# AWS networking

Reusable AWS networking module for creating a VPC, subnets, an internet
gateway, and route tables.

## Status

VPCs, subnets, internet gateways, and route-table resources are implemented.
Route resources and route-table associations are currently incomplete and
must not be assumed from the `route_tables.routes`, `subnet_ids`, or
`subnet_ref_keys` inputs. See `TODO.md` for planned scope.

## Usage

```hcl
module "networking" {
  source = "git::https://github.com/ORG/terraform-modules.git//aws/networking?ref=v1.0.0"

  region = "us-east-1"

  vpc = {
    create               = true
    cidr_block           = "10.0.0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
      Name = "example"
    }
  }

  subnets = {
    public_a = {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
    }
  }

  igw = {
    create = true
  }

  route_tables = {}
}
```

Pin production consumers to an immutable tag or commit SHA.

## Inputs

- `region` (`string`, required): AWS region used by the module's current
  provider configuration.
- `tags` (`map(string)`, default `{}`): common resource tags.
- `vpc` (`object`): VPC creation and configuration. Set `create = true` to
  create a VPC, or provide `vpc_id` for an existing VPC.
- `vpc_id` (`string`, default `null`): existing VPC ID used when the module
  does not create one.
- `subnets` (`map(object)`): subnets keyed by stable logical names. Pass `{}`
  when no subnets are needed.
- `igw` (`object`): internet-gateway creation and optional VPC selection.
- `route_tables` (`map(object)`, default `{}`): route tables keyed by stable
  names. Route and association fields are not yet implemented.

## Outputs

- `aws_vpc`: the created `aws_vpc.this` resource collection. It is empty when
  the module uses an existing VPC.

## Compatibility note

This module currently declares its own AWS provider configuration and accepts
`region`. Reusable child modules should normally receive provider
configurations from consumers. Moving provider ownership and removing
`region` must be handled as a deliberate compatibility change.

## Safety

Review plans carefully for CIDR, subnet-key, and VPC changes because they may
replace networking resources. Route resources and associations should be
managed separately until their implementation is completed here.
