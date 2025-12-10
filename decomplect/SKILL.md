---
name: decomplect
description: Architectural code analysis using Rich Hickey's decomplection principles. Evaluates simplicity, functional core/imperative shell, and coupling. Use for design review, architectural assessment, or checking if code is "Rich Hickey approved."
---

# Decomplect

Architectural analysis inspired by Rich Hickey's simplicity philosophy.

## Usage

```
/decomplect                # Run all 3 analyzers in parallel
/decomplect --simplicity   # Specific analyzer
/decomplect --fcis         # Specific analyzer
/decomplect --coupling     # Specific analyzer
```

## Analyzers

| Analyzer | Question |
|----------|----------|
| **simplicity-analyzer** | Is this truly simple or just easy? |
| **fcis-analyzer** | Is pure logic separated from I/O? |
| **coupling-analyzer** | Are modules well-separated? |

## What It Checks

| Pillar | Focus |
|--------|-------|
| **Simplicity** | Values over state, decomplected concerns, explicit dependencies |
| **FCIS** | Functional core (pure), imperative shell (I/O at edges) |
| **Coupling** | High cohesion, low coupling, dependency direction |

## When to Use

- Reviewing system design
- Before major refactoring
- Assessing architectural quality
- Checking if code is "Rich Hickey approved"

## Supported Languages

- TypeScript / JavaScript
- Go
- Rust

## Reference Documentation

- [Rich Hickey Principles](reference/rich-hickey.md)
- [Functional Core/Imperative Shell](reference/fcis.md)
- [Cohesion & Coupling](reference/coupling.md)

## See Also

- `/unslopify` - Tactical code cleanup (types, SRP, fail-fast)
