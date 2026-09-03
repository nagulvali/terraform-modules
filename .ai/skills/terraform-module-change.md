# Terraform module change

## Use when

Adding, changing, or removing Terraform module behavior, inputs, or outputs.

## Workflow

1. Read `.ai/instructions.md`, `.ai/architecture.md`, and
   relevant files in `.ai/conventions/`.
2. Inspect the complete target module and its current callers or examples.
3. Classify the semantic-version impact and identify state-address,
   replacement, provider-version, security, and cost implications.
4. Implement the smallest complete change while preserving unrelated edits and
   stable resource addresses.
5. Add `moved` blocks or explicit migration instructions when addresses
   change.
6. Update variables, outputs, validation, documentation, examples, and tests
   affected by the public contract.
7. Run `terraform fmt` on changed Terraform files.
8. Initialize without a backend and run module validation and relevant tests.
9. Validate affected examples when practical.
10. Summarize behavior, compatibility, migration needs, checks, and residual
    operational risk.

## Approval boundaries

Get explicit user approval before applying a plan, importing or removing
resources, changing remote state, accessing cloud credentials, or making
cloud-side changes.
