# User Stories - Future Enhancements

---

## US-EXT-001 - Support Custom Tools in Configuration Bundles

**Status**: Backlog  
**Priority**: Medium  
**Milestone**: v1.1.0 - Custom Tool Support

### Background

OpenCode supports custom tools defined in `.opencode/tools/` (see [Custom Tools Docs](https://opencode.ai/docs/custom-tools)). Tools are TypeScript/JavaScript definitions that can invoke scripts in any language.

### User Story

**As a**: bundle maintainer  
**I want to**: include custom tools with my configuration presets  
**So that**: agents can use specialized tooling beyond OpenCode's built-in tools

### Acceptance Criteria

1. Bundle manifest can optionally declare custom tools via a `tools` field
2. Tool definitions are installed to `.opencode/tools/` in the target project
3. Bundle manifest v1.1.0 is backward-compatible with v1.0.0 CLIs
4. Documentation explains tool installation flow

### Proposed Manifest Extension

```json
{
  "manifest_version": 1,
  "bundle_name": "qbic-opencode-config-bundle",
  "bundle_version": "v1.1.0",
  "presets": [...],
  "tools": [
    {
      "name": "database",
      "entrypoint": ".opencode/tools/database.ts",
      "description": "Query the project database"
    }
  ]
}
```

### Implementation Dependencies

- CLI: Update manifest schema validation to accept optional `tools` field
- CLI: Update `bundle apply` to copy tool definitions to `.opencode/tools/`
- Bundle: Update manifest version to v1.1.0 when tools are added
- Docs: Document tool installation flow

### Notes

- Tools are independent of agent prompts - prompts reference tools by name
- Multiple tools can be defined in a single file or spread across files
- Tool runtime can be Node.js, Python, or any system executable

---

## Future Extension Ideas

### Tool Runtime Dependencies

Future iterations could include dependency management for tools:

```json
{
  "tools": [
    {
      "name": "database",
      "entrypoint": ".opencode/tools/database.ts",
      "runtime": "node",
      "dependencies": ["pg", "dotenv"]
    }
  ]
}
```

### Global vs Project Tools

Future iterations could distinguish between:

- **Project tools**: Installed per-project in `.opencode/tools/`
- **Global tools**: Installed in `~/.config/opencode/tools/`

---

*Last updated: 2026-03-30*
