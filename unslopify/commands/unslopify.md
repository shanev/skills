---
name: unslopify
description: Tactical code cleanup focusing on type strictness, single responsibility, fail-fast patterns, and DRY. Detects sloppy code, workarounds, silent failures, and duplication. Use for quick code quality checks.
---

# Unslopify Command

Tactical cleanup focused on immediate code quality issues.

## Usage

```
/unslopify                # Run all 4 tactical analyzers in parallel
/unslopify --sequential   # Run one at a time
/unslopify --types        # Run specific analyzer only
```

## What It Analyzes

| Analyzer | Question | Focus |
|----------|----------|-------|
| **type-strictness-analyzer** | Are types as strong as possible? | No `any`, domain types, null safety |
| **srp-analyzer** | Does each unit have one job? | God classes, kitchen-sink functions |
| **fail-fast-analyzer** | Do errors surface immediately? | No workarounds, no silent fallbacks |
| **dry-analyzer** | Is there duplicated code? | Copy-paste, repeated logic, missed abstractions |

## Execution

Launches 4 agents in parallel:
1. **type-strictness-analyzer** - Type safety and domain modeling
2. **srp-analyzer** - Single Responsibility Principle
3. **fail-fast-analyzer** - No workarounds, fail fast
4. **dry-analyzer** - Don't Repeat Yourself

## What's "Sloppy"?

| Sloppy | Clean |
|--------|-------|
| `any`, `interface{}`, `unwrap()` | Strong domain types |
| God classes, 500-line functions | Focused, single-purpose units |
| `catch (e) { }` (swallowed) | Explicit error handling |
| `?? defaultValue` everywhere | Fail on missing data |
| `// HACK:` comments | Fix the root cause |
| Silent fallbacks | Fail fast, fail loud |
| Copy-pasted code blocks | Extracted helpers/utilities |

## Output

```markdown
# Unslopify Analysis

## Overall Grade: [A-F]

## Summary
[Code quality assessment]

## Pillar Scores

| Pillar | Grade | Key Finding |
|--------|-------|-------------|
| Type Strictness | B | Some `any` usage |
| SRP | C | Handler does too much |
| Fail-Fast | D | Silent error swallowing |

## Detailed Findings
[Per-analyzer findings with fixes]

## Recommendations
[Priority cleanups]
```

## Agent Selection

| Flag | Analyzer |
|------|----------|
| (default) | All 4 in parallel |
| `--sequential` | All 4, one at a time |
| `--types` | Type strictness only |
| `--srp` | SRP only |
| `--fail-fast` | Fail-fast only |
| `--dry` | DRY only |

## When to Use

- Quick code review
- Before committing
- Cleaning up tech debt
- Checking for obvious issues

## See Also

- `/decomplect` - Deep architectural analysis (simplicity, FCIS, coupling)
