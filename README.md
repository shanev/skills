# Shane's Claude Code Skills

A collection of skills for Claude Code to enhance development workflows.

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

### [Codex Review Loop](codex-review-loop/)

Automated review-and-fix loop for Codex CLI.

```bash
./review-loop.sh
```

Runs `/review`, fixes issues, and repeats until clean (max 3 iterations). Similar to a [Ralph Wiggum loop](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) but specialized for code review workflows.

**Install to your repo:**
```bash
curl -sSL https://raw.githubusercontent.com/shanev/skills/main/codex-review-loop/review-loop.sh -o review-loop.sh && chmod +x review-loop.sh
```

## Installation

```bash
/plugin marketplace add shanev/skills

# Install what you need
/plugin install decomplect@shanev-skills
/plugin install unslopify@shanev-skills
/plugin install tmux-task-runner@shanev-skills
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

Or let Claude invoke them based on your requests.
