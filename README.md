# Shane's Claude Code Skills

A collection of skills for Claude Code to enhance development workflows.

## Available Skills

### [Decomplect](decomplect/)

Multi-agent toolkit for analyzing code simplicity using Rich Hickey's decomplection principles. Runs 5 specialized agents in parallel to evaluate:

- **Simplicity** - Values over state, functions over methods
- **Cohesion/Coupling** - Module boundaries and dependencies
- **Single Responsibility** - One reason to change per unit
- **Type Strictness** - Strong types, no `any`/`interface{}`
- **Functional Core** - Pure logic separated from I/O

Supports TypeScript, Go, and Rust.

```
/decomplect
```

[Read more →](decomplect/README.md)

### [Tmux Task Runner](tmux-task-runner/)

Run long-running tasks (builds, tests, deployments, dev servers) in monitored tmux sessions with persistent logging and real-time output monitoring.

[Read more →](tmux-task-runner/README.md)

## Installation

Install skills using Claude Code's plugin system:

```
/plugin marketplace add shanev/skills
/plugin install decomplect@shanev-skills
/plugin install tmux-task-runner@shanev-skills
```

Verify installation:
```
/plugin
```

The installed skills should appear in the list.

## Usage

Once installed, Claude automatically invokes skills when relevant to your requests. Each skill includes detailed documentation in its directory.
