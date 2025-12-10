# Rich Hickey's Simplicity Principles

## Core Philosophy

Rich Hickey (creator of Clojure) distinguishes between **simple** and **easy**:

- **Simple**: Not intertwined. One role, one concept, one dimension. Opposite of complex (complected).
- **Easy**: Near at hand. Familiar. Convenient. Opposite of hard.

**Key insight**: Easy is relative to the person. Simple is objective.

## What is Complecting?

**Complecting** = braiding/intertwining concerns that should be separate.

### Common Complections

| Complected | Decomplected |
|------------|--------------|
| State + Identity | Values + Managed references |
| What + How | Declarative + Implementation |
| What + When | Logic + Scheduling/Ordering |
| What + Who | Logic + Polymorphism dispatch |
| Values + Place | Immutable values + References |
| Rules + Enforcement | Data validation + Schema |

## Simple Made Easy (Key Concepts)

### 1. Values Over State

```typescript
// Complected: value tied to place/identity
class User {
  name: string;
  setName(n: string) { this.name = n; }
}

// Decomplected: immutable values
type User = { readonly name: string };
const rename = (user: User, name: string): User => ({ ...user, name });
```

### 2. Functions Over Methods

```go
// Complected: behavior tied to struct
type User struct { /* ... */ }
func (u *User) Validate() error { /* ... */ }

// Decomplected: function operates on data
type User struct { /* ... */ }
func ValidateUser(u User) error { /* ... */ }
```

### 3. Data Over Objects

```rust
// Complected: data + behavior + identity
struct OrderProcessor {
    orders: Vec<Order>,
    fn process(&mut self) { /* ... */ }
}

// Decomplected: plain data + separate functions
struct Order { /* ... */ }
fn process_orders(orders: &[Order]) -> Vec<ProcessedOrder> { /* ... */ }
```

### 4. Set Functions Over Iteration

```typescript
// Complected: how (loop) with what (transformation)
const result = [];
for (const item of items) {
  if (item.active) {
    result.push(transform(item));
  }
}

// Decomplected: declarative
const result = items.filter(i => i.active).map(transform);
```

### 5. Managed References Over Mutable Variables

```go
// Complected: shared mutable state
var config Config // global, mutable

// Decomplected: explicit dependency
func NewService(config Config) *Service { /* ... */ }
```

## The Simplicity Checklist

When reviewing code, ask:

1. **Can I understand this in isolation?** (no hidden dependencies)
2. **Can I change this without fear?** (no action at a distance)
3. **Can I test this without mocks?** (pure functions)
4. **Can I reuse this in a different context?** (not tied to framework)
5. **Can I reason about this locally?** (referential transparency)

## Complexity Smells

- Mutable state shared across functions
- Implicit dependencies (globals, singletons)
- Callbacks that modify external state
- Objects that are both data containers and actors
- Methods that do I/O and computation
- Inheritance hierarchies for code reuse

## Simplicity Patterns

### Pattern: Replace Mutation with Transformation

```typescript
// Before
function processItems(items: Item[]) {
  for (const item of items) {
    item.processed = true;  // mutation
    item.result = compute(item);  // mutation
  }
  return items;
}

// After
function processItems(items: readonly Item[]): ProcessedItem[] {
  return items.map(item => ({
    ...item,
    processed: true,
    result: compute(item)
  }));
}
```

### Pattern: Replace Hidden State with Explicit Parameters

```go
// Before: hidden dependency
var logger *Logger

func Process(data Data) error {
    logger.Info("processing")  // where does logger come from?
    // ...
}

// After: explicit dependency
func Process(logger *Logger, data Data) error {
    logger.Info("processing")
    // ...
}
```

### Pattern: Replace Time Coupling with Data Flow

```rust
// Before: operations must happen in order
fn process() {
    validate();  // must be first
    transform(); // must be second
    save();      // must be third
}

// After: data flow enforces order
fn process(input: Input) -> Result<Output> {
    let validated = validate(input)?;
    let transformed = transform(validated);
    save(transformed)
}
```

## Rich Hickey Talks (Reference)

- **Simple Made Easy** (2011): Core simplicity concepts
- **The Value of Values** (2012): Immutability and facts
- **The Language of the System** (2012): System-level simplicity
- **Hammock Driven Development** (2010): Thinking before coding
