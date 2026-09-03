# Create a Terraform module

## Use when

Adding a new independently consumable module to this repository.

## Workflow

1. Define the module's single responsibility, supported use cases, provider,
   and ownership boundary.
2. Check existing modules to avoid duplicate or overlapping abstractions.
3. Create the provider/module directory with `README.md`, `main.tf`,
   `variables.tf`, `outputs.tf`, `versions.tf`, `examples/`, and tests.
4. Declare Terraform and provider compatibility without configuring a backend
   or provider inside the child module.
5. Design typed inputs with safe defaults and validation. Document null,
   optional, and mutually exclusive behavior.
6. Design narrow, stable outputs needed for composition.
7. Use stable resource addresses and secure defaults.
8. Add at least one runnable example representing supported usage.
9. Format, initialize without a backend, validate, and run tests.
10. Update the repository README and `.ai/architecture.md`.

## Approval boundaries

Creating module source and running static checks does not authorize creating
cloud resources. Get explicit approval before credentialed plans, applies,
imports, state operations, or other cloud-side actions.

## Handoff

Report the module contract, provider requirements, validation performed,
security and cost considerations, and any work required before its first
release.
