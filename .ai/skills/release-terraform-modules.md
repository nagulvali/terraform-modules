# Release Terraform modules

## Use when

Preparing or publishing a repository version consumed by downstream projects.

## Workflow

1. Identify every module changed since the previous release.
2. Review public contracts, behavior, state addresses, provider constraints,
   security posture, and migration requirements.
3. Determine the required repository semantic-version increment based on the
   most significant included module change.
4. Run formatting, initialization without backends, validation, tests, and
   affected example checks.
5. Prepare release notes listing changed modules, consumer-visible behavior,
   breaking changes, and migration steps.
6. Confirm the target commit and tag do not contain state, plans, credentials,
   secrets, or generated provider directories.
7. Create and publish an immutable version tag only when the user explicitly
   requests it.

## Safety

Never reuse, move, or overwrite a published tag. A release does not require
running `terraform apply` or accessing consumer state.

## Handoff

Report the proposed version, included modules, validation results, release
notes, and any consumer action required.
