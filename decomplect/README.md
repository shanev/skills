# Decomplect - Code Simplicity Analyzer

A multi-agent toolkit for analyzing code quality using Rich Hickey's decomplection principles.

## Overview

Decomplect runs 5 specialized agents to evaluate your code against key simplicity principles:

| Agent | Focus | Color |
|-------|-------|-------|
| **simplicity-analyzer** | Rich Hickey's decomplection principles | Purple |
| **coupling-analyzer** | High-cohesion, low-coupling | Blue |
| **srp-analyzer** | Single Responsibility Principle | Orange |
| **type-strictness-analyzer** | Type safety and domain modeling | Green |
| **fcis-analyzer** | Functional Core, Imperative Shell | Cyan |

## Supported Languages

- TypeScript / JavaScript
- Go
- Rust

## Usage

### Full Analysis (All Agents)

```
/decomplect
```

Runs all 5 agents in parallel and aggregates results (default behavior).

### Individual Agents

Run specific agents based on your focus:

```
"Check my code for simplicity issues"        → simplicity-analyzer
"Review coupling and module boundaries"      → coupling-analyzer
"Does this class have too many responsibilities?" → srp-analyzer
"Check my types for strictness"              → type-strictness-analyzer
"Is my business logic properly separated?"   → fcis-analyzer
```

### Natural Language

```
"Would Rich Hickey approve of this code?"
"Review my staged changes for decomplection"
"Check this PR for code quality"
```

## Output

Each agent provides:
- **Grade** (A-F)
- **Findings** with file:line references
- **Confidence scores** (only reports issues ≥80% confidence)
- **Refactoring suggestions** with before/after code

The `/decomplect` command aggregates all results into a unified report with:
- Overall grade (weighted average)
- Issues sorted by severity
- Priority recommendations

## The 5 Pillars

### 1. Simplicity (Rich Hickey)

Is the code truly **simple** or just **easy**?

- Values over state
- Functions over methods
- Explicit over implicit
- Composition over inheritance

### 2. Cohesion & Coupling

Are modules well-separated?

- High cohesion (related things together)
- Low coupling (minimal dependencies)
- Clear interfaces
- Dependency inversion

### 3. Single Responsibility

Does each unit have one job?

- One reason to change
- No god classes
- Focused functions
- Clear naming

### 4. Type Strictness

Are types as strong as possible?

- No `any` / `interface{}` / excessive `unwrap()`
- Domain types (branded/newtype)
- Discriminated unions
- Explicit nullability

### 5. Functional Core, Imperative Shell

Is pure logic separated from I/O?

- Pure functions for business logic
- Side effects at the edges
- Testable without mocks
- Deterministic core

## Installation

```bash
# In Claude Code
/plugins add shanev-skills
```

## Architecture

```
decomplect/
├── .claude-plugin/
│   └── plugin.json           # Plugin configuration
├── agents/
│   ├── simplicity-analyzer.md
│   ├── coupling-analyzer.md
│   ├── srp-analyzer.md
│   ├── type-strictness-analyzer.md
│   └── fcis-analyzer.md
├── commands/
│   └── decomplect.md         # Orchestration command
├── reference/
│   ├── rich-hickey.md
│   ├── coupling.md
│   ├── srp.md
│   ├── types.md
│   └── fcis.md
├── SKILL.md                  # Skill overview
├── EXAMPLES.md               # Usage examples
└── README.md
```

## Philosophy

Inspired by Rich Hickey's talks:

- **Simple Made Easy** - Distinguishing simple from easy
- **The Value of Values** - Preferring immutable values
- **Hammock Driven Development** - Thinking before coding

The goal is code that is:
- Easy to understand in isolation
- Easy to change without fear
- Easy to test without mocks
- Easy to reuse in different contexts

## See Also

- [EXAMPLES.md](EXAMPLES.md) - Full analysis examples
- [reference/](reference/) - Deep dives on each principle
