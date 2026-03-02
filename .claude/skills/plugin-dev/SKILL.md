---
name: plugin-dev
description: Complete guide for developing Claude Code plugins. Covers plugin structure, skill development, agent creation, command development, hook development, MCP integration, and plugin settings. Use when the user wants to create, validate, or review Claude Code plugins.
tools: Read, Write, Edit, Glob, Grep, Bash, Task
---

# Plugin Development Guide

Complete reference for developing Claude Code plugins covering all components: skills, agents, commands, hooks, MCP integration, and settings.

## Plugin Structure

### Directory Layout

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (required)
├── README.md                # Documentation
├── LICENSE                  # License file
├── skills/
│   └── my-skill/
│       ├── SKILL.md         # Skill definition (required)
│       └── references/      # Supporting docs
├── agents/
│   └── my-agent.md          # Agent definitions
├── commands/
│   └── my-command.md        # Slash commands
└── hooks/
    └── my-hook.md           # Event hooks
```

### Plugin Manifest (plugin.json)

```json
{
  "name": "my-plugin",
  "description": "What this plugin does",
  "version": "1.0.0",
  "author": {
    "name": "Author Name",
    "email": "email@example.com"
  }
}
```

## Skill Development

### SKILL.md Frontmatter

```yaml
---
name: skill-name
description: When and how to use this skill. Be specific about trigger conditions.
tools: Read, Write, Edit, Bash, Glob, Grep, Task
---
```

### Best Practices

- **Progressive disclosure**: Start with overview, then details
- **Imperative form**: "Create the file" not "The file should be created"
- **Concrete examples**: Show code snippets and expected output
- **Trigger conditions**: Be explicit about when to activate
- **References directory**: Put detailed docs in `references/` subdirectory

## Agent Development

### Agent Frontmatter

```yaml
---
name: agent-name
description: What this agent does
model: sonnet  # or haiku, opus, inherit
color: cyan    # Terminal color for output
tools: Read, Write, Edit, Bash
---
```

### Agent Design Principles

- **Single responsibility**: Each agent does one thing well
- **Expert persona**: Define the agent's expertise clearly
- **Structured output**: Specify expected output format
- **Error handling**: Define how to handle failures

## Command Development

### Command Frontmatter

```yaml
---
description: What this command does
allowed-tools: Bash(specific:*), Read, Edit
disable-model-invocation: false
---
```

### Command Features

- **Arguments**: Access via `$ARGUMENTS` placeholder
- **Tool restrictions**: Limit which tools the command can use
- **Bash patterns**: Use `Bash(pattern:*)` for specific command access
- **User-invocable**: Commands become `/command-name` slash commands

## Hook Development

### Hook Types

| Hook | Trigger | Use Case |
|------|---------|----------|
| `PreToolUse` | Before tool execution | Validation, approval gates |
| `PostToolUse` | After tool execution | Linting, formatting |
| `Notification` | On notifications | Alerts, logging |
| `Stop` | Session ending | Quality gates, cleanup |
| `SessionStart` | Session beginning | Setup, initialization |

### Hook Configuration

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint -- $CLAUDE_FILE_PATH"
          }
        ]
      }
    ]
  }
}
```

### Hook Environment Variables

- `$CLAUDE_TOOL_NAME` - Name of the tool being used
- `$CLAUDE_FILE_PATH` - Path of the file being operated on
- `$CLAUDE_SESSION_ID` - Current session identifier

## MCP Integration

### Configuration Locations

- **Project**: `.claude/settings.json`
- **User**: `~/.claude/settings.json`

### Transport Types

| Type | Config | Use Case |
|------|--------|----------|
| **stdio** | `command`, `args` | Local processes |
| **sse** | `url` | Remote HTTP servers |
| **http** | `url` | Streamable HTTP |

### Example Configuration

```json
{
  "mcpServers": {
    "my-server": {
      "type": "stdio",
      "command": "node",
      "args": ["./mcp-server/index.js"],
      "env": {
        "API_KEY": "..."
      }
    }
  }
}
```

## Plugin Settings

### Local Configuration Pattern

Create `.claude/plugin-name.local.md` for user-specific settings:

```markdown
# My Plugin Local Settings

## API Keys
- SERVICE_KEY: stored in environment

## Preferences
- Output format: markdown
- Verbosity: detailed
```

Add to `.gitignore`:
```
.claude/*.local.md
```

## Plugin Validation Checklist

- [ ] `plugin.json` has name, description, version, author
- [ ] All SKILL.md files have valid frontmatter
- [ ] Agent files have model, tools, description
- [ ] Commands have description and allowed-tools
- [ ] Hooks have correct matcher patterns
- [ ] No secrets in committed files
- [ ] README.md documents usage
- [ ] LICENSE file present

## Creating a Plugin (Guided Workflow)

1. **Discovery** - Understand requirements
2. **Component Planning** - Decide which components to include
3. **Detailed Design** - Design each component
4. **Structure Creation** - Create directory structure and manifest
5. **Component Implementation** - Build skills, agents, commands, hooks
6. **Validation** - Run validation checks
7. **Testing** - Verify all components work
8. **Documentation** - Write README and usage guide
