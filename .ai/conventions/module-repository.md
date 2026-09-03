# Central module repository conventions

## Module scope

- Each module must have one clear responsibility and be independently
  consumable.
- Prefer small composable modules over flags that combine unrelated resource
  families.
- Keep environment-specific policy and values in consumers.
- Do not couple modules to a particular account, region, backend, workspace,
  or organization unless that is the module's documented purpose.

## Public contract

A module's variables, outputs, provider requirements, resource addresses,
defaults, validations, and observable infrastructure behavior form its public
contract.

- Add new inputs with backward-compatible defaults when possible.
- Do not silently change the meaning or units of an existing input.
- Keep output types stable and expose useful resource identifiers rather than
  whole provider resource objects unless the broad contract is intentional.
- Document nullability, mutually exclusive options, and precedence rules.
- Avoid leaking sensitive values through outputs.

## Documentation and examples

Every published module needs a README covering:

- Purpose and supported scope.
- Terraform and provider requirements.
- A pinned, runnable usage example.
- Inputs, outputs, defaults, and sensitive values.
- Important creation, replacement, deletion, security, and cost behavior.
- Upgrade or migration instructions for breaking changes.

Examples are root modules and may configure providers. Keep them minimal,
deterministic, and suitable for validation without an active backend.

## Versioning and releases

- Consumers should pin immutable semantic-version tags or commit SHAs.
- Patch releases contain compatible fixes and documentation corrections.
- Minor releases add backward-compatible capabilities.
- Major releases contain breaking contracts or behavior.
- Never move or overwrite a published tag.
- Raising minimum Terraform or provider versions may be breaking for
  consumers; evaluate it explicitly.

## Review requirements

Review every module change for:

- Existing-consumer compatibility.
- State moves, replacement, destruction, and import implications.
- Provider constraint and lock-file impact.
- IAM, network exposure, encryption, secret, and policy changes.
- Cost, quotas, regional availability, and eventual consistency.
- Documentation, examples, and tests affected by the change.
