# Single Responsibility

Use this lens to find units that change for unrelated actors, policies, or operational reasons.
Apply it to functions, types, modules, services, jobs, views, handlers, and configuration.

## Look for

- One unit owning unrelated domain rules or workflows.
- Boundary orchestration mixed with substantial policy, formatting, persistence, or delivery.
- Functions that jump repeatedly between abstraction levels.
- Generic helper modules that accumulate unrelated behavior.
- A public API serving several unrelated caller groups through one mutable implementation.
- Tests that require unrelated fixtures because the production unit owns unrelated concerns.

Size, number of methods, and line count are investigation signals only. The stronger evidence is
that different changes arrive for different reasons and repeatedly touch the same unit.

## Validate the cost

Identify at least two independent change vectors and show the resulting coordination cost,
regression surface, test setup, ownership ambiguity, or deployment coupling.

## Prefer proportionate improvements

- Separate policy from orchestration when each changes independently.
- Extract a cohesive concept with its own contract, rather than fragments named after technical
  steps.
- Keep related invariants together even if the unit remains large.
- Split public surfaces by caller need when consumers otherwise depend on unrelated behavior.
- Avoid replacing one cohesive function with many one-line forwarding layers.

## False-positive traps

- An application service may legitimately orchestrate several collaborators for one use case.
- A parser, compiler pass, protocol handler, migration, or generated unit may be large but
  cohesive.
- Code that changes together for the same business rule belongs together even if it performs
  several mechanical steps.
