# Functional Core, Imperative Shell

## Concept

Separate your code into two layers:

1. **Functional Core**: Pure functions containing business logic. No I/O, no side effects.
2. **Imperative Shell**: Thin layer that handles I/O and orchestrates the core.

## Why?

- **Testability**: Core logic testable without mocks
- **Predictability**: Pure functions always return same output for same input
- **Composability**: Pure functions compose easily
- **Debuggability**: No hidden state changes

## The Pattern

```
┌─────────────────────────────────────┐
│         Imperative Shell            │
│  ┌─────────────────────────────┐    │
│  │      Functional Core        │    │
│  │   (pure business logic)     │    │
│  └─────────────────────────────┘    │
│           ↑         ↓               │
│     [Read I/O]  [Write I/O]         │
└─────────────────────────────────────┘
```

## Examples

### TypeScript Example

```typescript
// ❌ Mixed: I/O and logic intertwined
async function processOrder(orderId: string): Promise<void> {
  const order = await db.findOrder(orderId);  // I/O

  if (order.items.length === 0) {  // Logic
    throw new Error('Empty order');
  }

  const total = order.items.reduce(  // Logic
    (sum, item) => sum + item.price * item.qty,
    0
  );

  const tax = total * 0.1;  // Logic
  const finalTotal = total + tax;  // Logic

  await db.updateOrder(orderId, { total: finalTotal });  // I/O
  await emailService.sendConfirmation(order.email, finalTotal);  // I/O
}
```

```typescript
// ✅ Separated: Functional Core + Imperative Shell

// CORE: Pure functions
type Order = {
  items: Array<{ price: number; qty: number }>;
  email: string;
};

type OrderResult =
  | { status: 'success'; total: number; tax: number }
  | { status: 'error'; reason: string };

function calculateOrder(order: Order): OrderResult {
  if (order.items.length === 0) {
    return { status: 'error', reason: 'Empty order' };
  }

  const subtotal = order.items.reduce(
    (sum, item) => sum + item.price * item.qty,
    0
  );
  const tax = subtotal * 0.1;

  return { status: 'success', total: subtotal + tax, tax };
}

// SHELL: I/O orchestration
async function processOrder(orderId: string): Promise<void> {
  // Input I/O
  const order = await db.findOrder(orderId);

  // Pure computation
  const result = calculateOrder(order);

  // Output I/O
  if (result.status === 'error') {
    throw new Error(result.reason);
  }

  await db.updateOrder(orderId, { total: result.total });
  await emailService.sendConfirmation(order.email, result.total);
}
```

### Go Example

```go
// ❌ Mixed
func ProcessUser(db *sql.DB, userID string) error {
    row := db.QueryRow("SELECT * FROM users WHERE id = ?", userID)  // I/O
    var user User
    row.Scan(&user.ID, &user.Name, &user.Score)  // I/O

    // Logic mixed with I/O
    if user.Score > 100 {
        user.Level = "gold"
    } else if user.Score > 50 {
        user.Level = "silver"
    } else {
        user.Level = "bronze"
    }

    _, err := db.Exec(  // I/O
        "UPDATE users SET level = ? WHERE id = ?",
        user.Level, user.ID,
    )
    return err
}
```

```go
// ✅ Separated

// CORE: Pure function
type User struct {
    ID    string
    Name  string
    Score int
    Level string
}

func DetermineLevel(score int) string {
    switch {
    case score > 100:
        return "gold"
    case score > 50:
        return "silver"
    default:
        return "bronze"
    }
}

func UpdateUserLevel(user User) User {
    return User{
        ID:    user.ID,
        Name:  user.Name,
        Score: user.Score,
        Level: DetermineLevel(user.Score),
    }
}

// SHELL: I/O orchestration
func ProcessUser(db *sql.DB, userID string) error {
    // Input I/O
    user, err := fetchUser(db, userID)
    if err != nil {
        return err
    }

    // Pure computation
    updated := UpdateUserLevel(user)

    // Output I/O
    return saveUser(db, updated)
}
```

### Rust Example

```rust
// ❌ Mixed
async fn process_payment(pool: &PgPool, payment_id: &str) -> Result<(), Error> {
    let payment = sqlx::query_as!(Payment, "SELECT * FROM payments WHERE id = $1", payment_id)
        .fetch_one(pool)  // I/O
        .await?;

    // Logic mixed with I/O
    let fee = payment.amount * 0.029 + 0.30;
    let net = payment.amount - fee;

    if net < 0.0 {
        return Err(Error::InsufficientAmount);
    }

    sqlx::query!("UPDATE payments SET fee = $1, net = $2 WHERE id = $3", fee, net, payment_id)
        .execute(pool)  // I/O
        .await?;

    Ok(())
}
```

```rust
// ✅ Separated

// CORE: Pure functions
#[derive(Clone)]
struct Payment {
    id: String,
    amount: f64,
}

struct ProcessedPayment {
    id: String,
    amount: f64,
    fee: f64,
    net: f64,
}

enum ProcessResult {
    Success(ProcessedPayment),
    InsufficientAmount { amount: f64, min_required: f64 },
}

fn calculate_payment(payment: &Payment) -> ProcessResult {
    let fee = payment.amount * 0.029 + 0.30;
    let net = payment.amount - fee;

    if net < 0.0 {
        return ProcessResult::InsufficientAmount {
            amount: payment.amount,
            min_required: 0.31,  // Minimum to cover fee
        };
    }

    ProcessResult::Success(ProcessedPayment {
        id: payment.id.clone(),
        amount: payment.amount,
        fee,
        net,
    })
}

// SHELL: I/O orchestration
async fn process_payment(pool: &PgPool, payment_id: &str) -> Result<(), Error> {
    // Input I/O
    let payment = fetch_payment(pool, payment_id).await?;

    // Pure computation
    let result = calculate_payment(&payment);

    // Output I/O
    match result {
        ProcessResult::Success(processed) => {
            save_processed_payment(pool, &processed).await
        }
        ProcessResult::InsufficientAmount { amount, min_required } => {
            Err(Error::InsufficientAmount { amount, min_required })
        }
    }
}
```

## Testing Benefits

```typescript
// Core is trivially testable - no mocks needed!
describe('calculateOrder', () => {
  it('calculates total with tax', () => {
    const order = {
      items: [{ price: 10, qty: 2 }, { price: 5, qty: 1 }],
      email: 'test@example.com'
    };

    const result = calculateOrder(order);

    expect(result).toEqual({
      status: 'success',
      total: 27.5,  // (20 + 5) * 1.1
      tax: 2.5
    });
  });

  it('rejects empty orders', () => {
    const order = { items: [], email: 'test@example.com' };

    const result = calculateOrder(order);

    expect(result).toEqual({
      status: 'error',
      reason: 'Empty order'
    });
  });
});
```

## Checklist

1. **Identify I/O**: Database, network, filesystem, console, time, randomness
2. **Extract pure logic**: Move calculations to pure functions
3. **Return data, not effects**: Core returns new data, shell applies effects
4. **Push I/O to edges**: Shell does I/O, calls core, does more I/O
5. **Test the core**: Should be testable without any mocks

## Common Mistakes

### Mistake 1: Logger in Core

```typescript
// Bad: I/O in core
function calculate(data: Data): number {
  logger.info('Calculating...');  // I/O!
  return data.a + data.b;
}

// Good: Return what would be logged
function calculate(data: Data): { result: number; events: string[] } {
  return {
    result: data.a + data.b,
    events: ['calculation_performed']
  };
}
```

### Mistake 2: Time/Random in Core

```typescript
// Bad: non-deterministic
function createOrder(items: Item[]): Order {
  return {
    id: uuid(),  // Non-deterministic!
    createdAt: new Date(),  // Non-deterministic!
    items
  };
}

// Good: inject non-determinism
function createOrder(
  items: Item[],
  id: string,
  createdAt: Date
): Order {
  return { id, createdAt, items };
}
```

### Mistake 3: Throwing in Core

```typescript
// Bad: exceptions are side effects
function divide(a: number, b: number): number {
  if (b === 0) throw new Error('Division by zero');
  return a / b;
}

// Good: return result type
function divide(a: number, b: number): { ok: true; value: number } | { ok: false; error: string } {
  if (b === 0) return { ok: false, error: 'Division by zero' };
  return { ok: true, value: a / b };
}
```
