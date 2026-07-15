# Contract Strength

Use this lens to assess whether code expresses and enforces the states and values it actually
accepts. A contract may be encoded by static types, schemas, validators, protocols, assertions,
tests, documentation, or deliberate runtime checks.

## Look for

- Broad escape hatches that erase information already known at the boundary.
- Optional or nullable values where absence is not a legal domain state.
- Several fields whose legal combinations are implicit rather than modeled.
- Primitive values reused for distinct domain concepts and easily interchanged.
- Unchecked casts, downcasts, deserialization, foreign data, or boundary inputs.
- Declared return values or errors that contradict reachable behavior.
- Mutable values exposed where callers can violate an invariant.
- Dynamic objects or maps passed across important boundaries without validation or tests.

## Adapt to the ecosystem

- Use the strongest *idiomatic and available* mechanism; do not demand static typing in a
  dynamic language.
- Consider schemas, property tests, contracts, protocols, pattern matching, refinements, and
  constructors alongside nominal types.
- Treat untyped boundary data as normal until it crosses into trusted domain logic.
- Treat a broad type as intentional when the operation genuinely accepts arbitrary values and
  validates them safely.

## Validate the cost

Show a reachable invalid state, confused value, missed validation, misleading API, or refactor
hazard. A stronger contract should remove a real ambiguity rather than add ceremonial wrappers.

## Prefer proportionate improvements

- Validate once at an untrusted boundary and pass a trusted representation inward.
- Model mutually exclusive states explicitly when callers otherwise coordinate fields manually.
- Introduce domain-specific values when accidental interchange is plausible and costly.
- Narrow public contracts without overconstraining legitimate callers.
- Align declarations, documentation, tests, and runtime behavior.

## False-positive traps

- Generic infrastructure often requires broad or erased types.
- Tests, adapters, reflection, serialization, and interop may need controlled escape hatches.
- Force unwraps, assertions, casts, or panics can be valid when a nearby invariant proves them;
  report the missing or breakable invariant, not the syntax alone.
