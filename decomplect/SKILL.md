---
name: decomplecting-code
description: Analyzes git diff/staged changes for simplicity and decomplection using Rich Hickey's principles. Evaluates TypeScript, Go, and Rust code for high-cohesion/low-coupling, single responsibility, type strictness, and functional core/imperative shell patterns. Provides specific refactoring suggestions. Use when reviewing code changes, preparing PRs, or checking if code "would get a good grade from Rich Hickey."
---

# Decomplecting Code Skill

## Overview

This skill analyzes code changes for **decomplection** - Rich Hickey's term for separating intertwined concerns. Code is evaluated against 5 pillars of simplicity, with specific refactoring suggestions provided.

**Target:** Git diff/staged changes in TypeScript, Go, and Rust.

## Critical Workflow

When analyzing code for decomplection:

1. **Get the changes**: Run `git diff HEAD` or `git diff --staged`
2. **Filter relevant files**: Only analyze `*.ts`, `*.tsx`, `*.go`, `*.rs`
3. **Evaluate each pillar**: Score A-F based on criteria below
4. **Generate report**: Structured output with grades and findings
5. **Provide refactoring suggestions**: Specific code examples for improvements

**CRITICAL:** Always provide concrete refactoring suggestions with before/after code examples. Don't just identify problems - show solutions.

## The 5 Pillars

### Pillar 1: Simplicity (Rich Hickey Grade)

Evaluates whether code is truly **simple** (easy to understand, compose, change) vs merely **easy** (familiar, convenient).

**Check for:**
- **Complected concerns**: State + identity, what + when + how, value + place
- **Mutation**: Prefer immutable values over mutable state
- **Side effects**: Should be explicit and at boundaries
- **Hidden dependencies**: Global state, singletons, implicit context

**Grading:**
- **A**: Pure functions, immutable data, explicit dependencies
- **B**: Mostly immutable, minor state where justified
- **C**: Mixed - some unnecessary mutation or complection
- **D**: Significant complection, hidden dependencies
- **F**: Pervasive mutation, tightly coupled state and behavior

**See:** [reference/rich-hickey.md](reference/rich-hickey.md) for detailed simplicity concepts.

### Pillar 2: High-Cohesion, Low-Coupling

Evaluates module boundaries and dependency management.

**Check for:**
- **Cohesion**: Related functionality grouped together
- **Coupling**: Minimal dependencies between modules
- **Interfaces**: Clear contracts at boundaries
- **Dependency direction**: Depend on abstractions, not concretions

**Grading:**
- **A**: Clear module boundaries, dependency injection, minimal cross-cutting
- **B**: Good separation with minor coupling issues
- **C**: Some unclear boundaries or unnecessary dependencies
- **D**: Significant coupling, circular dependencies
- **F**: Spaghetti code, everything depends on everything

**See:** [reference/coupling.md](reference/coupling.md) for cohesion/coupling patterns.

### Pillar 3: Single Responsibility Principle

Evaluates whether each unit has one reason to change.

**Check for:**
- **Functions**: One task, one level of abstraction
- **Types/Structs**: One concept, cohesive fields
- **Modules**: One domain area
- **God objects**: Classes/structs doing too much

**Grading:**
- **A**: Each function/type has clear, single purpose
- **B**: Mostly focused with minor violations
- **C**: Some functions/types doing multiple things
- **D**: Several "kitchen sink" functions or god objects
- **F**: No clear responsibilities, everything mixed

**See:** [reference/srp.md](reference/srp.md) for SRP patterns.

### Pillar 4: Type Strictness

Evaluates type system usage (language-specific).

**TypeScript:**
- No `any` (use `unknown` with narrowing if needed)
- Strict null checks enabled and respected
- Discriminated unions over loose object types
- Branded types for domain concepts

**Go:**
- Meaningful type aliases for domain concepts
- Small, focused interfaces (interface segregation)
- Avoid `interface{}` / `any` - use generics or specific types
- Error types with context

**Rust:**
- Newtype pattern for domain concepts
- `Result`/`Option` over panics
- Avoid `.unwrap()` in library code
- Leverage enums for state machines

**Grading:**
- **A**: Types express domain invariants, no escape hatches
- **B**: Strong types with minimal escape hatches, justified
- **C**: Some weak typing (`any`, `interface{}`, excessive `unwrap`)
- **D**: Frequent type escape hatches, weak domain modeling
- **F**: Types as afterthought, pervasive `any`/`interface{}`

**See:** [reference/types.md](reference/types.md) for language-specific type patterns.

### Pillar 5: Functional Core, Imperative Shell

Evaluates separation of pure logic from side effects.

**Check for:**
- **Pure core**: Business logic in pure functions (no I/O, no mutation)
- **Imperative shell**: I/O and side effects at the edges
- **Testability**: Core logic testable without mocks
- **Separation**: Clear boundary between pure and impure

**Grading:**
- **A**: Clear separation, pure core easily testable
- **B**: Mostly separated with minor mixing
- **C**: Some business logic mixed with I/O
- **D**: Side effects scattered throughout
- **F**: No separation, I/O everywhere

**See:** [reference/fcis.md](reference/fcis.md) for functional core patterns.

## Output Format

Generate a structured report:

```markdown
# Decomplection Analysis

## Overall Grade: [A-F]

## Summary
[1-2 sentence overview of the changes and key findings]

## Pillar Scores

| Pillar | Grade | Key Finding |
|--------|-------|-------------|
| Simplicity | [A-F] | [Brief description] |
| Cohesion/Coupling | [A-F] | [Brief description] |
| Single Responsibility | [A-F] | [Brief description] |
| Type Strictness | [A-F] | [Brief description] |
| Functional Core | [A-F] | [Brief description] |

## Findings & Refactoring Suggestions

### 1. Simplicity: [Grade]

[For each issue found, show:]

**Issue:** `file:line` - [Description]
```[language]
// Current code
```

**Suggested refactor:**
```[language]
// Improved code
```

**Why:** [Explain the decomplection benefit]

### 2. Cohesion/Coupling: [Grade]
[Same format...]

### 3. Single Responsibility: [Grade]
[Same format...]

### 4. Type Strictness: [Grade]
[Same format...]

### 5. Functional Core: [Grade]
[Same format...]

## Priority Recommendations

1. **[Highest impact]**: [Brief description and why]
2. **[Second priority]**: [Brief description and why]
3. **[Third priority]**: [Brief description and why]
```

## Common Refactoring Patterns

### Pattern: Complected State → Values + Functions

```typescript
// Before: complected state and behavior
class Counter {
  private count = 0;
  increment() { this.count++; }
  getCount() { return this.count; }
}

// After: separated
type Count = number;
const increment = (count: Count): Count => count + 1;
```

### Pattern: Mixed I/O → Functional Core

```go
// Before: I/O mixed with logic
func ProcessUser(id string) error {
    user, err := db.GetUser(id)  // I/O
    if err != nil { return err }

    user.Score = calculateScore(user)  // Logic
    user.Level = determineLevel(user.Score)  // Logic

    return db.SaveUser(user)  // I/O
}

// After: separated
func ProcessUserLogic(user User) User {  // Pure
    score := calculateScore(user)
    return User{...user, Score: score, Level: determineLevel(score)}
}

func ProcessUser(id string) error {  // Shell
    user, err := db.GetUser(id)
    if err != nil { return err }
    updated := ProcessUserLogic(user)
    return db.SaveUser(updated)
}
```

### Pattern: Weak Types → Strong Types

```rust
// Before: stringly typed
fn process_order(user_id: String, product_id: String, amount: i64)

// After: newtype pattern
struct UserId(String);
struct ProductId(String);
struct Money(i64);

fn process_order(user_id: UserId, product_id: ProductId, amount: Money)
```

## Tips

- **Focus on changed code**: Don't review entire files, just the diff
- **Prioritize high-impact issues**: Not every minor issue needs a suggestion
- **Be specific**: Reference exact file:line locations
- **Show, don't tell**: Always include code examples
- **Consider context**: A quick prototype has different standards than production code

## Examples

**See:** [EXAMPLES.md](EXAMPLES.md) for complete analysis examples.
