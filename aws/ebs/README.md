# AWS EBS Module

Terraform module for creating AWS EBS volumes, attachments, snapshots, and
account-level default encryption settings with a key-based reference pattern.

## Design Pattern

1. Resources are defined as maps keyed by `ref_key`
2. Downstream resources reference upstream resources using `*_ref_key` attributes
3. Resource names follow: `{name_prefix}_{ref_key}_{name_suffix}`
4. Other modules reference by `ref_key` and fetch `name`, `id`, or `arn`

## Naming Convention

```
Pattern: {name_prefix}_{ref_key}_{name_suffix}
```

| `name_prefix` | `name_suffix` | `ref_key` | Resulting Name |
|---------------|---------------|-----------|----------------|
| `"acme"` | `"prod"` | `"data"` | `acme_data_prod` |
| `null` | `null` | `"data"` | `data` |

## Resources Supported

| Resource | Variable | Reference Key | Name Output |
|----------|----------|---------------|-------------|
| EBS Volume | `volumes` | `volume_ref_key` | `volume_names` |
| Volume Attachment | `volume_attachments` | - | - |
| Snapshot | `snapshots` | `snapshot_ref_key` / `source_snapshot_ref_key` | `snapshot_names` |
| Snapshot Copy | `snapshot_copies` | `snapshot_copy_ref_key` | `snapshot_copy_names` |
| Default Encryption | `encryption_by_default` | - | - |
| Default KMS Key | `default_kms_key` | - | - |

## Usage

```hcl
module "ebs" {
  source = "./aws/ebs"

  region      = "us-east-1"
  name_prefix = "acme"
  name_suffix = "prod"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }

  volumes = {
    data = {
      availability_zone = "us-east-1a"
      size              = 100
      type              = "gp3"
      encrypted         = true
      iops              = 3000
      throughput        = 125
    }
  }

  volume_attachments = {
    data-app = {
      device_name    = "/dev/sdf"
      instance_id    = "i-0123456789abcdef0"
      volume_ref_key = "data"
    }
  }

  snapshots = {
    data-daily = {
      volume_ref_key = "data"
      description    = "Daily snapshot of data volume"
    }
  }
}

output "data_volume_id" {
  value = module.ebs.volume_ids["data"]
}
```

## Safety

- Volumes default to `encrypted = true` and `type = gp3`.
- Restoring a volume from a snapshot uses the external `snapshot_id` input to
  avoid a Terraform dependency cycle with module-managed snapshots.
- Account-level `encryption_by_default` and `default_kms_key` affect the
  entire AWS account/region; enable only when intentional.
- Snapshot and volume size/type changes can replace or recreate resources.
- Attachments target external EC2 instance IDs; use the EC2 module when you
  need instance-local volume lifecycle.
- Review plans carefully before applying; destroying volumes deletes data
  unless snapshots exist.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.0.0 |

## Outputs

| Output | Description |
|--------|-------------|
| `volume_ids` / `volume_arns` / `volume_names` | Volume identifiers and names |
| `snapshot_ids` / `snapshot_arns` / `snapshot_names` | Snapshot identifiers and names |
| `snapshot_copy_ids` / `snapshot_copy_arns` / `snapshot_copy_names` | Snapshot copy identifiers and names |
| `volume_attachments` | Attachment resources |
| `encryption_by_default_enabled` | Managed default encryption flag |
| `default_kms_key_arn` | Managed default KMS key ARN |
