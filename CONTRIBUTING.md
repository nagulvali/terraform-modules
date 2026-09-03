# Contributing

This repository is a shared dependency for multiple projects. Changes must be
safe for existing consumers and independently reviewable.

## Before changing a module

1. Read the module README, inputs, outputs, and implementation.
2. Search known consumers when available.
3. Classify the change as patch, minor, or major under semantic versioning.
4. Identify Terraform state-address changes and provider-version impact.
5. Keep unrelated refactoring separate from behavior changes.

## Required module structure

Every published module must include:

- `README.md` with purpose, usage, requirements, inputs, outputs, and caveats.
- `main.tf` for resources, data sources, and locals.
- `variables.tf` for typed, described, and validated inputs.
- `outputs.tf` for described outputs.
- `versions.tf` for `required_version` and `required_providers`.
- At least one runnable example for supported use cases.
- Tests when behavior is complex or regression-prone.

Additional Terraform files may be split by concern as a module grows. File
boundaries do not affect Terraform behavior.

## Compatibility

Treat these as public contract changes:

- Adding, removing, renaming, or changing an input or output.
- Changing defaults, validation, null behavior, or collection keys.
- Changing resource addresses, creation conditions, or replacement behavior.
- Raising Terraform or provider version constraints.
- Changing tags, names, policies, networking rules, or other observable
  infrastructure behavior.

Use `moved` blocks for address-preserving refactors where possible. Document
required migration steps for changes that cannot be made safely in place.

## Provider and state ownership

- Root modules configure providers and backends.
- Reusable child modules declare provider requirements but normally do not
  contain `provider` or `terraform backend` blocks.
- Do not read or write remote state unless cross-stack coupling is deliberate
  and documented.
- Do not run apply, import, state, or cloud-mutating commands as part of normal
  module development.

## Validation

Run the narrowest checks first, followed by repository-wide checks when
available:

```shell
terraform fmt -recursive -check
terraform -chdir=<module-path> init -backend=false
terraform -chdir=<module-path> validate
```

Also run configured linting, security scanning, examples, and tests. A
successful `validate` confirms configuration consistency; it does not prove
that a plan is backward compatible or operationally safe.

## Pull requests and releases

- Describe consumer-visible behavior and migration requirements.
- Include verification performed and checks that were not run.
- Call out replacements, deletions, IAM changes, exposure changes, and cost
  impact.
- Release immutable semantic-version tags only after required checks pass.
- Do not move or reuse an existing release tag.
