# Shane's Agent Skills

A collection of reusable coding-agent skills for code quality and architecture.
They use the open `SKILL.md` format and can be installed for Codex, Claude Code,
Cursor, GitHub Copilot, OpenCode, and other supported agents.

## Available Skills

### [Decomplect](decomplect/)

Architectural code analysis for design quality.

```
/decomplect
```

- **Simplicity** - Values over state, decomplected concerns
- **FCIS** - Functional core, imperative shell
- **Coupling** - High cohesion, low coupling

[Read more →](decomplect/README.md)

### [Unslopify](unslopify/)

Tactical code cleanup for immediate quality issues.

```
/unslopify
```

- **Type Strictness** - No `any`, domain types
- **SRP** - Single responsibility, no god classes
- **Fail-Fast** - No workarounds, no silent fallbacks

[Read more →](unslopify/README.md)

## Installation

Install every skill globally for all supported coding agents with the
[Vercel Labs Skills CLI](https://github.com/vercel-labs/skills):

```bash
npx skills add shanev/skills --all -g
```

Or install one skill globally for all supported agents:

```bash
npx skills add shanev/skills --skill decomplect --agent '*' -g -y
npx skills add shanev/skills --skill unslopify --agent '*' -g -y
```

Omit `-g` to install into the current project instead of your user-level agent
directories. The CLI uses symlinks by default so each agent shares one canonical
copy of a skill.

### Claude Code plugin marketplace

Claude Code users can alternatively install the skills as plugins:

```bash
/plugin marketplace add shanev/skills

# Install what you need
/plugin install decomplect@shanev-skills
/plugin install unslopify@shanev-skills
```

Verify installation:
```
/plugin
```

## Usage

Once installed, use the commands directly:

```
/decomplect    # Architectural analysis
/unslopify     # Tactical cleanup
```

Or ask your coding agent to apply a skill by name.
