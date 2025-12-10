# Unslopify

Tactical code cleanup focused on immediate quality issues.

## Overview

Asks: *"Is this clean?"*

```
/unslopify
```

Runs 3 analyzers in parallel to detect sloppy code patterns.

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
| `?? defaultValue` everywhere | Fail on missing data |

## Usage

```
/unslopify                # All 3 analyzers in parallel
/unslopify --sequential   # One at a time
/unslopify --types        # Type strictness only
/unslopify --srp          # SRP only
/unslopify --fail-fast    # Fail-fast only
```

## When to Use

- Quick code review
- Before committing
- Cleaning up tech debt
- Checking for obvious issues

## Supported Languages

- TypeScript / JavaScript
- Go
- Rust

## Installation

```bash
/plugin marketplace add shanev/skills
/plugin install unslopify@shanev-skills
```

## Architecture

```
unslopify/
├── agents/
│   ├── type-strictness-analyzer.md
│   ├── srp-analyzer.md
│   └── fail-fast-analyzer.md
├── commands/
│   └── unslopify.md
└── reference/
    ├── types.md
    └── srp.md
```

## See Also

- `/decomplect` - Deep architectural analysis (simplicity, FCIS, coupling)
