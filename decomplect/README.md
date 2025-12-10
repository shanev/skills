# Decomplect

Architectural code analysis inspired by Rich Hickey's simplicity philosophy.

## Overview

Asks: *"Is this well-designed?"*

```
/decomplect
```

Runs 3 analyzers in parallel to evaluate architectural quality.

## Analyzers

| Analyzer | Question |
|----------|----------|
| **simplicity-analyzer** | Is this truly simple or just easy? |
| **fcis-analyzer** | Is pure logic separated from I/O? |
| **coupling-analyzer** | Are modules well-separated? |

## What It Checks

| Pillar | Focus |
|--------|-------|
| **Simplicity** | Values over state, decomplected concerns, no hidden dependencies |
| **FCIS** | Functional core (pure logic), imperative shell (I/O at edges) |
| **Coupling** | High cohesion, low coupling, clean dependency direction |

## Usage

```
/decomplect                # All 3 analyzers in parallel
/decomplect --sequential   # One at a time
/decomplect --simplicity   # Simplicity only
/decomplect --fcis         # FCIS only
/decomplect --coupling     # Coupling only
```

## When to Use

- Reviewing system design
- Before major refactoring
- Assessing architectural quality
- Checking if code is "Rich Hickey approved"

## Supported Languages

- TypeScript / JavaScript
- Go
- Rust

## Installation

```bash
/plugin marketplace add shanev/skills
/plugin install decomplect@shanev-skills
```

## Architecture

```
decomplect/
├── agents/
│   ├── simplicity-analyzer.md
│   ├── fcis-analyzer.md
│   └── coupling-analyzer.md
├── commands/
│   └── decomplect.md
└── reference/
    ├── rich-hickey.md
    ├── fcis.md
    └── coupling.md
```

## See Also

- `/unslopify` - Tactical code cleanup (types, SRP, fail-fast)
- [EXAMPLES.md](EXAMPLES.md) - Full analysis examples
