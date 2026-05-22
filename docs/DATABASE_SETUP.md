# SingapoDent Database Setup Guide

## Overview

SingapoDent is a comprehensive business management system for a dental equipment and 3D printer sales company with integrated training platform. The database schema is built on PostgreSQL/Supabase and includes modules for:

- **Product Management & Inventory** - Manage dental equipment, 3D printers, materials, and accessories
- **Sales & CRM** - Customer management, orders, invoicing, and payments
- **Training Platform** - Course management, student enrollment, progress tracking
- **HR & Compensation** - Employee management, payroll, commissions
- **Finance & Accounting** - Chart of accounts, budgeting, cashflow, financial reporting
- **KPI & Performance** - Key performance indicators with targets and actuals

---

## Database Schema Files

### Core Schema
**File:** `db/singapodent_schema.sql`

Contains all table definitions organized by module:

1. **Organization & Core** - Companies, departments, positions, employees
2. **Products & Inventory** - Product categories, products, stock levels, movements
3. **Sales & Customers** - Customers, orders, invoices, payments
4. **Courses & Training** - Courses, sessions, enrollments, materials, progress
5. **HR & Compensation** - Contracts, salary components, commissions, payroll
6. **KPI & Performance** - KPIs, targets, actuals tracking
7. **Finance & Accounting** - Chart of accounts, budgets, cashflow, financial snapshots
8. **App Settings & Audit** - Configuration and audit logging

### Demo Data
**File:** `db/singapodent_seed.sql`

Includes sample data:
- 1 Company (SingapoDent)
- 6 Departments (Sales, Marketing, Warehouse, Finance, HR, Training)
- 7 Employees across departments
- 5 Products (drills, 3D printer, resins, suction unit, LED light)
- Inventory records for all products
- 3 Customer accounts
- 3 Training courses with sessions
- 4 KPIs tracking sales, inventory, and training

---

## Setup Instructions

### Step 1: Create Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Click "New Project"
3. Fill in project name and password
4. Wait for database initialization (2-3 minutes)

### Step 2: Run Schema SQL

1. In Supabase dashboard, go to **SQL Editor**
2. Click **New Query**
3. Copy and paste the entire content of `db/singapodent_schema.sql`
4. Click **Run**
5. Wait for all tables to be created (should see green checkmark)

**Expected tables created:** ~45 tables across all modules

### Step 3: Load Demo Data

1. In SQL Editor, click **New Query**
2. Copy and paste the entire content of `db/singapodent_seed.sql`
3. Click **Run**
4. Verify data loaded successfully

**Expected records:**
- 1 Company
- 6 Departments
- 7 Employees
- 5 Products
- 3 Customers
- 3 Courses

### Step 4: Create Auth Users (Optional)

To enable login for demo users, create auth users in Supabase:

1. Go to **Authentication → Users**
2. Click **Add User** and create these accounts:
   ```
   Email: ceo@singapodent.demo
   Password: (any secure password)
   
   Email: sales.manager@singapodent.demo
   Password: (any secure password)
   
   Email: instructor1@singapodent.demo
   Password: (any secure password)
   
   Email: finance@singapodent.demo
   Password: (any secure password)
   ```

3. After creating users, get their `auth.users.id` values

4. Update employee records with auth IDs:
   ```sql
   update employees 
   set auth_user_id = '<auth-user-id>' 
   where email = 'ceo@singapodent.demo';
   ```

5. Assign user roles:
   ```sql
   insert into user_roles (auth_user_id, company_id, role)
   values 
     ('<ceo-auth-id>', '00000000-0000-0000-0000-00000000c001', 'admin'),
     ('<sales-manager-auth-id>', '00000000-0000-0000-0000-00000000c001', 'sales_manager'),
     ('<instructor-auth-id>', '00000000-0000-0000-0000-00000000c001', 'instructor'),
     ('<finance-auth-id>', '00000000-0000-0000-0000-00000000c001', 'finance');
   ```

### Step 5: Set Environment Variables

Copy your Supabase connection details to `.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
POSTGRES_URL=postgresql://postgres:password@db.your-project.supabase.co:5432/postgres
```

---

## Key Tables & Relationships

### Sales Pipeline
```
Customers → Sales Orders → Sales Order Items → Products
           ↓
        Invoices → Invoice Payments
```

### Product Management
```
Product Categories → Products ← Inventory Stock
                     ↓
              Inventory Movements (tracking changes)
```

### Training System
```
Courses → Course Sessions → Course Enrollments ← Students
        → Course Materials → Student Progress
```

### Financial Flow
```
Invoices & Payments → Accounting Entries → Chart of Accounts
                     ↓
                  Budgets → Budget Lines
                     ↓
              Cashflow Records → Financial Snapshots
```

### HR & Compensation
```
Employees → Employment Contracts → Salary Components
         → Payroll Entries (calculated from above)
         → Commission Rules (for sales staff)
```

---

## Important Enums

### User Roles
- `admin` - Full system access
- `sales_manager` - Manage sales orders and customers
- `sales_staff` - Create and view sales orders
- `course_manager` - Manage courses
- `instructor` - Teach courses, track student progress
- `warehouse` - Manage inventory
- `finance` - Financial management
- `hr` - HR operations
- `viewer` - Read-only access

### Order Status
- `draft` - Initial state
- `confirmed` - Approved for processing
- `processing` - Being prepared
- `shipped` - Sent to customer
- `delivered` - Received by customer
- `cancelled` - Cancelled order

### Payment Status
- `pending` - No payment received
- `partial` - Partial payment received
- `paid` - Fully paid
- `overdue` - Past due date
- `cancelled` - Payment cancelled

### Enrollment Status
- `registered` - Enrolled in course
- `in_progress` - Currently taking course
- `completed` - Finished course
- `dropped` - Withdrew from course
- `certified` - Completed and certified

---

## Data Model Highlights

### Products
- Supports 5 product types: dental equipment, 3D printers, materials, accessories, other
- Tracks cost price for margin calculations
- Specifications stored as JSON for flexibility

### Inventory
- Real-time stock tracking with reserved quantity
- Automatic calculation of available quantity
- Reorder level alerts built-in
- Complete movement history

### Sales Orders
- Customer information linked
- Line items with discounts
- Tax and shipping cost tracking
- Multiple payment/invoice support

### Courses
- Multiple sessions per course
- Material library per course
- Student progress tracking
- Enrollment with various statuses
- Certificate tracking

### Payroll
- Base salary + allowances
- Commission rules for sales staff
- Period-based payroll entries
- Detailed breakdown of pay components

### KPI Tracking
- Monthly, quarterly, yearly frequency support
- Target vs actual comparison
- Parent-child KPI hierarchies
- Multi-level ownership (employee, department)

---

## Backup & Maintenance

### Regular Backups
- Supabase automatically backs up daily
- Access backups in **Settings → Backups**
- Automated point-in-time recovery available

### Monitoring Queries
Check table row counts:
```sql
SELECT 
  schemaname,
  tablename,
  n_live_tup as row_count
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;
```

Monitor invoice payments status:
```sql
SELECT 
  payment_status,
  COUNT(*) as count,
  SUM(total_amount) as total_amount
FROM invoices
GROUP BY payment_status;
```

Check inventory levels:
```sql
SELECT 
  p.name,
  s.quantity_on_hand,
  s.reorder_level,
  CASE WHEN s.quantity_on_hand <= s.reorder_level THEN 'REORDER' ELSE 'OK' END as status
FROM inventory_stock s
JOIN products p ON s.product_id = p.id
ORDER BY s.quantity_on_hand;
```

---

## Common Queries

### Revenue by Period
```sql
SELECT 
  DATE_TRUNC('month', invoice_date)::DATE as month,
  SUM(total_amount) as revenue,
  COUNT(*) as invoice_count
FROM invoices
WHERE payment_status != 'cancelled'
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY month DESC;
```

### Top Customers
```sql
SELECT 
  c.customer_name,
  COUNT(o.id) as order_count,
  SUM(o.total_amount) as total_spent
FROM customers c
LEFT JOIN sales_orders o ON c.id = o.customer_id
GROUP BY c.id, c.customer_name
ORDER BY total_spent DESC;
```

### Course Enrollment Summary
```sql
SELECT 
  c.title,
  COUNT(ce.id) as total_enrolled,
  SUM(CASE WHEN ce.status = 'completed' THEN 1 ELSE 0 END) as completed,
  ROUND(100.0 * SUM(CASE WHEN ce.status = 'completed' THEN 1 ELSE 0 END) / COUNT(ce.id), 2) as completion_rate
FROM courses c
LEFT JOIN course_enrollments ce ON c.id = ce.course_id
GROUP BY c.id, c.title;
```

### Payroll Summary
```sql
SELECT 
  e.full_name,
  pe.base_salary,
  pe.allowance_total,
  pe.commission_total,
  pe.gross_pay,
  pe.net_pay
FROM payroll_entries pe
JOIN employees e ON pe.employee_id = e.id
WHERE pe.payroll_period_id = '<period-uuid>'
ORDER BY pe.net_pay DESC;
```

---

## Troubleshooting

### Tables not created?
- Check SQL syntax in `singapodent_schema.sql`
- Verify Supabase connection
- Check for duplicate table names from previous runs

### Foreign key errors when seeding?
- Run schema first, then seed
- Verify UUIDs match between tables
- Check that company_id exists before inserting related records

### Slow queries?
- Add indexes: `CREATE INDEX idx_table_column ON table(column);`
- Use EXPLAIN to analyze query plans
- Monitor with Supabase dashboard

### Auth user connection issues?
- Verify `auth_user_id` UUID matches exactly
- Check user roles have correct company_id
- Ensure RLS policies allow access (if enabled)

---

## Next Steps

1. **Frontend Integration** - Connect Next.js app to Supabase client
2. **API Routes** - Create backend endpoints for CRUD operations
3. **RLS Policies** - Set up Row Level Security for multi-tenant safety
4. **Reports** - Build dashboards for KPIs and financial reporting
5. **Automations** - Set up scheduled jobs for payroll, invoicing, etc.

For more info, see the main [README.md](../README.md).
