# Shane's Agent Skills

A collection of language-agnostic coding-agent skills for code quality and architecture.
They use the open `SKILL.md` format and can be installed for Codex, Claude Code,
Cursor, GitHub Copilot, OpenCode, and other supported agents.

## Available Skills

### [Decomplect](docs/decomplect.md)

Architecture review based on semantic design costs rather than language-specific syntax.

```
/decomplect
```

- **Simplicity** - Separate independent concerns and expose hidden context
- **FCIS** - Separate deterministic policy from effects where it pays off
- **Coupling** - Align cohesion, boundaries, and dependency direction

[View skill source →](decomplect/SKILL.md)

### [Unslopify](docs/unslopify.md)

Evidence-first tactical review of contracts, responsibilities, failures, and duplication.

```
/unslopify
```

- **Contract Strength** - Express and enforce valid states idiomatically
- **Responsibility** - Keep independent change vectors separate
- **Failure Integrity** - Make recovery, degradation, and failure explicit
- **DRY** - Remove duplicated knowledge without premature abstraction

[View skill source →](unslopify/SKILL.md)

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

Ask your coding agent to apply a skill by name:

```text
Use decomplect to review the architecture of this branch.
Use unslopify on src/payments and focus on failure handling.
```

Claude Code plugin users can also invoke the slash commands directly:

```
/decomplect:decomplect    # Architectural analysis
/unslopify:unslopify      # Tactical cleanup
```

Both skills accept explicit files, directories, diffs, commits, branches, or whole-repository
scopes. They work across programming languages by evaluating behavior and contracts relative
to the repository's own ecosystem.
