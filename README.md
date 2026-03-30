# OpenCode Config Bundle

A collection of OpenCode AI agent configuration presets with planning-first multi-tier workflow support.

## Overview

This bundle provides drop-in OpenCode agent configurations that route work through schema-validated JSON handoff artifacts before planning, execution, and review. The goal is fewer ambiguous changes, less rework, and tighter safety boundaries with a small, explicit contract between agents.

## Versioning & Stability

This bundle follows its own versioning scheme (`bundle_version` in the manifest), independent of the opencode-helper CLI version. This is intentional:

- **Ecosystem Stability**: Configuration bundles are foundational contracts that other tools and workflows depend on. Changes to the bundle should be rare and deliberate.
- **Semantic Versioning**: Follows semver (e.g., `v1.0.0`, `v1.1.0`, `v2.0.0`) to communicate change impact.
- **Backward Compatibility**: Minor and patch updates within a major version must not break existing configurations.
- **Schema Stability**: The bundle manifest schema (see below) is contractually stable. Once published, a manifest version `1` will never change breakingly.

## Bundle Contract (V2)

The V2 bundle manifest is the contract between the bundle and the opencode-helper CLI. This contract is:

- **Published**: Included in the CLI's schema validation
- **Versioned**: The `manifest_version` field ensures forward compatibility
- **Minimal**: Only contains what's needed for the CLI to discover and apply presets

### Manifest Schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["manifest_version", "bundle_name", "bundle_version", "presets"],
  "properties": {
    "manifest_version": { "type": "integer", "const": 1 },
    "bundle_name": { "type": "string" },
    "bundle_version": { "type": "string" },
    "source_repo": { "type": "string" },
    "source_commit": { "type": "string" },
    "release_tag": { "type": "string" },
    "presets": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["name", "description", "entrypoint"],
        "properties": {
          "name": { "type": "string" },
          "description": { "type": "string" },
          "entrypoint": { "type": "string" },
          "prompt_files": { "type": "array", "items": { "type": "string" } }
        }
      }
    }
  }
}
```

### Required Files

A valid V2 bundle must include:

```
<bundle-root>/
  opencode-bundle.manifest.json  <- required for V2
  <preset-entrypoint>.json       <- each preset file
  .opencode/schemas/
    handoff.schema.json          <- canonical handoff contract
    result.schema.json           <- canonical result contract
```

## Ecosystem Role

This bundle serves as a foundational component of the OpenCode ecosystem:

1. **Contract Provider**: Exports the canonical V2 bundle manifest schema used by the CLI
2. **Schema Publisher**: Includes `handoff.schema.json` and `result.schema.json` that define inter-agent contracts
3. **Preset Repository**: Maintains multiple model-specific configurations in a single, versioned bundle

> **Important**: Because other tools depend on this bundle's contracts, changes should follow semver strictly. The manifest schema (`manifest_version: 1`) is locked and will never break backward compatibility.

## Bundle Contents

| Preset | Description |
|--------|-------------|
| `openai` | OpenAI-based multi-tier agent configuration (GPT-5 series) |
| `mixed` | Mixed model stack (Claude for routing/planning/review, Codex for execution) |
| `kimi` | Kimi-based multi-tier agent configuration |
| `big-pickle` | Big Pickle model-based configuration |
| `minimax` | MiniMax-based configuration |

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
