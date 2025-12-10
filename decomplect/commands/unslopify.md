---
name: unslopify
description: Clean up sloppy code using Rich Hickey's decomplection principles. Runs 5 analyzers for simplicity, coupling, SRP, type strictness, and functional core patterns. Alias for /decomplect.
---

# Unslopify Command

Alias for `/decomplect`. Runs all 5 code quality analyzers in parallel.

## Usage

```
/unslopify                    # Run all 5 analyzers in parallel (default)
/unslopify --sequential       # Run analyzers one at a time
/unslopify --simplicity       # Run specific pillar only
```

## What It Checks

| Pillar | What's "Sloppy" | What's Clean |
|--------|-----------------|--------------|
| Simplicity | Complected concerns, hidden state | Values, pure functions |
| Coupling | Spaghetti dependencies | Clear module boundaries |
| SRP | God classes, kitchen-sink functions | Focused, single-purpose |
| Types | `any`, `interface{}`, `unwrap()` | Strong domain types |
| FCIS | I/O mixed with logic | Pure core, side effects at edges |

## Execution

Launches all 5 agents in parallel:
1. simplicity-analyzer
2. coupling-analyzer
3. srp-analyzer
4. type-strictness-analyzer
5. fcis-analyzer

Aggregates results into a single report with grades (A-F) and refactoring suggestions.

## Examples

```
/unslopify                     # Full analysis
/unslopify --types             # Just check type strictness
/unslopify --simplicity --srp  # Check simplicity and SRP
```

## See Also

- `/decomplect` - Same command, different name
