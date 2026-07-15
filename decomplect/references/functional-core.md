# Functional Core and Imperative Shell

Use this lens to determine whether deterministic policy can be understood and tested separately
from effects. The goal is a useful boundary, not purity everywhere.

## Classify behavior

Treat behavior as part of the **functional core** when its result is determined by explicit
inputs and it does not observably read or change the outside world. Treat behavior as part of
the **imperative shell** when it coordinates storage, network, filesystem, UI, clocks, random
values, process state, logging, queues, or other effects.

Equivalent encodings vary by language. Pure behavior may be a function, method, reducer,
declarative rule, query, or value transformation. Effects may use exceptions, callbacks,
coroutines, actors, capabilities, commands, or framework hooks.

## Look for

- Business rules embedded between reads and writes in a handler or adapter.
- Domain calculations that directly fetch clocks, identifiers, randomness, configuration, or
  global state.
- “Pure” APIs that mutate inputs, caches, shared state, or hidden collaborators.
- Tests that require extensive I/O mocking just to exercise deterministic decisions.
- Effectful orchestration duplicated because the reusable policy has no independent boundary.
- Domain results represented only as side effects, making composition and validation difficult.

## Validate the cost

Report only when extracting or clarifying the policy boundary would materially improve at least
one of testability, determinism, reuse, reasoning, or failure handling. Identify the actual
policy and effect rather than saying merely that a function “does too much.”

## Prefer proportionate improvements

- Read inputs at the boundary, pass plain domain values into policy, then interpret the result.
- Inject nondeterministic values when reproducibility matters; do not wrap every standard call.
- Return decisions, state transitions, or commands when that makes effects explicit.
- Keep transactional coordination in the shell while moving calculations and validation into
  the core.
- Preserve a direct adapter when its logic is boundary-specific and already easy to test.

## False-positive traps

- Logging or metrics in an imperative shell are expected effects.
- A tiny CRUD endpoint may have no meaningful domain policy to extract.
- Framework callbacks and UI views are often shells by design.
- Throwing, panicking, or returning an error does not by itself determine purity; inspect whether
  the behavior depends only on explicit inputs and the language’s observable semantics.
