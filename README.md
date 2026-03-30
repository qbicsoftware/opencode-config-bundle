# OpenCode Config Bundle

A collection of OpenCode AI agent configuration presets with planning-first multi-tier workflow support.

## Overview

This bundle provides drop-in OpenCode agent configurations that route work through schema-validated JSON handoff artifacts before planning, execution, and review. The goal is fewer ambiguous changes, less rework, and tighter safety boundaries with a small, explicit contract between agents.

## Bundle Contents

| Preset | Description |
|--------|-------------|
| `openai` | OpenAI-based multi-tier agent configuration (GPT-5 series) |
| `mixed` | Mixed model stack (Claude for routing/planning/review, Codex for execution) |
| `kimi` | Kimi-based multi-tier agent configuration |
| `big-pickle` | Big Pickle model-based configuration |
| `minimax` | MiniMax-based configuration |

## Bundle Manifest

This bundle follows the V2 config bundle manifest specification:

```json
{
  "manifest_version": 1,
  "bundle_name": "qbic-opencode-config-bundle",
  "bundle_version": "v1.0.0",
  "presets": [...]
}
```

## Schema Files

The bundle includes the canonical artifact schemas used by all configurations:

- `.opencode/schemas/handoff.schema.json` - Handoff artifact contract
- `.opencode/schemas/result.schema.json` - Result artifact contract

## Usage with opencode-helper

Register this bundle as a config source:

```bash
opencode-helper source add qbicsoftware/opencode-config-bundle --name qbic
```

List available presets:

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
