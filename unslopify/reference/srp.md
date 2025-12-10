# Single Responsibility Principle (SRP)

## Definition

> "A module should have one, and only one, reason to change."
> — Robert C. Martin

**Key insight**: "Reason to change" = "actor" or "stakeholder". A module should serve one stakeholder.

## What is a "Responsibility"?

A responsibility is a reason for change. Ask: "Who would request changes to this code?"

- **UI team** requests display changes
- **Business team** requests logic changes
- **DBA** requests persistence changes
- **Security team** requests auth changes

If multiple teams could request changes, the module has multiple responsibilities.

## SRP Violations

### 1. God Class

```typescript
// Bad: does everything
class UserManager {
  // Authentication (Security team)
  login(email: string, password: string): User { }
  logout(user: User): void { }

  // Profile (Product team)
  updateProfile(user: User, data: ProfileData): void { }
  getAvatar(user: User): string { }

  // Persistence (DBA)
  saveUser(user: User): void { }
  loadUser(id: string): User { }

  // Notifications (Marketing team)
  sendWelcomeEmail(user: User): void { }
  sendPasswordReset(user: User): void { }
}
```

### 2. Mixed Abstraction Levels

```go
// Bad: HTTP handling + business logic + persistence
func HandleCreateOrder(w http.ResponseWriter, r *http.Request) {
    // HTTP parsing
    var req OrderRequest
    json.NewDecoder(r.Body).Decode(&req)

    // Business logic
    order := Order{
        Items: req.Items,
        Total: calculateTotal(req.Items),
        Tax:   calculateTax(req.Items),
    }

    // Persistence
    db.Save(&order)

    // HTTP response
    json.NewEncoder(w).Encode(order)
}
```

### 3. Utility Dumping Ground

```rust
// Bad: unrelated utilities
mod utils {
    pub fn format_date(d: DateTime) -> String { }
    pub fn hash_password(p: &str) -> String { }
    pub fn send_email(to: &str, body: &str) { }
    pub fn calculate_shipping(weight: f64) -> f64 { }
}
```

## Refactoring to SRP

### Before: God Class

```typescript
class ReportGenerator {
  // Data fetching
  fetchSalesData(): SalesData { }
  fetchInventoryData(): InventoryData { }

  // Calculations
  calculateTotals(data: SalesData): Totals { }
  calculateTrends(data: SalesData): Trends { }

  // Formatting
  formatAsHTML(report: Report): string { }
  formatAsPDF(report: Report): Buffer { }
  formatAsCSV(report: Report): string { }

  // Delivery
  sendEmail(report: string, to: string): void { }
  saveToFile(report: string, path: string): void { }
}
```

### After: Separated Responsibilities

```typescript
// Data fetching
class SalesDataRepository {
  fetch(): SalesData { }
}

class InventoryDataRepository {
  fetch(): InventoryData { }
}

// Calculations (pure functions)
function calculateTotals(data: SalesData): Totals { }
function calculateTrends(data: SalesData): Trends { }

// Formatting
interface ReportFormatter {
  format(report: Report): string | Buffer;
}

class HTMLFormatter implements ReportFormatter { }
class PDFFormatter implements ReportFormatter { }
class CSVFormatter implements ReportFormatter { }

// Delivery
interface ReportDelivery {
  deliver(report: string | Buffer): void;
}

class EmailDelivery implements ReportDelivery { }
class FileDelivery implements ReportDelivery { }

// Orchestration
class ReportService {
  constructor(
    private salesRepo: SalesDataRepository,
    private formatter: ReportFormatter,
    private delivery: ReportDelivery
  ) {}

  generateAndDeliver(): void {
    const data = this.salesRepo.fetch();
    const totals = calculateTotals(data);
    const report = this.formatter.format({ data, totals });
    this.delivery.deliver(report);
  }
}
```

## SRP at Different Levels

### Function Level

```go
// Bad: multiple responsibilities
func ProcessOrder(order Order) error {
    // Validate
    if order.Total <= 0 { return errors.New("invalid total") }

    // Apply discount
    if order.HasCoupon { order.Total *= 0.9 }

    // Save
    return db.Save(order)
}

// Good: single responsibility per function
func ValidateOrder(order Order) error {
    if order.Total <= 0 { return errors.New("invalid total") }
    return nil
}

func ApplyDiscount(order Order) Order {
    if order.HasCoupon {
        return Order{...order, Total: order.Total * 0.9}
    }
    return order
}

func SaveOrder(order Order) error {
    return db.Save(order)
}
```

### Module Level

```rust
// Bad: one big module
mod orders {
    pub fn create_order() { }
    pub fn validate_order() { }
    pub fn calculate_shipping() { }
    pub fn process_payment() { }
    pub fn send_confirmation() { }
    pub fn generate_invoice() { }
}

// Good: separated modules
mod orders {
    mod creation { pub fn create() { } }
    mod validation { pub fn validate() { } }
    mod shipping { pub fn calculate() { } }
}

mod payments {
    pub fn process() { }
}

mod notifications {
    pub fn send_confirmation() { }
}

mod invoicing {
    pub fn generate() { }
}
```

## Signs of SRP Violations

1. **Class/module is hard to name** (ends up as "Manager", "Handler", "Utils")
2. **Many imports** from different domains
3. **Changes for different reasons** affect same file
4. **Large test files** with unrelated test cases
5. **God objects** that everything depends on

## SRP Checklist

When reviewing code:

1. **Name test**: Can you name it with a single noun? (Not "XManager" or "XHandler")
2. **Stakeholder test**: Who would request changes? Should be one answer.
3. **Change test**: What could change? All changes should be related.
4. **Import test**: Are imports from one domain or many?
5. **Description test**: Can you describe it without "and"?
