# Terraform conventions

## Design

- Treat variables and outputs as a module's public API.
- Declare supported Terraform versions with `required_version`.
- Declare provider source addresses and compatible version constraints in
  `required_providers`.
- Do not define provider or backend blocks in reusable child modules.
- Use explicit object types and validation for structured inputs.
- Give optional attributes intentional defaults.
- Prefer empty collections over `null` when values feed `for_each`, `count`,
  collection functions, or comprehensions.
- Mark sensitive inputs and outputs with `sensitive = true`; do not rely on
  that flag as a substitute for secure state handling.
- Use stable `for_each` keys for resources whose identity must survive list
  reordering; avoid changing existing resource addresses unnecessarily.
- Keep provider-specific implementation details inside the module.
- Prefer references over manually reconstructed resource identifiers.
- Add descriptions to variables and outputs.
- Add preconditions, postconditions, and variable validations for constraints
  Terraform can verify before cloud-side operations.

## Style

- Use canonical formatting from `terraform fmt`.
- Use `snake_case` for variables, outputs, locals, and resource names.
- Name a module's primary resource `this` when there is only one logical
  instance; use descriptive names when multiple roles exist.
- Keep comments focused on intent or non-obvious constraints.
- Remove obsolete commented-out code once it is no longer serving an active,
  documented design purpose.
- Prefer direct attribute access for typed objects; use `try` only for
  intentional fallback behavior and avoid hiding unexpected errors.
- Use `locals` for derived values, not to obscure simple one-time expressions.

## Safety and compatibility

- Consider resource address, variable type, default, and output changes for
  backward compatibility.
- Use `moved` blocks when an intentional refactor changes resource addresses.
- Use `removed` blocks and documented migration steps when retiring resources
  without destroying their underlying infrastructure.
- Review plans for create, update, replace, and destroy actions; validation
  alone cannot establish operational safety.
- Avoid data-loss-prone lifecycle settings unless the user explicitly accepts
  the impact.
- Do not add broad IAM permissions, unrestricted ingress/egress, public
  exposure, or disabled encryption as convenience defaults.
- Avoid provisioners unless no provider-native or declarative alternative
  exists and the tradeoff is documented.
- Do not run `terraform apply`, import resources, or alter state without
  explicit approval.

## Verification

From each changed module directory, run when available:

```shell
terraform fmt -check
terraform init -backend=false
terraform validate
terraform test
```

Validate affected examples as root modules. Use repository-provided linting,
security scanning, and tests when available. Provider-dependent tests or plans
may require credentials and explicit approval; static validation should not.
