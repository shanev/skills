---
name: unslopify
description: Review code for weak type or data contracts, mixed responsibilities, hidden failures, workaround-driven error handling, and duplicated knowledge. Use for tactical code-quality review, pull-request review, pre-commit cleanup, refactoring assessment, or requests about type strictness, single responsibility, fail-fast behavior, defensive fallbacks, and DRY. Works across programming languages and mixed-language repositories.
---

# Unslopify

Review tactical code quality through four complementary lenses:

- **Contract strength:** Do types, schemas, validation, and invariants express valid states?
- **Single responsibility:** Does each unit have a coherent reason to change?
- **Failure integrity:** Are failures handled deliberately rather than hidden?
- **Knowledge duplication:** Is the same rule encoded in multiple places?

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

Run all four lenses unless the user selects one. If independent workers or subagents are
available, the lenses may run in parallel with the same scope. Otherwise, run them
sequentially. Parallelism is an optimization, not a requirement.

1. Read [contracts.md](references/contracts.md) for type, schema, validation, nullability,
   state-modeling, and boundary-contract issues.
2. Read [responsibility.md](references/responsibility.md) for mixed change vectors,
   abstraction levels, and orchestration that contains unrelated policy.
3. Read [failure-integrity.md](references/failure-integrity.md) for swallowed failures,
   unbounded recovery, invalid defaults, and workaround-driven control flow.
4. Read [duplication.md](references/duplication.md) for duplicated knowledge and missed shared
   sources of truth without encouraging premature abstraction.
5. Merge overlapping observations into one finding and name the primary root cause.

## Remain language-agnostic

Evaluate contracts and behavior relative to the repository's language and conventions.

- In statically typed code, use the available type system to judge whether invalid states are
  representable unnecessarily.
- In dynamically typed code, consider annotations, schemas, validators, tests, protocols, and
  runtime guards; do not require static typing merely for its own sake.
- Treat exceptions, result values, optionals, error codes, panics, retries, and fallbacks as
  different encodings of failure policy rather than universally good or bad constructs.
- Treat duplicated knowledge as the target of DRY analysis, not repeated syntax alone.
- When a language or framework is unfamiliar, inspect local usage and toolchain evidence and
  lower confidence instead of applying rules from another ecosystem.

## Validate candidates

Report a candidate only when all of the following hold:

- The evidence is observable in the selected scope and necessary context.
- The issue creates a concrete correctness, maintenance, debugging, or change-propagation cost.
- A plausible improvement reduces that cost without adding greater indirection or fragility.
- Confidence is at least 80%.

Treat file length, function length, `any`-like types, force unwraps, broad catches, fallbacks,
comments, and repeated lines as investigation signals—not automatic findings. Respect explicit
resilience boundaries, optional data, generated code, test scaffolding, and intentional local
duplication.

## Report findings

Lead with findings ordered by severity, then provide a short summary. Do not assign an overall
letter grade; severity, confidence, evidence, and impact carry the assessment.

For each finding include:

```markdown
### [high|medium|low] Concise title
- Location: `path:line`
- Lens: contracts | responsibility | failure-integrity | duplication
- Confidence: 80-100%
- Evidence: What the code does and the relevant surrounding context.
- Impact: The concrete failure mode or maintenance cost.
- Recommendation: The smallest change that addresses the cause.
```

Use **high** for likely correctness, data, or security failures; **medium** for material
maintenance, debugging, or change-propagation costs; and **low** for bounded issues worth
addressing. If no qualifying findings exist, say so directly and note any limits in scope.

## Claude Code adapter

Claude Code users may invoke `/unslopify` for a standalone install or
`/unslopify:unslopify` for the plugin, optionally with `--types`, `--srp`, `--fail-fast`, `--dry`,
or `--sequential`. Map the lens flags to contracts, responsibility, failure-integrity, and
duplication respectively; treat `--sequential` as disabling parallel workers and remaining
arguments as the explicit review scope. Other agents should follow this file directly.
