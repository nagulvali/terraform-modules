# AI collaboration

This directory is the provider-neutral source of truth for AI-assisted work in
this repository.

## Contents

- `instructions.md` contains the repository-wide operating instructions.
- `architecture.md` describes the repository structure and design boundaries.
- `conventions/terraform.md` contains Terraform language and safety standards.
- `conventions/module-repository.md` contains module contract, documentation,
  compatibility, and release standards.
- `skills/` contains reusable, provider-neutral workflows.

Agent-specific files such as `AGENTS.md`,
`.github/copilot-instructions.md`, and `.cursor/rules/*.mdc` should remain
small adapters that direct agents to these documents. Put shared guidance here
instead of duplicating it in those adapters.

## Precedence

1. The user's current request.
2. The agent-specific entry file.
3. `.ai/instructions.md`.
4. Relevant documents under `.ai/conventions/` and `.ai/skills/`.

If instructions conflict, follow the higher-precedence source and call out any
material ambiguity.
