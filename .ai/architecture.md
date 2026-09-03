# Repository architecture

This repository is the central source of reusable Terraform modules consumed
by multiple projects. Modules are grouped by provider and released as
immutable repository versions.

## Layout

```text
aws/
  networking/
    README.md
    main.tf
    variables.tf
    outputs.tf
    versions.tf
    examples/
    tests/
```

The current AWS networking module manages VPC networking resources. As the
repository grows, keep each independently consumable module in its own
directory under the relevant provider.

## Module boundaries

- `main.tf` contains resources, data sources, and module-local values.
- `variables.tf` defines the public input contract and validations.
- `outputs.tf` defines the public output contract.
- `versions.tf` defines Terraform and provider requirements, not provider or
  backend configuration.
- `README.md` documents supported behavior, usage, requirements, inputs,
  outputs, and operational caveats.
- `examples/` contains runnable root modules demonstrating supported usage.
- `tests/` contains native Terraform tests or other module-level tests.

## Ownership boundaries

- Consuming root modules own provider configuration, authentication, backend
  configuration, state, environment-specific values, and apply decisions.
- Reusable modules own resource composition, input validation, outputs, and
  safe defaults within their documented scope.
- A module must not depend on a sibling module through a relative source path
  unless the composite relationship is intentional, documented, and tested.
- Modules must not assume a particular backend, account, region, workspace,
  or naming system unless exposed as a documented input.

## Dependency direction

Consumers pin this repository to immutable tags or commit SHAs. Published
modules must not depend on consumer repositories. Cross-module composition
belongs in a dedicated composite module or in the consuming root module.

## Evolution

- Additive, backward-compatible capabilities are minor changes.
- Compatible bug fixes and documentation corrections are patch changes.
- Breaking contracts, state-address changes without safe migration, or
  materially changed behavior are major changes.
- Preserve resource addresses during refactoring and use `moved` blocks when
  an address must change.

Update this document when adding a provider, module family, or repository-wide
architectural convention.
