---
name: decomplect
description: Architectural code analysis for design quality. Evaluates simplicity (Rich Hickey), functional core/imperative shell (Gary Bernhardt), and coupling (Constantine & Yourdon). Use for design review or architectural assessment.
---

# Decomplect

Architectural analysis for design quality.

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
| **Simplicity** | Values over state, decomplected concerns |
| **FCIS** | Functional core (pure), imperative shell (I/O) |
| **Coupling** | High cohesion, low coupling |

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
