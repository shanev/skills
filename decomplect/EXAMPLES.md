# Decomplect Skill Examples

## Quick Start

Ask Claude to analyze your code changes:

```
"Review my staged changes for decomplection"
"Would Rich Hickey approve of this code?"
"Check my PR for simplicity issues"
```

## Example Analysis: TypeScript Service

### Input (git diff)

```typescript
// user-service.ts (changed)
+ export class UserService {
+   private db: Database;
+   private cache: Cache;
+   private logger: Logger;
+
+   constructor() {
+     this.db = new PostgresDB();
+     this.cache = new RedisCache();
+     this.logger = new ConsoleLogger();
+   }
+
+   async getUser(id: string): Promise<any> {
+     this.logger.info(`Getting user ${id}`);
+
+     const cached = await this.cache.get(id);
+     if (cached) return cached;
+
+     const user = await this.db.query(`SELECT * FROM users WHERE id = '${id}'`);
+
+     if (user) {
+       user.fullName = user.firstName + ' ' + user.lastName;
+       user.isAdmin = user.role === 'admin';
+       await this.cache.set(id, user);
+     }
+
+     return user;
+   }
+ }
```

### Output

```markdown
# Decomplection Analysis

## Overall Grade: D

## Summary
The UserService complects multiple concerns (caching, logging, persistence, business logic) and uses weak types. Significant refactoring recommended.

## Pillar Scores

| Pillar | Grade | Key Finding |
|--------|-------|-------------|
| Simplicity | D | State + I/O + logic complected |
| Cohesion/Coupling | D | Hard-coded dependencies |
| Single Responsibility | D | Caching, logging, persistence, logic in one class |
| Type Strictness | F | Returns `any`, SQL injection risk |
| Functional Core | F | No separation of pure logic |

## Findings & Refactoring Suggestions

### 1. Simplicity: D

**Issue:** `user-service.ts:18-19` - Business logic complected with I/O
```typescript
user.fullName = user.firstName + ' ' + user.lastName;
user.isAdmin = user.role === 'admin';
```

**Suggested refactor:**
```typescript
// Pure function - no I/O, no mutation
type User = {
  readonly firstName: string;
  readonly lastName: string;
  readonly role: string;
};

type EnrichedUser = User & {
  readonly fullName: string;
  readonly isAdmin: boolean;
};

function enrichUser(user: User): EnrichedUser {
  return {
    ...user,
    fullName: `${user.firstName} ${user.lastName}`,
    isAdmin: user.role === 'admin'
  };
}
```

**Why:** Separates pure transformation from I/O, making it testable without mocks.

---

### 2. Cohesion/Coupling: D

**Issue:** `user-service.ts:6-9` - Hard-coded concrete dependencies
```typescript
constructor() {
  this.db = new PostgresDB();
  this.cache = new RedisCache();
  this.logger = new ConsoleLogger();
}
```

**Suggested refactor:**
```typescript
interface UserRepository {
  findById(id: string): Promise<User | null>;
}

interface Cache<T> {
  get(key: string): Promise<T | null>;
  set(key: string, value: T): Promise<void>;
}

class UserService {
  constructor(
    private readonly repo: UserRepository,
    private readonly cache: Cache<User>
  ) {}
}
```

**Why:** Dependency injection enables testing, swapping implementations, and follows the Dependency Inversion Principle.

---

### 3. Single Responsibility: D

**Issue:** `user-service.ts:1-24` - Class has multiple responsibilities
- Caching logic
- Logging
- Database querying
- User enrichment

**Suggested refactor:**
```typescript
// Separate concerns
class UserRepository {
  async findById(id: string): Promise<User | null> { }
}

class CachedUserRepository implements UserRepository {
  constructor(
    private readonly inner: UserRepository,
    private readonly cache: Cache<User>
  ) {}

  async findById(id: string): Promise<User | null> {
    const cached = await this.cache.get(id);
    if (cached) return cached;

    const user = await this.inner.findById(id);
    if (user) await this.cache.set(id, user);
    return user;
  }
}

// Pure function for enrichment
function enrichUser(user: User): EnrichedUser { }
```

**Why:** Each class has one reason to change. Caching is now a decorator.

---

### 4. Type Strictness: F

**Issue:** `user-service.ts:11` - Returns `any`, loses type safety
```typescript
async getUser(id: string): Promise<any>
```

**Issue:** `user-service.ts:16` - SQL injection vulnerability
```typescript
const user = await this.db.query(`SELECT * FROM users WHERE id = '${id}'`);
```

**Suggested refactor:**
```typescript
type UserId = string & { readonly __brand: 'UserId' };

interface User {
  readonly id: UserId;
  readonly firstName: string;
  readonly lastName: string;
  readonly role: 'admin' | 'user' | 'guest';
}

async findById(id: UserId): Promise<User | null> {
  return this.db.query<User>(
    'SELECT * FROM users WHERE id = $1',
    [id]
  );
}
```

**Why:** Branded types prevent ID mixups. Parameterized queries prevent SQL injection. Explicit return type enables type checking.

---

### 5. Functional Core: F

**Issue:** No separation between pure logic and I/O

**Suggested refactor:**
```typescript
// CORE: Pure functions
function enrichUser(user: User): EnrichedUser {
  return {
    ...user,
    fullName: `${user.firstName} ${user.lastName}`,
    isAdmin: user.role === 'admin'
  };
}

// SHELL: I/O orchestration
async function getEnrichedUser(
  repo: UserRepository,
  id: UserId
): Promise<EnrichedUser | null> {
  const user = await repo.findById(id);  // I/O
  return user ? enrichUser(user) : null;  // Pure
}
```

**Why:** Pure `enrichUser` is testable without mocks. Shell handles I/O at edges.

## Priority Recommendations

1. **Fix type safety (F → B)**: Add proper types, fix SQL injection. Highest risk.
2. **Extract pure functions (F → B)**: Move business logic to pure functions. Enables testing.
3. **Dependency injection (D → B)**: Accept dependencies in constructor. Enables testing and flexibility.
```

---

## Example Analysis: Go Handler

### Input (git diff)

```go
// handlers/order.go (changed)
+ func HandleCreateOrder(w http.ResponseWriter, r *http.Request) {
+     var req struct {
+         UserID   string  `json:"user_id"`
+         Items    []Item  `json:"items"`
+         Discount float64 `json:"discount"`
+     }
+     json.NewDecoder(r.Body).Decode(&req)
+
+     // Validate
+     if len(req.Items) == 0 {
+         http.Error(w, "no items", 400)
+         return
+     }
+
+     // Calculate
+     var total float64
+     for _, item := range req.Items {
+         total += item.Price * float64(item.Qty)
+     }
+     total = total * (1 - req.Discount)
+
+     // Save
+     order := Order{ID: uuid.New(), UserID: req.UserID, Total: total}
+     db.Create(&order)
+
+     json.NewEncoder(w).Encode(order)
+ }
```

### Output

```markdown
# Decomplection Analysis

## Overall Grade: C

## Summary
Handler mixes HTTP concerns with business logic. Extracting pure calculation functions would improve testability.

## Pillar Scores

| Pillar | Grade | Key Finding |
|--------|-------|-------------|
| Simplicity | C | Logic mixed with HTTP handling |
| Cohesion/Coupling | C | Global `db` dependency |
| Single Responsibility | D | HTTP + validation + calculation + persistence |
| Type Strictness | B | Good use of structs, could add domain types |
| Functional Core | D | No pure functions, all mixed |

## Findings & Refactoring Suggestions

### 1. Simplicity: C

**Issue:** `handlers/order.go:14-19` - Calculation complected with HTTP handling

**Suggested refactor:**
```go
// Pure calculation function
func CalculateOrderTotal(items []Item, discount float64) float64 {
    var subtotal float64
    for _, item := range items {
        subtotal += item.Price * float64(item.Qty)
    }
    return subtotal * (1 - discount)
}
```

### 5. Functional Core: D

**Suggested refactor:**
```go
// CORE: Pure types and functions
type OrderRequest struct {
    UserID   string
    Items    []Item
    Discount float64
}

type OrderResult struct {
    Order Order
    Err   error
}

func ValidateOrderRequest(req OrderRequest) error {
    if len(req.Items) == 0 {
        return errors.New("no items")
    }
    return nil
}

func CreateOrderFromRequest(req OrderRequest, id uuid.UUID) Order {
    return Order{
        ID:     id,
        UserID: req.UserID,
        Total:  CalculateOrderTotal(req.Items, req.Discount),
    }
}

// SHELL: HTTP handler
func HandleCreateOrder(
    repo OrderRepository,
) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        // Parse (I/O)
        var req OrderRequest
        json.NewDecoder(r.Body).Decode(&req)

        // Validate (pure)
        if err := ValidateOrderRequest(req); err != nil {
            http.Error(w, err.Error(), 400)
            return
        }

        // Create (pure)
        order := CreateOrderFromRequest(req, uuid.New())

        // Save (I/O)
        repo.Save(order)

        // Respond (I/O)
        json.NewEncoder(w).Encode(order)
    }
}
```

## Priority Recommendations

1. **Extract pure functions**: `ValidateOrderRequest`, `CalculateOrderTotal`, `CreateOrderFromRequest`
2. **Inject repository**: Replace global `db` with injected `OrderRepository`
3. **Add domain types**: `type Money float64`, `type UserID string`
```

---

## Example Analysis: Rust Module

### Input (git diff)

```rust
// src/payment.rs (changed)
+ pub async fn process_payment(
+     pool: &PgPool,
+     payment_id: &str,
+ ) -> Result<(), Box<dyn std::error::Error>> {
+     let payment = sqlx::query_as!(
+         Payment,
+         "SELECT * FROM payments WHERE id = $1",
+         payment_id
+     )
+     .fetch_one(pool)
+     .await?;
+
+     let fee = payment.amount * 0.029 + 0.30;
+     let net = payment.amount - fee;
+
+     if net < 0.0 {
+         return Err("Insufficient amount".into());
+     }
+
+     sqlx::query!(
+         "UPDATE payments SET fee = $1, net = $2 WHERE id = $3",
+         fee, net, payment_id
+     )
+     .execute(pool)
+     .await?;
+
+     Ok(())
+ }
```

### Output

```markdown
# Decomplection Analysis

## Overall Grade: C+

## Summary
Solid Rust idioms but business logic mixed with I/O. Extracting pure fee calculation would improve testability.

## Pillar Scores

| Pillar | Grade | Key Finding |
|--------|-------|-------------|
| Simplicity | C | Logic mixed with database calls |
| Cohesion/Coupling | B | Single function, clear purpose |
| Single Responsibility | B | Does one thing, but mixes layers |
| Type Strictness | C | Uses `Box<dyn Error>`, raw floats |
| Functional Core | D | No separation |

## Findings & Refactoring Suggestions

### 4. Type Strictness: C

**Issue:** `src/payment.rs:1-4` - Stringly typed ID, generic error
```rust
payment_id: &str
Result<(), Box<dyn std::error::Error>>
```

**Suggested refactor:**
```rust
#[derive(Debug, Clone)]
pub struct PaymentId(String);

#[derive(Debug, Clone, Copy)]
pub struct Money(f64);

#[derive(Debug, thiserror::Error)]
pub enum PaymentError {
    #[error("Payment not found: {0}")]
    NotFound(PaymentId),
    #[error("Insufficient amount: {amount}, minimum: {minimum}")]
    InsufficientAmount { amount: Money, minimum: Money },
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),
}
```

### 5. Functional Core: D

**Suggested refactor:**
```rust
// CORE: Pure types and functions
#[derive(Debug)]
pub struct FeeCalculation {
    pub fee: Money,
    pub net: Money,
}

pub fn calculate_fee(amount: Money) -> Result<FeeCalculation, PaymentError> {
    let fee = Money(amount.0 * 0.029 + 0.30);
    let net = Money(amount.0 - fee.0);

    if net.0 < 0.0 {
        return Err(PaymentError::InsufficientAmount {
            amount,
            minimum: Money(0.31),
        });
    }

    Ok(FeeCalculation { fee, net })
}

// SHELL: I/O orchestration
pub async fn process_payment(
    pool: &PgPool,
    payment_id: PaymentId,
) -> Result<(), PaymentError> {
    // Fetch (I/O)
    let payment = fetch_payment(pool, &payment_id).await?;

    // Calculate (pure)
    let calc = calculate_fee(payment.amount)?;

    // Update (I/O)
    update_payment_fees(pool, &payment_id, calc).await?;

    Ok(())
}
```

## Priority Recommendations

1. **Add domain types**: `PaymentId`, `Money` newtypes
2. **Extract pure calculation**: `calculate_fee` function
3. **Typed errors**: Replace `Box<dyn Error>` with `PaymentError` enum
```
