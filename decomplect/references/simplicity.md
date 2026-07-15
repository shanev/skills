# Simplicity and Decomplection

Use this lens to find independent concepts that have been braided together. “Simple” means
having one role or dimension; it does not mean familiar, short, or easy to write.

## Look for

- **State with identity:** Callers cannot distinguish a value from the mutable place that
  currently stores it.
- **Policy with mechanism:** Business decisions depend directly on transport, storage,
  scheduling, rendering, or framework lifecycle details.
- **What with when:** Correctness depends on implicit call order, timing, or initialization.
- **Data with behavior:** Information can be accessed only through an object that also owns
  unrelated effects or lifecycle.
- **Hidden context:** Globals, ambient state, singletons, thread-local values, or implicit
  framework context affect results without appearing in the contract.
- **Several concepts behind one option:** A flag, mode, or configuration value changes
  multiple independent dimensions at once.

## Validate the cost

Do not report a pattern solely because mutation, objects, callbacks, inheritance, macros, or
framework conventions are present. Establish at least one concrete cost:

- A change to one concern forces edits or retesting in an unrelated concern.
- A unit cannot be understood or tested without reconstructing hidden state or call order.
- Legal combinations are obscured while illegal combinations remain expressible.
- Concurrency or reentrancy makes the implicit ordering observably unsafe.
- Reuse requires importing a mechanism unrelated to the desired policy.

## Prefer proportionate improvements

- Pass values or explicit capabilities where hidden context causes action at a distance.
- Separate independent decisions before introducing an abstraction for them.
- Represent ordering as data or a state transition when timing is part of correctness.
- Isolate framework lifecycle and effects at boundaries when doing so makes policy clearer.
- Keep a direct, cohesive implementation when separation would add indirection without an
  independent reason to change.

## False-positive traps

- Local mutation inside an encapsulated algorithm may be simpler than persistent data.
- A cohesive object can legitimately keep data and the operations that preserve its invariant.
- A small adapter may mix mapping and I/O because the mapping is specific to that boundary.
- A familiar framework convention is not accidental complexity unless it creates a demonstrated
  testing or change cost in this codebase.
