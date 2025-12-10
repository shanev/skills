# Decomplect

Architectural code analysis for design quality.

## Overview

Asks: *"Is this well-designed?"*

```
/decomplect
```

Runs 3 analyzers in parallel to evaluate architectural quality.

## Analyzers

| Analyzer | Source | Question |
|----------|--------|----------|
| **simplicity-analyzer** | Rich Hickey | Is this truly simple or just easy? |
| **fcis-analyzer** | Gary Bernhardt | Is pure logic separated from I/O? |
| **coupling-analyzer** | Constantine & Yourdon | Are modules well-separated? |

## What It Checks

| Pillar | Source | Focus |
|--------|--------|-------|
| **Simplicity** | Rich Hickey (Simple Made Easy, 2011) | Values over state, decomplected concerns |
| **FCIS** | Gary Bernhardt (Destroy All Software) | Functional core (pure), imperative shell (I/O) |
| **Coupling** | Constantine & Yourdon (1970s) | High cohesion, low coupling |

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
