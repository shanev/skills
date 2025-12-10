---
name: unslopify
description: Tactical code cleanup focusing on type strictness, single responsibility, and fail-fast patterns. Detects sloppy code, workarounds, silent failures, and god classes. Use for quick code quality checks before committing or during code review.
---

# Unslopify

Tactical code cleanup focused on immediate quality issues.

## Usage

```
/unslopify                # Run all 3 analyzers in parallel
/unslopify --types        # Type strictness only
/unslopify --srp          # Single responsibility only
/unslopify --fail-fast    # Fail-fast only
```

## Analyzers

| Analyzer | Question |
|----------|----------|
| **type-strictness-analyzer** | Are types as strong as possible? |
| **srp-analyzer** | Does each unit have one job? |
| **fail-fast-analyzer** | Do errors surface immediately? |

## What's "Sloppy"?

| Sloppy | Clean |
|--------|-------|
| `any`, `interface{}`, `unwrap()` | Strong domain types |
| God classes, 500-line functions | Focused, single-purpose |
| `catch (e) { }` swallowed | Explicit error handling |
| `// HACK:` comments | Fix the root cause |
| Silent fallbacks | Fail fast, fail loud |

## When to Use

- Quick code review
- Before committing
- Cleaning up tech debt
- Checking for obvious issues

## Supported Languages

- TypeScript / JavaScript
- Go
- Rust

## Reference Documentation

- [Type Strictness](reference/types.md)
- [Single Responsibility](reference/srp.md)
