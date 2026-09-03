# AWS EC2 Module

Terraform module for creating AWS EC2 resources with a consistent key-based reference pattern and flexible naming convention.

## Design Pattern

This module uses a **key-based reference pattern** where:
1. Resources are defined as maps keyed by `ref_key`
2. Downstream resources reference upstream resources using `*_ref_key` attributes
3. Resource names follow the pattern: `{name_prefix}_{ref_key}_{name_suffix}`
4. Other modules reference by `ref_key` and fetch `name`, `id`, `arn`, or other attributes

## Naming Convention

```
Pattern: {name_prefix}_{ref_key}_{name_suffix}
```

| `name_prefix` | `name_suffix` | `ref_key` | Resulting Name |
|---------------|---------------|-----------|----------------|
| `"acme"` | `"prod"` | `"web-server"` | `acme_web-server_prod` |
| `"acme"` | `null` | `"web-server"` | `acme_web-server` |
| `null` | `null` | `"web-server"` | `web-server` |

## Resources Supported

| Resource | Variable | Reference Key | Name Output |
|----------|----------|---------------|-------------|
| Key Pair | `key_pairs` | `key_pair_ref_key` | `key_pair_names` |
| Security Group | `security_groups` | `security_group_ref_keys` | `security_group_names` |
| Instance Profile | `instance_profiles` | `instance_profile_ref_key` | `instance_profile_names` |
| Launch Template | `launch_templates` | `launch_template_ref_key` | `launch_template_names` |
| EC2 Instance | `instances` | `instance_ref_key` | `instance_names` |
| EBS Volume | `ebs_volumes` | `volume_ref_key` | `ebs_volume_names` |
| Volume Attachment | `ebs_volume_attachments` | - | - |

## Usage

```hcl
module "ec2" {
  source = "./aws/ec2"

  region      = "us-east-1"
  name_prefix = "mycompany"
  name_suffix = "prod"

  tags = {
    Environment = "production"
  }

  # Key Pairs
  key_pairs = {
    main = {
      create_private_key = true  # Generate new key pair
    }
  }

  # Security Groups
  security_groups = {
    web = {
      description = "Web server security group"
      vpc_id      = module.networking.vpc_ids["main"]

      ingress_rules = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]

      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }

  # Instance Profiles (reference IAM roles)
  instance_profiles = {
    web = {
      role_name = module.iam.role_names["web-server"]
    }
  }

  # Launch Templates
  launch_templates = {
    web = {
      image_id      = "ami-xxxxxxxx"
      instance_type = "t3.medium"

      key_pair_ref_key         = "main"
      security_group_ref_keys  = ["web"]
      instance_profile_ref_key = "web"

      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 30
            volume_type = "gp3"
            encrypted   = true
          }
        }
      ]
    }
  }

  # EC2 Instances
  instances = {
    web-1 = {
      launch_template_ref_key = "web"
      subnet_id = module.networking.subnet_ids["public-1a"]
    }

    web-2 = {
      launch_template_ref_key = "web"
      subnet_id = module.networking.subnet_ids["public-1b"]
    }
  }

  # EBS Volumes
  ebs_volumes = {
    data = {
      availability_zone = "us-east-1a"
      size              = 100
      type              = "gp3"
      encrypted         = true
    }
  }

  # Volume Attachments
  ebs_volume_attachments = {
    web-1-data = {
      device_name      = "/dev/xvdf"
      instance_ref_key = "web-1"
      volume_ref_key   = "data"
    }
  }
}

# Access outputs by ref_key
output "web_instance_ids" {
  value = [
    module.ec2.instance_ids["web-1"],
    module.ec2.instance_ids["web-2"]
  ]
}

output "web_sg_id" {
  value = module.ec2.security_group_ids["web"]
}
```

## Reference Keys vs Direct Values

Each resource supports both reference keys (for resources in this module) and direct values:

| Resource | Ref Key Attribute | Direct Value Attribute |
|----------|-------------------|------------------------|
| Key Pair | `key_pair_ref_key` | `key_name` |
| Security Group | `security_group_ref_keys` | `vpc_security_group_ids` |
| Instance Profile | `instance_profile_ref_key` | `iam_instance_profile` / `instance_profile_name` |
| Launch Template | `launch_template_ref_key` | `launch_template_id` |
| Instance | `instance_ref_key` | `instance_id` |
| Volume | `volume_ref_key` | `volume_id` |

## Key Pairs

Generate new key pairs or import existing public keys:

```hcl
key_pairs = {
  # Generate new key pair (private key in outputs)
  generated = {
    create_private_key = true
  }

  # Import existing public key
  imported = {
    public_key = "ssh-rsa AAAAB3..."
  }
}

# Access generated private key
output "private_key" {
  value     = module.ec2.private_keys["generated"]
  sensitive = true
}
```

## Launch Templates vs Direct Instance Config

Instances can use either launch templates or direct configuration:

```hcl
instances = {
  # Using launch template (recommended)
  from-template = {
    launch_template_ref_key = "web"
    subnet_id = "subnet-xxx"
  }

  # Direct configuration
  direct = {
    ami                     = "ami-xxx"
    instance_type           = "t3.micro"
    subnet_id               = "subnet-xxx"
    key_pair_ref_key        = "main"
    security_group_ref_keys = ["web"]
  }
}
```

## Cross-Module Integration

```hcl
# Networking module
module "networking" {
  source = "./aws/networking"
  # ...
}

# IAM module
module "iam" {
  source = "./aws/iam"
  # ...
}

# EC2 module - references both
module "ec2" {
  source = "./aws/ec2"

  security_groups = {
    web = {
      vpc_id = module.networking.vpc_ids["main"]  # From networking
      # ...
    }
  }

  instance_profiles = {
    web = {
      role_name = module.iam.role_names["ec2-role"]  # From IAM
    }
  }

  instances = {
    web = {
      subnet_id = module.networking.subnet_ids["public-1a"]  # From networking
      # ...
    }
  }
}
```

## Outputs

### Naming
| Output | Description |
|--------|-------------|
| `name_prefix` | Name prefix used |
| `name_suffix` | Name suffix used |

### Key Pairs
| Output | Description |
|--------|-------------|
| `key_pairs` | Full key pair resources |
| `key_pair_names` | Names by ref_key |
| `key_pair_ids` | IDs by ref_key |
| `private_keys` | Generated private keys (sensitive) |

### Security Groups
| Output | Description |
|--------|-------------|
| `security_groups` | Full security group resources |
| `security_group_names` | Names by ref_key |
| `security_group_ids` | IDs by ref_key |

### Instance Profiles
| Output | Description |
|--------|-------------|
| `instance_profiles` | Full instance profile resources |
| `instance_profile_names` | Names by ref_key |
| `instance_profile_arns` | ARNs by ref_key |

### Launch Templates
| Output | Description |
|--------|-------------|
| `launch_templates` | Full launch template resources |
| `launch_template_names` | Names by ref_key |
| `launch_template_ids` | IDs by ref_key |

### EC2 Instances
| Output | Description |
|--------|-------------|
| `instances` | Full instance resources |
| `instance_names` | Names by ref_key |
| `instance_ids` | IDs by ref_key |
| `instance_private_ips` | Private IPs by ref_key |
| `instance_public_ips` | Public IPs by ref_key |

### EBS Volumes
| Output | Description |
|--------|-------------|
| `ebs_volumes` | Full EBS volume resources |
| `ebs_volume_names` | Names by ref_key |
| `ebs_volume_ids` | IDs by ref_key |

## Validation

Built-in validation ensures:
- Each key pair specifies exactly one of `public_key` or `create_private_key=true`
- Each volume attachment specifies exactly one of `instance_ref_key` or `instance_id`
- Each volume attachment specifies exactly one of `volume_ref_key` or `volume_id`
