# Provider-neutral skills

Store reusable workflows here when they should work across Copilot, Codex, and
Cursor.

Each skill should be a Markdown file containing:

1. When to use the workflow.
2. Required context and preconditions.
3. Ordered execution steps.
4. Safety boundaries and actions requiring approval.
5. Verification and expected handoff.

Agent-native skills may require wrapper files in vendor-specific locations.
Keep those wrappers minimal and place the shared workflow here.

Available workflows:

- `create-terraform-module.md` — create a new reusable module.
- `release-terraform-modules.md` — prepare and publish an immutable release.
- `terraform-module-change.md` — safely modify and verify a Terraform module.
