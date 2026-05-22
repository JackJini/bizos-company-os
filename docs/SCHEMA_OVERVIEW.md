# SingapoDent Database Schema Overview

## Quick Facts

- **Total Tables:** 45+
- **Enums:** 8 types
- **Primary Modules:** 8
- **Demo Records:** 50+
- **Database:** PostgreSQL via Supabase

---

## Module Breakdown

### 1. Organization & Core (5 tables)
Manage company structure, departments, employees, and roles.

**Key Tables:**
- `companies` - Company master data
- `departments` - Organizational structure
- `positions` - Job positions and salary bands
- `employees` - Employee records
- `user_roles` - RBAC mapping

**Key Relationships:**
- 1 Company → Many Departments → Many Employees
- Employees report to managers (self-referential)
- Roles tied to auth users for login

---

### 2. Products & Inventory (5 tables)
Manage product catalog, stock levels, and suppliers.

**Key Tables:**
- `product_categories` - Category hierarchy
- `products` - Product master (5 types supported)
- `inventory_stock` - Real-time stock levels with auto-calculate available qty
- `inventory_movements` - Complete audit trail
- `suppliers` - Vendor information

**Key Features:**
- Tracks both unit price (selling) and cost price (profit margin)
- Real-time available quantity = on_hand - reserved
- Automatic reorder alerts when stock hits reorder_level
- Complete movement history for audit

**Demo Products:**
- Dental High Speed Drill X-3000
- LS 3D Dental Printer Pro
- Dental Resin Clear - 1kg
- Dental Suction Unit
- Surgical LED Light Kit

---

### 3. Sales & Customers (4 tables)
Manage customers, orders, invoicing, and payments.

**Key Tables:**
- `customers` - Customer/client records (B2B, B2C, Distributors)
- `sales_orders` - Customer orders with line items
- `sales_order_items` - Order details with auto-calculated line totals
- `invoices` - Invoicing with payment tracking
- `invoice_payments` - Payment records per invoice

**Key Features:**
- Orders link to invoices (1 order → 1+ invoices possible)
- Track discount at line and order level
- Payment status tracking (pending, partial, paid, overdue)
- Multi-payment support per invoice
- Customer lifetime value calculation

**Business Flow:**
1. Create Sales Order (draft)
2. Confirm Order (confirmed)
3. Process & Ship (processing → shipped → delivered)
4. Create Invoice
5. Record Payments (partial or full)

---

### 4. Courses & Training (5 tables)
Manage training courses, enrollment, and student progress.

**Key Tables:**
- `courses` - Course master (3 demo courses)
- `course_sessions` - Multiple cohorts per course
- `course_enrollments` - Student enrollment tracking
- `course_materials` - Course content (videos, documents, quizzes)
- `student_progress` - Individual completion tracking

**Key Features:**
- Support multiple sessions per course (cohorts)
- Track enrollment status: registered → in_progress → completed/dropped
- Material types: video, document, quiz, assignment
- Student progress tracking per material
- Certificate tracking with URL
- Completion rate calculation

**Demo Courses:**
1. **3D Printing in Dentistry 101** (16 hours, $5M VND)
2. **Dental Equipment Management** (12 hours, $3M VND)
3. **Dental Equipment Sales Mastery** (20 hours, $4M VND)

---

### 5. HR & Compensation (5 tables)
Manage employment contracts, salary, and payroll.

**Key Tables:**
- `employment_contracts` - Contract details per employee
- `salary_components` - Allowances, bonuses, deductions by employee
- `commission_rules` - Sales commission calculation rules
- `payroll_periods` - Monthly payroll batches
- `payroll_entries` - Calculated payroll with detailed breakdown

**Salary Calculation:**
```
Gross Pay = Base Salary + Allowances + Commission + Bonus - Penalty - Deductions
Net Pay = Gross Pay - Taxes (if applicable)
```

**Demo Employees:** 7 across 6 departments with salary ranges from 17-80M VND/month

---

### 6. KPI & Performance (3 tables)
Track key performance indicators with targets and actuals.

**Key Tables:**
- `kpis` - KPI definitions (company-wide or department-specific)
- `kpi_targets` - Target values by period
- `kpi_actuals` - Achieved values with completion rates

**Features:**
- Multiple frequencies: daily, weekly, monthly, quarterly, yearly
- Parent-child KPI hierarchies (cascade tracking)
- Unit flexibility: %, currency, count, ratio, etc.
- Status tracking: on_track, at_risk, exceeded, missed
- Owner can be employee or department

**Demo KPIs:**
1. **Monthly Revenue** (Sales owner, VND unit)
2. **Sales Order Count** (Sales owner, Orders unit)
3. **Inventory Turnover** (Warehouse owner, Ratio unit)
4. **Course Enrollments** (Training owner, Students unit)

---

### 7. Finance & Accounting (5 tables)
Chart of accounts, budgeting, and financial reporting.

**Key Tables:**
- `chart_of_accounts` - Hierarchical account structure
- `cost_centers` - Cost allocation centers
- `accounting_entries` - Journal entries (debit/credit pairs)
- `budgets` & `budget_lines` - Budget planning and tracking
- `cashflow_records` - Cash movement tracking
- `financial_snapshots` - P&L, Balance Sheet, Cash Flow snapshots

**Features:**
- Hierarchical chart of accounts
- Double-entry accounting (debit/credit)
- Cost center allocation
- Budget vs actual comparison
- Cashflow categorization (Sales, Payroll, Supplies, etc.)
- Period-based financial snapshots

---

### 8. App Settings & Audit (2 tables)
Configuration and compliance tracking.

**Key Tables:**
- `app_settings` - Company-wide settings (JSON-based)
- `audit_logs` - Complete audit trail of all changes

**Features:**
- Flexible JSONB settings
- Who did what, when, and what changed
- Supports compliance and data governance

---

## Data Model Diagram (Simplified)

```
┌─────────────────────────────────────────────────────────────┐
│                         COMPANY                              │
└────────────┬────────────────────────────────────────────┬───┘
             │                                            │
    ┌────────▼──────────┐                  ┌─────────────▼──────────┐
    │   DEPARTMENTS     │                  │    APP SETTINGS        │
    │   POSITIONS       │                  │    AUDIT LOGS          │
    │   EMPLOYEES       │                  └────────────────────────┘
    │   USER ROLES      │
    └────────┬──────────┘
             │
   ┌─────────┴──────────┐
   │                    │
   ▼                    ▼
PAYROLL         KPIs & PERFORMANCE
CONTRACTS       (Targets/Actuals)
SALARY COMP
COMMISSION


┌──────────────────────────────────────────────────────────────┐
│              PRODUCTS & INVENTORY MANAGEMENT                  │
├──────────────────────────────────────────────────────────────┤
│  Categories → Products ← Inventory Stock ← Movements         │
│                          ↓                                    │
│                      Suppliers                                │
└──────────────────────────────────────────────────────────────┘


┌──────────────────────────────────────────────────────────────┐
│                    SALES PIPELINE                             │
├──────────────────────────────────────────────────────────────┤
│  Customers → Orders → Order Items → Invoices → Payments     │
│                          ↓              ↓                     │
│                      Products      Accounting                 │
└──────────────────────────────────────────────────────────────┘


┌──────────────────────────────────────────────────────────────┐
│                   TRAINING PLATFORM                           │
├──────────────────────────────────────────────────────────────┤
│  Courses → Sessions → Enrollments ← Student Progress        │
│     ↓                                                         │
│  Materials (Videos, Docs, Quizzes, Assignments)             │
└──────────────────────────────────────────────────────────────┘


┌──────────────────────────────────────────────────────────────┐
│              FINANCIAL MANAGEMENT                             │
├──────────────────────────────────────────────────────────────┤
│  Chart of Accounts → Accounting Entries → Financial Snapshots│
│       ↓                 ↓                                     │
│  Cost Centers     Budgets & Cashflow                         │
└──────────────────────────────────────────────────────────────┘
```

---

## Key Design Decisions

### 1. JSONB for Flexibility
- `companies.settings` - Brand, fiscal year, locale preferences
- `products.specifications` - Variable product specs
- `commission_rules.definition` - Complex commission formulas
- `course_materials.curriculum` - Course structure
- `payroll_entries.breakdown` - Detailed salary breakdown

### 2. Generated Columns
- `inventory_stock.quantity_available` = quantity_on_hand - quantity_reserved
- `sales_order_items.line_total` = qty × price × (1 - discount%)
- Auto-calculated, always consistent

### 3. Unique Constraints
- Each product has unique SKU
- Each order number is unique
- Each invoice number is unique
- Each course code is unique
- Only 1 account per (user, company, role, scope) combination

### 4. Foreign Keys
- All foreign keys set to `on delete cascade` for parent-child relationships
- Some exceptions like `customers → sales_orders` use `on delete restrict` to prevent accidental deletion of customers with orders

### 5. Temporal Data
- All tables have `created_at` and most have `updated_at`
- Complete audit trail via `audit_logs`
- Payroll records by period for historical tracking
- Inventory movements for transaction history

---

## Typical Workflows

### Sales Workflow
```
1. Create Customer record
2. Create Sales Order (draft)
   - Add Order Items (products, quantities, pricing)
3. Confirm Order → Processing
4. Reserve Inventory
5. Ship Products → Delivered
6. Create Invoice
7. Receive Payments
8. Post to Accounting Entries
```

### Inventory Workflow
```
1. Add products to catalog with cost price
2. Create Inventory Stock records
3. Receive purchase → Inventory Movement (inflow)
4. Reserve for orders → quantity_reserved increases
5. Ship order → Inventory Movement (outflow)
6. Track reorder alerts when qty < reorder_level
7. Audit history via Inventory Movements log
```

### Payroll Workflow
```
1. Create Payroll Period (e.g., "2025-01")
2. Calculate entries from:
   - Base salary (Employment Contracts)
   - Allowances (Salary Components)
   - Commission (Commission Rules × Sales)
   - Bonus rules applied
3. Create Payroll Entries with full breakdown
4. Post to Accounting (Payroll Expense accounts)
5. Process payment
```

### Training Workflow
```
1. Create Course (draft)
   - Set instructor, price, duration
2. Publish Course
3. Create Course Sessions (cohorts)
4. Add Course Materials
5. Enroll Students
6. Track Progress via Student Progress records
7. Mark as Completed + issue Certificate
8. Archive Course
```

---

## Security & Multi-Tenancy

- All tables include `company_id` FK
- User roles scoped to (company_id, optional department_id)
- Ready for Row-Level Security (RLS) policies
- Audit logs track all changes
- Auth users linked to employees via `auth_user_id`

---

## Performance Considerations

### Indexes
Key columns are indexed for fast queries:
- `products.category_id`
- `products.code`
- `customers.code`
- `sales_orders.customer_id`, `order_date`, `status`
- `invoices.customer_id`, `invoice_date`
- `course_enrollments.course_id`, `student_email`
- `inventory_movements.product_id`, `created_at`
- `accounting_entries.entry_date`
- `audit_logs.created_at`

### Scalability
- Supports unlimited:
  - Products and inventory
  - Customers and orders
  - Students and enrollments
  - Employees and payroll history
- Monthly data partitioning recommended for large accounting tables

---

## Next Steps

1. **Run Setup:** Execute `singapodent_schema.sql` then `singapodent_seed.sql`
2. **Add Auth:** Create Supabase auth users and link to employees
3. **Set RLS Policies:** Restrict data by department/role
4. **Build APIs:** Create endpoints for CRUD operations
5. **Design UI:** Build dashboards for each module
6. **Automations:** Set up scheduled jobs (payroll, invoicing, KPI calc)

See [DATABASE_SETUP.md](./DATABASE_SETUP.md) for detailed instructions.
