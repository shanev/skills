# Cohesion and Coupling

Use this lens to assess whether boundaries keep related changes together and constrain how
unrelated components depend on one another.

## Examine cohesion

A cohesive unit has a clear purpose and changes for related reasons. Low cohesion often appears
as unrelated policy sharing a module, a generic utility that owns several domains, or a public
surface that exposes features used by disjoint callers.

Do not infer low cohesion from size alone. A large parser, protocol implementation, generated
table, or cohesive domain model may have one reason to change.

## Examine coupling

Look for dependencies that increase change propagation:

- Access to another component’s internal representation or lifecycle.
- Shared mutable state or ambient configuration.
- Callers passing flags that control another component’s internal algorithm.
- Interfaces or protocols wider than any caller needs.
- Domain policy depending outward on storage, transport, UI, or vendor-specific details.
- Import, package, module, schema, build, or deployment cycles.
- Data structures that force consumers to depend on fields irrelevant to their job.
- Temporal contracts that are real but undocumented or unenforced.

Coupling through explicit data and stable contracts is often desirable. The objective is not
zero dependencies; it is dependencies whose direction and surface match ownership and change.

## Validate the cost

Establish how a change crosses a boundary: coordinated edits, broad rebuilds, lockstep releases,
fragile tests, cycles, accidental data exposure, or an inability to substitute a boundary in a
real use case.

## Prefer proportionate improvements

- Narrow the public contract to what consumers need.
- Move a boundary toward the component that owns the policy it expresses.
- Pass focused values instead of broad context objects when irrelevant fields create coupling.
- Invert a dependency only when a stable policy needs independence from a variable mechanism.
- Break cycles at the conceptual ownership boundary, not with a miscellaneous shared module.
- Keep direct dependencies when they are stable, local, and easier to understand than an added
  abstraction.

## False-positive traps

- Two modules importing each other may be legal in a language, but report only if the cycle has
  an observable initialization, build, ownership, or change cost.
- Dependency injection is not automatically better than direct construction.
- Reusing a shared data model is not harmful stamp coupling when the consumers genuinely share
  the same concept and lifecycle.
