# Type Strictness Reference

## Philosophy

Strong types:
- **Prevent bugs** at compile time
- **Document intent** in code
- **Enable refactoring** with confidence
- **Express domain concepts** precisely

## TypeScript

### Avoid `any`

```typescript
// Bad: any defeats the type system
function process(data: any): any {
  return data.foo.bar;  // No safety
}

// Better: unknown requires narrowing
function process(data: unknown): string {
  if (typeof data === 'object' && data !== null && 'foo' in data) {
    // Now we can safely access
  }
  throw new Error('Invalid data');
}

// Best: proper typing
interface Data {
  foo: { bar: string };
}
function process(data: Data): string {
  return data.foo.bar;  // Type safe
}
```

### Use Discriminated Unions

```typescript
// Bad: loose object type
interface ApiResponse {
  success?: boolean;
  data?: User;
  error?: string;
}

// Good: discriminated union
type ApiResponse =
  | { status: 'success'; data: User }
  | { status: 'error'; error: string }
  | { status: 'loading' };

function handle(response: ApiResponse) {
  switch (response.status) {
    case 'success':
      console.log(response.data);  // data is available
      break;
    case 'error':
      console.log(response.error);  // error is available
      break;
  }
}
```

### Branded/Opaque Types

```typescript
// Bad: stringly typed
function getUser(id: string): User { }
function getOrder(id: string): Order { }

// Can accidentally swap IDs
getUser(orderId);  // No error!

// Good: branded types
type UserId = string & { readonly __brand: 'UserId' };
type OrderId = string & { readonly __brand: 'OrderId' };

function userId(id: string): UserId { return id as UserId; }
function orderId(id: string): OrderId { return id as OrderId; }

function getUser(id: UserId): User { }
function getOrder(id: OrderId): Order { }

getUser(orderId('123'));  // Type error!
```

### Strict Null Checks

```typescript
// Bad: implicit null handling
function findUser(id: string): User {
  // might return undefined, but type says User
}

// Good: explicit nullability
function findUser(id: string): User | undefined {
  // Return type is honest
}

// Usage requires handling
const user = findUser('123');
if (user) {
  console.log(user.name);  // Safe
}
```

### Const Assertions

```typescript
// Bad: mutable, wide types
const config = {
  env: 'production',  // type: string
  ports: [8080, 8081]  // type: number[]
};

// Good: immutable, narrow types
const config = {
  env: 'production',
  ports: [8080, 8081]
} as const;
// env: 'production' (literal)
// ports: readonly [8080, 8081] (tuple)
```

## Go

### Meaningful Type Aliases

```go
// Bad: primitive obsession
func Transfer(from string, to string, amount int64) error

// Good: domain types
type AccountID string
type Money int64

func Transfer(from AccountID, to AccountID, amount Money) error
```

### Interface Segregation

```go
// Bad: fat interface
type Repository interface {
    Create(entity Entity) error
    Read(id string) (Entity, error)
    Update(entity Entity) error
    Delete(id string) error
    List() ([]Entity, error)
    Search(query string) ([]Entity, error)
    Count() (int, error)
    // ... 20 more methods
}

// Good: small, focused interfaces
type Reader interface {
    Read(id string) (Entity, error)
}

type Writer interface {
    Create(entity Entity) error
    Update(entity Entity) error
}

type Deleter interface {
    Delete(id string) error
}

// Compose as needed
type ReadWriter interface {
    Reader
    Writer
}
```

### Avoid `interface{}`/`any`

```go
// Bad: type erasure
func Process(data interface{}) interface{} {
    // No compile-time safety
}

// Good: generics (Go 1.18+)
func Process[T any](data T) T {
    // Type preserved
}

// Good: specific interface
type Processable interface {
    Process() Result
}

func Process(data Processable) Result {
    return data.Process()
}
```

### Error Types with Context

```go
// Bad: string errors
if err != nil {
    return errors.New("failed to process")
}

// Good: typed errors with context
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

// Can check error type
var validErr *ValidationError
if errors.As(err, &validErr) {
    // Handle validation error specifically
}
```

## Rust

### Newtype Pattern

```rust
// Bad: primitive types
fn transfer(from: &str, to: &str, amount: u64) -> Result<(), Error>

// Good: newtype wrappers
struct AccountId(String);
struct Money(u64);

fn transfer(from: &AccountId, to: &AccountId, amount: Money) -> Result<(), Error>
```

### Result/Option Over Panics

```rust
// Bad: panics in library code
fn divide(a: i64, b: i64) -> i64 {
    a / b  // Panics on zero!
}

fn find_user(id: &str) -> User {
    users.get(id).unwrap()  // Panics if not found!
}

// Good: explicit error handling
fn divide(a: i64, b: i64) -> Option<i64> {
    if b == 0 { None } else { Some(a / b) }
}

fn find_user(id: &str) -> Option<&User> {
    users.get(id)
}

// Or with Result for errors
fn divide(a: i64, b: i64) -> Result<i64, DivisionError> {
    if b == 0 {
        Err(DivisionError::DivideByZero)
    } else {
        Ok(a / b)
    }
}
```

### Enums for State Machines

```rust
// Bad: boolean flags
struct Connection {
    is_connected: bool,
    is_authenticated: bool,
    is_ready: bool,
}

// Good: enum state machine
enum ConnectionState {
    Disconnected,
    Connected { socket: TcpStream },
    Authenticated { socket: TcpStream, user: User },
    Ready { socket: TcpStream, user: User, session: Session },
}

// Impossible to be authenticated but not connected!
```

### Avoid Excessive `unwrap()`

```rust
// Bad: unwrap everywhere
fn process(data: &str) -> Output {
    let parsed: Data = serde_json::from_str(data).unwrap();
    let result = compute(&parsed).unwrap();
    result.finalize().unwrap()
}

// Good: propagate errors
fn process(data: &str) -> Result<Output, ProcessError> {
    let parsed: Data = serde_json::from_str(data)?;
    let result = compute(&parsed)?;
    Ok(result.finalize()?)
}
```

## Type Strictness Checklist

1. **No escape hatches**: `any`, `interface{}`, excessive `unwrap()`
2. **Domain types**: Business concepts have their own types
3. **Explicit nullability**: Nullable values are in the type
4. **Discriminated unions**: Use sum types over loose objects
5. **Type narrowing**: Narrow unknown/union types before use
6. **Const correctness**: Immutable where possible
