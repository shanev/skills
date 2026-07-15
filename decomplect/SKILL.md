---
name: decomplect
description: Review code and architecture for accidental complexity, mixed pure logic and effects, weak boundaries, and harmful coupling. Use for design reviews, architecture assessments, pre-refactor analysis, pull-request review, or questions about simplicity, functional core/imperative shell, cohesion, dependency direction, and Rich Hickey's decomplection principles. Works across programming languages and mixed-language repositories.
---

# Decomplect

Review architecture through three complementary lenses:

- **Simplicity:** Are independent concerns intertwined?
- **Functional core / imperative shell:** Is deterministic policy separated from effects?
- **Cohesion and coupling:** Do boundaries group related behavior and constrain dependencies?

Perform a review by default. Do not edit code unless the user explicitly asks for changes.

## Select the scope

Honor an explicit user-provided review scope before applying defaults. Accept files,
directories, snippets, diffs, commits, branches, pull-request refs, or the whole repository.
A comparison-base option by itself configures branch comparison; it is not a review scope.

When the user does not specify a scope:

1. In a Git repository, inspect working-tree changes relative to `HEAD`.
2. If the working tree is clean, resolve the comparison base in this order: a comparison-base
   option supplied by the user, the remote's symbolic default branch, then the configured
   upstream when no remote default can be determined. Never assume `main`.
3. Compute the merge base between that ref and `HEAD`, then review from the merge base through
   `HEAD`. This includes already-pushed feature commits instead of comparing a feature branch
   only with its same-named remote tracking branch.
4. If no base or meaningful diff can be determined, ask for a scope or report that there is
   nothing to review.
5. Outside Git with no explicit review scope, ask the user for files, a directory, a diff, or a
   snippet to review.

Read enough surrounding code, tests, configuration, and documentation to validate each
finding. Distinguish problems introduced by the selected changes from relevant pre-existing
context. Exclude generated, vendored, minified, lock, and snapshot files unless requested.

## Apply the review lenses

Run all three lenses unless the user selects one. If independent workers or subagents are
available, the lenses may run in parallel with the same scope. Otherwise, run them
sequentially. Parallelism is an optimization, not a requirement.

1. Read [simplicity.md](references/simplicity.md) for intertwined concerns, hidden state,
   ordering, and incidental mechanisms.
2. Read [functional-core.md](references/functional-core.md) for policy/effect separation,
   deterministic logic, and testable boundaries.
3. Read [coupling.md](references/coupling.md) for cohesion, dependency direction, interface
   size, and change propagation.
4. Merge overlapping observations into one finding. Prefer the lens that best explains the
   root design problem and mention secondary effects briefly.

## Remain language-agnostic

Evaluate semantics rather than syntax. Infer state, effects, contracts, dependency direction,
and module boundaries using the repository's language, framework, tests, and conventions.

- Treat examples in the references as illustrations, not required syntax.
- Respect idiomatic ownership, error, concurrency, and dependency patterns.
- Do not demand pure functions, dependency injection, interfaces, or immutability where they
  add indirection without reducing change cost.
- When a language or framework is unfamiliar, inspect local usage and toolchain evidence and
  lower confidence instead of applying rules from another ecosystem.

## Validate candidates

Report a candidate only when all of the following hold:

- The evidence is observable in the selected scope and necessary context.
- The design creates a concrete correctness, changeability, testability, or operability cost.
- A plausible improvement reduces that cost without merely moving complexity elsewhere.
- Confidence is at least 80%.

Do not report style preferences, speculative future abstractions, or intentional tradeoffs
without evidence of harm. Mention a tradeoff when the current design is reasonable.

## Report findings

Lead with findings ordered by severity, then provide a short summary. Do not assign an overall
letter grade; severity, confidence, evidence, and impact carry the assessment.

For each finding include:

```markdown
### [high|medium|low] Concise title
- Location: `path:line`
- Lens: simplicity | functional-core | coupling
- Confidence: 80-100%
- Evidence: What the code does and the relevant surrounding context.
- Impact: The concrete failure mode or change cost.
- Recommendation: The smallest design change that addresses the cause.
```

Use **high** for likely correctness, data, security, or systemic architecture failures;
**medium** for material changeability, testability, or operability costs; and **low** for
bounded issues worth addressing. If no qualifying findings exist, say so directly and note
any limits in the reviewed scope.

## Claude Code adapter

Claude Code users may invoke `/decomplect` for a standalone install or
`/decomplect:decomplect` for the plugin, optionally with `--simplicity`, `--fcis`, `--coupling`,
or `--sequential`. Treat a lens flag as selecting only that lens, treat `--sequential` as
disabling parallel workers, and treat remaining arguments as the explicit review scope. Other
agents should follow this file directly.
