# High-Cohesion, Low-Coupling

## Definitions

**Cohesion**: How closely related the elements within a module are. High cohesion means the module does one thing well.

**Coupling**: How dependent modules are on each other. Low coupling means modules can change independently.

## The Goal

- **Maximize cohesion**: Group related functionality
- **Minimize coupling**: Reduce dependencies between groups

## Types of Coupling (Worst to Best)

### 1. Content Coupling (Worst)
One module modifies the internals of another.

```typescript
// Bad: directly accessing internal state
class UserService {
  users: User[] = [];
}

class OrderService {
  createOrder(userService: UserService, userId: string) {
    // Directly accessing UserService internals
    const user = userService.users.find(u => u.id === userId);
  }
}
```

### 2. Common Coupling
Modules share global data.

```go
// Bad: shared global state
var AppConfig Config

func ServiceA() { /* uses AppConfig */ }
func ServiceB() { /* uses AppConfig */ }
```

### 3. Control Coupling
One module controls the flow of another via flags.

```rust
// Bad: flag determines behavior
fn process(data: Data, mode: ProcessMode) {
    match mode {
        ProcessMode::Fast => fast_process(data),
        ProcessMode::Slow => slow_process(data),
    }
}

// Better: separate functions
fn fast_process(data: Data) { }
fn slow_process(data: Data) { }
```

### 4. Stamp Coupling
Modules share composite data but only use parts.

```typescript
// Bad: passing whole User when only name needed
function greet(user: User) {
  return `Hello, ${user.name}`;
}

// Better: pass only what's needed
function greet(name: string) {
  return `Hello, ${name}`;
}
```

### 5. Data Coupling (Best)
Modules share only necessary primitive data.

```go
// Good: minimal data sharing
func CalculateDiscount(price float64, percentage float64) float64 {
    return price * (percentage / 100)
}
```

## Types of Cohesion (Worst to Best)

### 1. Coincidental Cohesion (Worst)
Unrelated functionality grouped together.

```typescript
// Bad: unrelated utilities
class Utils {
  formatDate(d: Date): string { }
  calculateTax(amount: number): number { }
  sendEmail(to: string): void { }
}
```

### 2. Logical Cohesion
Grouped by category, not by function.

```go
// Bad: grouped by "type" not by function
type Handlers struct {}
func (h *Handlers) HandleUserRequest() {}
func (h *Handlers) HandleOrderRequest() {}
func (h *Handlers) HandlePaymentRequest() {}
```

### 3. Temporal Cohesion
Grouped by when they execute.

```rust
// Bad: grouped by "initialization time"
fn init() {
    init_logging();
    init_database();
    init_cache();
    init_metrics();
}
```

### 4. Functional Cohesion (Best)
Every element contributes to a single well-defined task.

```typescript
// Good: single responsibility
class PasswordHasher {
  hash(password: string): string { }
  verify(password: string, hash: string): boolean { }
  needsRehash(hash: string): boolean { }
}
```

## Dependency Direction

Dependencies should point toward stability and abstraction.

```
Unstable (changes often)  →  Stable (rarely changes)
Concrete (implementation) →  Abstract (interfaces)
```

### Example: Dependency Inversion

```go
// Bad: high-level depends on low-level
type OrderService struct {
    db *PostgresDB  // concrete dependency
}

// Good: depend on abstraction
type OrderRepository interface {
    Save(order Order) error
    Find(id string) (Order, error)
}

type OrderService struct {
    repo OrderRepository  // abstract dependency
}
```

## Module Boundary Patterns

### Pattern: Facade

```typescript
// Hide internal complexity
class PaymentFacade {
  constructor(
    private validator: PaymentValidator,
    private processor: PaymentProcessor,
    private notifier: PaymentNotifier
  ) {}

  async processPayment(payment: Payment): Promise<Receipt> {
    await this.validator.validate(payment);
    const result = await this.processor.process(payment);
    await this.notifier.notify(result);
    return result.receipt;
  }
}
```

### Pattern: Anti-Corruption Layer

```go
// Translate between bounded contexts
type LegacyUserAdapter struct {
    legacy *LegacyUserSystem
}

func (a *LegacyUserAdapter) GetUser(id string) (User, error) {
    legacyUser := a.legacy.FetchUser(id)
    return translateToModernUser(legacyUser), nil
}
```

## Coupling Checklist

When reviewing code, check:

1. **Import graph**: Can you draw a clean dependency diagram?
2. **Change impact**: If module A changes, how many others are affected?
3. **Test isolation**: Can you test a module without its dependencies?
4. **Interface size**: Are interfaces minimal (ISP)?
5. **Circular dependencies**: Any A → B → A cycles?

## Decoupling Strategies

1. **Dependency injection**: Pass dependencies, don't create them
2. **Events/Messages**: Communicate via events, not direct calls
3. **Interfaces**: Depend on contracts, not implementations
4. **Data transfer objects**: Copy data at boundaries
5. **Configuration**: Externalize environment-specific values
