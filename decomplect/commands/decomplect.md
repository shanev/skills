---
name: decomplect
description: Run comprehensive decomplection analysis using all 5 pillars. Orchestrates simplicity, coupling, SRP, type strictness, and FCIS analyzers. Use for full code review before PRs.
---

# Decomplect Command

This command orchestrates all 5 decomplection analyzers for comprehensive code review.

## Usage

```
/decomplect                    # Run all 5 analyzers in parallel (default)
/decomplect --sequential       # Run analyzers one at a time
/decomplect --simplicity       # Run specific pillar only
```

## Execution Workflow

### Step 1: Determine Scope

Get the code changes to analyze:

```bash
# Default: staged changes
git diff --staged

# If nothing staged, use unstaged changes
git diff HEAD

# Filter to supported languages
# Only analyze: *.ts, *.tsx, *.go, *.rs
```

### Step 2: Launch Analyzers

**Default (Parallel):** Launch all 5 agents simultaneously for comprehensive, fast analysis.

**Sequential Mode (`--sequential`):** Run analyzers one at a time for focused feedback.

```
Agents to launch:
1. simplicity-analyzer    (Rich Hickey principles)
2. coupling-analyzer      (Cohesion/Coupling)
3. srp-analyzer          (Single Responsibility)
4. type-strictness-analyzer (Type safety)
5. fcis-analyzer         (Functional Core/Imperative Shell)
```

### Step 3: Aggregate Results

After all agents complete, consolidate into a unified report:

```markdown
# Decomplection Analysis Report

## Overall Grade: [A-F]

Calculated as weighted average:
- Simplicity: 25%
- Coupling: 20%
- SRP: 20%
- Type Strictness: 15%
- FCIS: 20%

## Summary

[2-3 sentence overview of code quality]

## Pillar Scores

| Pillar | Grade | Findings | Top Issue |
|--------|-------|----------|-----------|
| Simplicity | B | 3 | Mutable state in core |
| Coupling | A | 1 | Minor interface leak |
| SRP | C | 4 | Handler does too much |
| Type Strictness | B | 2 | Some `any` usage |
| FCIS | D | 5 | I/O mixed throughout |

## Issues by Severity

### Critical (Must Fix)
[Issues with confidence ≥ 95%]

### Important (Should Fix)
[Issues with confidence 85-94%]

### Suggestions (Consider)
[Issues with confidence 80-84%]

## Detailed Findings

### Simplicity (Rich Hickey)
[Findings from simplicity-analyzer]

### Cohesion/Coupling
[Findings from coupling-analyzer]

### Single Responsibility
[Findings from srp-analyzer]

### Type Strictness
[Findings from type-strictness-analyzer]

### Functional Core/Imperative Shell
[Findings from fcis-analyzer]

## Priority Recommendations

1. **[Highest impact]**: Description
2. **[Second priority]**: Description
3. **[Third priority]**: Description

## Positive Observations

[What the code does well]
```

## Agent Selection

You can run specific pillars:

| Flag | Agent | Focus |
|------|-------|-------|
| (default) | All agents | Full analysis (parallel) |
| `--sequential` | All agents | Full analysis (one at a time) |
| `--simplicity` | simplicity-analyzer | Rich Hickey principles |
| `--coupling` | coupling-analyzer | Module boundaries |
| `--srp` | srp-analyzer | Responsibility focus |
| `--types` | type-strictness-analyzer | Type safety |
| `--fcis` | fcis-analyzer | Pure/impure separation |

## Examples

**Full review before PR:**
```
User: /decomplect
Claude: Launching all 5 analyzers in parallel...
[Aggregated report]
```

**Quick simplicity check:**
```
User: /decomplect --simplicity
Claude: Running simplicity analyzer...
[Simplicity report only]
```

**Focus on types and FCIS:**
```
User: Check my code for type safety and pure function separation
Claude: Running type-strictness-analyzer and fcis-analyzer...
[Combined report]
```

## Grading Scale

| Grade | Description |
|-------|-------------|
| A | Excellent - minimal issues, well-designed |
| B | Good - minor issues, mostly clean |
| C | Acceptable - some issues need attention |
| D | Poor - significant issues, refactoring needed |
| F | Failing - major redesign recommended |

## Tips

- Run before creating PRs for comprehensive review
- Use `--all` for speed when you want parallel analysis
- Focus on high-confidence (≥90%) issues first
- Not every suggestion needs to be implemented
