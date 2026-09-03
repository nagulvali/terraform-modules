# Repository instructions

These instructions apply to every AI agent working in this repository.

## Before making changes

- Read `.ai/architecture.md` and the relevant documents in
  `.ai/conventions/`.
- Read `CONTRIBUTING.md` and the target module's README.
- Inspect the working tree and preserve unrelated user changes.
- Prefer the smallest complete change that satisfies the request.
- Inspect a module's inputs, resources, outputs, and documentation together
  before changing its interface.
- Search known consumers when evaluating a public contract change.

## Terraform changes

- Follow `.ai/conventions/terraform.md`.
- Follow `.ai/conventions/module-repository.md` for module layout, releases,
  and consumer compatibility.
- Preserve backward compatibility unless the user explicitly requests a
  breaking change.
- Keep provider and backend configuration in consuming root modules. Reusable
  modules declare provider requirements but should not configure providers.
- Update the module README and examples when behavior or its public contract
  changes.
- Do not run `terraform apply`, modify remote state, or perform cloud-side
  operations without explicit user approval.
- Never commit credentials, secrets, state files, plan files, or provider
  lock data containing sensitive configuration.

## Verification

- Format changed Terraform files with `terraform fmt`.
- Run `terraform validate` in each changed module when initialization and
  provider access permit it.
- Validate runnable examples affected by the change when practical.
- Run the narrowest relevant tests or static checks available.
- Report checks that could not be run and why.

## Communication

- State assumptions when repository context is incomplete.
- Summarize changed files, consumer compatibility, verification performed,
  migration needs, and any remaining risk.
- Do not create commits, push branches, or open pull requests unless the user
  explicitly asks.
