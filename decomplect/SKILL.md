---
name: decomplecting-code
description: Analyzes git diff/staged changes for simplicity and decomplection using Rich Hickey's principles. Multi-agent toolkit with 5 specialized analyzers for simplicity, coupling, SRP, type strictness, and functional core patterns. Use when reviewing code, preparing PRs, or checking if code "would get a good grade from Rich Hickey."
---

# Decomplecting Code Skill

Multi-agent toolkit for analyzing code simplicity using Rich Hickey's decomplection principles.

## Quick Start

**Full analysis:**
```
/decomplect --all
```

**Natural language:**
```
"Would Rich Hickey approve of this code?"
"Check my staged changes for simplicity"
```

## Agents

This skill provides 5 specialized agents:

| Agent | Purpose | Trigger |
|-------|---------|---------|
| [simplicity-analyzer](agents/simplicity-analyzer.md) | Rich Hickey's decomplection | "simplicity", "decomplect", "Rich Hickey" |
| [coupling-analyzer](agents/coupling-analyzer.md) | Cohesion & coupling | "coupling", "cohesion", "dependencies" |
| [srp-analyzer](agents/srp-analyzer.md) | Single Responsibility | "responsibility", "god class", "too much" |
| [type-strictness-analyzer](agents/type-strictness-analyzer.md) | Type safety | "types", "any", "strictness" |
| [fcis-analyzer](agents/fcis-analyzer.md) | Functional Core/Imperative Shell | "pure", "side effects", "I/O" |

## Commands

| Command | Description |
|---------|-------------|
| `/decomplect` | Run all 5 analyzers in parallel (default) |
| `/decomplect --sequential` | Run analyzers one at a time |
| `/decomplect --simplicity` | Run simplicity analyzer only |

## Supported Languages

- TypeScript / JavaScript (`.ts`, `.tsx`, `.js`)
- Go (`.go`)
- Rust (`.rs`)

## The 5 Pillars

### 1. Simplicity (Rich Hickey)
Is code truly simple or just easy? Values over state, functions over methods, explicit over implicit.

### 2. Cohesion & Coupling
Are modules well-separated? High cohesion within, low coupling between.

### 3. Single Responsibility
Does each unit have one reason to change? No god classes or kitchen-sink functions.

### 4. Type Strictness
Are types as strong as possible? No `any`, domain types, explicit nullability.

### 5. Functional Core, Imperative Shell
Is pure logic separated from I/O? Testable core, side effects at edges.

## Output

Agents provide:
- Grade (A-F)
- Findings with confidence scores (≥80% only)
- Refactoring suggestions with code examples
- Priority recommendations

## Reference Documentation

- [Rich Hickey Principles](reference/rich-hickey.md)
- [Cohesion & Coupling](reference/coupling.md)
- [Single Responsibility](reference/srp.md)
- [Type Strictness](reference/types.md)
- [Functional Core/Imperative Shell](reference/fcis.md)

## Examples

See [EXAMPLES.md](EXAMPLES.md) for full analysis examples.
