---
name: decomplect
description: Deep architectural analysis using Rich Hickey's decomplection principles. Evaluates simplicity, functional core/imperative shell, and coupling. Use for design review and architectural assessment.
---

# Decomplect Command

Architectural analysis focused on Rich Hickey's simplicity philosophy.

## Usage

```
/decomplect                # Run all 3 architectural analyzers in parallel
/decomplect --sequential   # Run one at a time
/decomplect --simplicity   # Run specific analyzer only
```

## What It Analyzes

| Analyzer | Question | Focus |
|----------|----------|-------|
| **simplicity-analyzer** | Is this truly simple or just easy? | Values over state, decomplected concerns |
| **fcis-analyzer** | Is pure logic separated from I/O? | Functional core, imperative shell |
| **coupling-analyzer** | Are modules well-separated? | Cohesion, coupling, dependency direction |

## Execution

Launches 3 agents in parallel:
1. **simplicity-analyzer** - Rich Hickey's decomplection principles
2. **fcis-analyzer** - Functional Core, Imperative Shell pattern
3. **coupling-analyzer** - Module boundaries and dependencies

## Output

```markdown
# Decomplection Analysis

## Overall Grade: [A-F]

## Summary
[Architectural assessment]

## Pillar Scores

| Pillar | Grade | Key Finding |
|--------|-------|-------------|
| Simplicity | B | Some complected concerns |
| FCIS | C | I/O mixed with logic |
| Coupling | A | Well-separated modules |

## Detailed Findings
[Per-analyzer findings with refactoring suggestions]

## Recommendations
[Priority architectural improvements]
```

## Agent Selection

| Flag | Analyzer |
|------|----------|
| (default) | All 3 in parallel |
| `--sequential` | All 3, one at a time |
| `--simplicity` | Simplicity only |
| `--fcis` | FCIS only |
| `--coupling` | Coupling only |

## When to Use

- Reviewing system design
- Before major refactoring
- Assessing architectural quality
- Checking if code is "Rich Hickey approved"

## See Also

- `/unslopify` - Tactical code cleanup (types, SRP, fail-fast)
