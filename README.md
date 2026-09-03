# Terraform modules

Central repository of reusable Terraform modules consumed by multiple
projects. Modules are organized by provider and designed to expose stable,
documented interfaces.

## Repository layout

```text
<provider>/
  <module>/
    README.md
    main.tf
    variables.tf
    outputs.tf
    versions.tf
    examples/
    tests/
```

Available modules:

- `aws/networking` — AWS VPC networking resources; see its README and TODO for
  the currently implemented scope.
- `aws/kms` — KMS customer managed keys, aliases, and grants

## Consuming a module

Pin consumers to an immutable Git tag or commit. Do not consume a moving
branch in production.

```hcl
module "networking" {
  source = "git::https://github.com/ORG/terraform-modules.git//aws/networking?ref=v1.0.0"

  # Module inputs
}
```

Provider configuration belongs in the consuming root module. Pass aliased
providers explicitly when a module requires them.

## Module guarantees

- Inputs and outputs are treated as public APIs.
- Stable releases follow semantic versioning.
- Breaking input, output, behavior, or resource-address changes require a
  major version.
- Resource renames use `moved` blocks when possible.
- Modules do not apply infrastructure or manage backend configuration.

## Contributing

Read `CONTRIBUTING.md` and the module's documentation before changing a
module. At minimum, format and validate every changed module:

```shell
terraform fmt -recursive -check
terraform -chdir=aws/networking init -backend=false
terraform -chdir=aws/networking validate
```

Cloud credentials and `terraform apply` are not required for normal static
validation. Never commit state, plans, credentials, or secret variable files.
