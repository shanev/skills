# Knowledge Duplication

Use this lens to find one rule, invariant, mapping, calculation, or policy encoded in multiple
places that must remain synchronized. DRY concerns duplicated knowledge, not visual similarity.

## Look for

- The same business rule implemented independently in several paths.
- Constants, status mappings, schemas, validation rules, or protocol details with one owner but
  several definitions.
- Copied error handling or transformations that evolve together.
- Parallel branches differing only by data that could be represented declaratively.
- Tests reproducing production algorithms instead of asserting outcomes or using shared data.

## Validate the cost

Show that copies represent the same knowledge and are expected to change together. Prefer
repository history, neighboring inconsistencies, shared terminology, or the domain contract as
evidence. Similar syntax alone is insufficient.

## Prefer proportionate improvements

- Establish one source of truth for owned data, rules, and mappings.
- Extract a shared operation when callers need the same policy and the contract is stable.
- Replace parallel conditional code with data only when the data model is clearer.
- Generate repeated artifacts when synchronization is mechanical and generation is reliable.
- Keep duplication local when an abstraction would couple concepts that can evolve separately.

## False-positive traps

- Two or three simple lines can be clearer than a shared abstraction.
- Similar code in independent domains may be coincidental and should remain separate.
- Tests may intentionally repeat expected values to avoid reproducing the implementation.
- Generated, vendored, migration, and compatibility code often duplicates structure for valid
  lifecycle reasons.
