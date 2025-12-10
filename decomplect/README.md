# Decomplect Code Analysis Skill

Analyze your code for simplicity using Rich Hickey's decomplection principles.

## What it Does

This skill evaluates your code changes against 5 pillars of simplicity:

1. **Simplicity (Rich Hickey)** - Is the code truly simple or just easy?
2. **High-Cohesion, Low-Coupling** - Are modules well-separated?
3. **Single Responsibility** - Does each unit have one job?
4. **Type Strictness** - Are types as strong as possible?
5. **Functional Core, Imperative Shell** - Is logic separated from I/O?

## Supported Languages

- TypeScript / JavaScript
- Go
- Rust

## Usage

Ask Claude to analyze your code:

```
"Review my staged changes for decomplection"
"Would Rich Hickey approve of this PR?"
"Check this code for simplicity issues"
"Analyze my diff for coupling problems"
```

## Output

You'll get a structured report with:

- Overall grade (A-F)
- Per-pillar scores with key findings
- Specific issues with file:line references
- Refactoring suggestions with before/after code
- Priority recommendations

## Example

```
User: Review my staged changes

Claude: # Decomplection Analysis

## Overall Grade: C

## Pillar Scores

| Pillar | Grade | Key Finding |
|--------|-------|-------------|
| Simplicity | C | Mutable state in core logic |
| Cohesion/Coupling | B | Minor coupling issues |
| Single Responsibility | D | Handler does too much |
| Type Strictness | B | Some `any` types |
| Functional Core | D | I/O mixed with logic |

## Findings & Refactoring Suggestions

### 1. Simplicity: C

**Issue:** `user-service.ts:45` - Mutation in business logic

[Shows current code and suggested refactor...]
```

## Philosophy

This skill is inspired by Rich Hickey's talks:

- **Simple Made Easy** - Distinguishing simple from easy
- **The Value of Values** - Preferring immutable values
- **Hammock Driven Development** - Thinking before coding

The goal is code that is:
- Easy to understand in isolation
- Easy to change without fear
- Easy to test without mocks
- Easy to reuse in different contexts

## Installation

This skill is part of the `shanev-skills` plugin:

```bash
# In Claude Code
/plugin marketplace add shanev-skills
```

## See Also

- [EXAMPLES.md](EXAMPLES.md) - Full analysis examples
- [reference/](reference/) - Deep dives on each principle
