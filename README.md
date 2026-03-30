# OpenCode Config Bundle

A collection of OpenCode AI agent configuration presets with planning-first multi-tier workflow support.

## Overview

This bundle provides drop-in OpenCode agent configurations that route work through schema-validated JSON handoff artifacts before planning, execution, and review. The goal is fewer ambiguous changes, less rework, and tighter safety boundaries with a small, explicit contract between agents.

## Contract Ownership

This bundle **implements** the V2 bundle contract defined by the [opencode-agents](https://github.com/sven1103-agent/opencode-agents) repository. The contract schema and specification are maintained in the CLI repository.

For the full contract specification, see [Bundle Manifest Reference](https://github.com/sven1103-agent/opencode-agents/blob/main/docs/opencode-helper-cli.md#bundle-manifest-reference) in the opencode-agents documentation.

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
opencode-helper source add qbicsoftware/opencode-config-bundle --name qbic
```

Apply a preset to your project:

```bash
opencode-helper bundle apply qbic --preset openai --project-root ./myproject
```

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
