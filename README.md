# OpenCode Config Bundle

A collection of OpenCode AI agent configuration presets with planning-first multi-tier workflow support.

## Overview

This bundle provides drop-in OpenCode agent configurations that route work through schema-validated JSON handoff artifacts before planning, execution, and review. The goal is fewer ambiguous changes, less rework, and tighter safety boundaries with a small, explicit contract between agents.

## Contract Ownership

This bundle consumes the bundle contract defined by the [opencode-config-cli](https://github.com/sven1103-agent/opencode-config-cli) repository. The CLI owns the manifest schema, validation rules, and GitHub release distribution contract.

For the full contract specification, see [Bundle Contract](https://github.com/sven1103-agent/opencode-config-cli/blob/main/docs/specs/bundle-contract.md).

## Versioning

This bundle follows its own versioning scheme (`bundle_version` in the manifest), independent of the opencode-helper CLI version:

- **Semantic Versioning**: Follows semver (e.g., `v1.0.0`, `v1.1.0`, `v2.0.0`)
- **Contract Compliance**: Each bundle version declares which `manifest_version` it complies with

## Required Files

A valid V2 bundle must include:

```
<bundle-root>/
  opencode-bundle.manifest.json  <- contract compliance marker
  <preset-entrypoint>.json       <- preset configurations
  .opencode/schemas/
    handoff.schema.json          <- from CLI contract
    result.schema.json           <- from CLI contract
```

## Bundle Contents

| Preset | Description |
|--------|-------------|
| `openai` | OpenAI-based multi-tier agent configuration (GPT-5 series) |
| `mixed` | Mixed model stack (Claude for routing/planning/review, Codex for execution) |
| `kimi` | Kimi-based multi-tier agent configuration |
| `big-pickle` | Big Pickle model-based configuration |
| `minimax` | MiniMax-based configuration |

## Usage with opencode-helper

Register this bundle as a config source:

```bash
oc source add qbicsoftware/opencode-config-bundle --name qbic
```

Apply a prerelease preset to your project:

```bash
oc bundle apply qbic --version 1.0.0-alpha.1 --preset openai --project-root ./myproject
```

The repository publishes release bundle assets during GitHub release publication. Each release uploads:

- `opencode-config-bundle-<tag>.tar.gz`
- `opencode-config-bundle-<tag>-checksums.txt`

These explicit assets are the supported distribution format for GitHub-release bundle sources. Do not rely on GitHub's auto-generated source archives for `oc` bundle resolution.

## Design Philosophy

### Planning-First Execution

The core insight behind these configurations is that **unplanned implementation is expensive to undo**. Before any file is touched, the system asks: is this task concrete and scoped enough to implement directly? If not, a dedicated planning agent runs first.

### Model Tier Strategy

Four model tiers are used, selected on the principle: **use the cheapest model that can do the job correctly**.

- **Standard** (`claude-sonnet-4-6` / `gpt-5.4`): Planning, routing decisions, review
- **Fast** (`claude-haiku-4-5` / `gpt-5.2`): Cheap routing, narrow doc edits
- **Mini** (`gpt-5.1-codex-mini`): Trivial and localized code edits
- **Codex** (`gpt-5.3-codex` / `big-pickle`): Primary implementation execution

## Agent Architecture

All configurations define four functional tiers:

1. **Routing Agents** - Entry points that classify and delegate work
2. **Planning Agents** - Produce structured execution plans
3. **Execution Agents** - Implement changes based on plans
4. **Validation Agents** - Review quality and safety

## License

AGPL-3.0 - see the LICENSE file for details.
