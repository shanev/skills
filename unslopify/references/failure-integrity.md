# Failure Integrity

Use this lens to assess whether failure policy is explicit, observable, and appropriate at each
boundary. “Fail fast” means invalid assumptions should not silently corrupt later behavior; it
does not mean every recoverable failure must terminate the process.

## Look for

- Errors, rejected results, or invalid states discarded without a deliberate policy.
- Catch-all handling that converts distinct failures into success or an unrelated default.
- Required data treated as optional through silent fallback values.
- Unbounded retries, recursion, polling, or recovery loops.
- Partial writes followed by success responses or continued processing.
- Workarounds that bypass a broken invariant while leaving downstream code to guess.
- Logging without propagation, compensation, alerting, or a documented best-effort boundary.
- Assertions or fatal termination in reusable code where callers need control of failure.

## Validate the cost

Trace what the caller or operator observes. Report only when the current policy can hide a bug,
misclassify success, corrupt state, exhaust resources, or make diagnosis materially harder.

## Prefer proportionate improvements

- Validate required conditions at the earliest trustworthy boundary.
- Preserve cause and context when translating errors between layers.
- Make fallback, retry, degradation, and best-effort behavior explicit and bounded.
- Use the ecosystem’s idiomatic error channel; do not prescribe exceptions or result values
  universally.
- Fix the violated invariant instead of normalizing its symptoms when feasible.

## False-positive traps

- Cache misses, optional telemetry, feature flags, compatibility paths, and degraded service can
  have valid fallbacks.
- Broad catches can be correct at process, request, task, or UI boundaries when they report and
  contain failure deliberately.
- Best-effort cleanup may intentionally suppress a secondary error while preserving the primary
  one.
