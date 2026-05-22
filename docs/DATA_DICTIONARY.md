# SingapoDent Data Dictionary

## Organization & Core

### companies
Represents the main company entity.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| name | text | Company name (e.g., "SingapoDent") |
| code | text | Company code for reference |
| currency | text | Currency code (default: VND) |
| timezone | text | Timezone (default: Asia/Ho_Chi_Minh) |
| settings | jsonb | JSON configuration (brand, fiscal year, etc.) |
| created_at | timestamptz | Creation timestamp |
| updated_at | timestamptz | Last update timestamp |

### departments
Organizational departments.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| name | text | Department name (e.g., Sales, Marketing) |
| code | text | Department code |
| head_employee_id | uuid | FK to employees (department head) |
| description | text | Department description |
| created_at | timestamptz | Creation timestamp |

### positions
Job positions and salary ranges.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| name | text | Position name (e.g., Sales Manager) |
| level | text | Position level (C-Level, Manager, Staff) |
| base_salary_min | numeric | Minimum salary for position |
| base_salary_max | numeric | Maximum salary for position |
| created_at | timestamptz | Creation timestamp |

### employees
Company employees.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| auth_user_id | uuid | FK to auth.users (for authentication) |
| code | text | Employee code |
| full_name | text | Employee full name |
| email | text | Email address |
| phone | text | Phone number |
| avatar_url | text | Profile picture URL |
| department_id | uuid | FK to departments |
| position_id | uuid | FK to positions |
| manager_id | uuid | FK to employees (reporting manager) |
| join_date | date | Employment start date |
| status | employee_status | active, onboarding, on_leave, terminated |
| base_salary | numeric | Base monthly salary |
| employment_type | employment_type | fulltime, parttime, contract, intern, freelance |
| created_at | timestamptz | Creation timestamp |
| updated_at | timestamptz | Last update timestamp |

### user_roles
Maps auth users to roles within company.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| auth_user_id | uuid | FK to auth.users |
| company_id | uuid | FK to companies |
| role | app_role | admin, sales_manager, sales_staff, course_manager, instructor, warehouse, finance, hr, viewer |
| scope_department_id | uuid | Optional department scope |
| created_at | timestamptz | Creation timestamp |

---

## Products & Inventory

### product_categories
Product category hierarchy.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| name | text | Category name |
| description | text | Category description |
| parent_category_id | uuid | FK to product_categories (for hierarchy) |
| created_at | timestamptz | Creation timestamp |

### products
Product master data.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| code | text | Product code |
| name | text | Product name |
| description | text | Full description |
| product_type | product_type | dental_equipment, 3d_printer, materials, accessories, other |
| category_id | uuid | FK to product_categories |
| unit_price | numeric | Selling price |
| cost_price | numeric | Cost price (for margin calculation) |
| sku | text | Stock keeping unit |
| barcode | text | Product barcode |
| supplier_id | uuid | FK to suppliers |
| specifications | jsonb | Technical specs in JSON format |
| image_url | text | Product image URL |
| active | boolean | Is product currently active? |
| created_at | timestamptz | Creation timestamp |
| updated_at | timestamptz | Last update timestamp |

### inventory_stock
Real-time inventory levels.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| product_id | uuid | FK to products |
| warehouse_location | text | Storage location |
| quantity_on_hand | int | Total quantity in stock |
| quantity_reserved | int | Quantity reserved for orders |
| quantity_available | int | Generated: on_hand - reserved |
| reorder_level | int | Minimum quantity before reorder alert |
| reorder_quantity | int | Quantity to order when reorder_level reached |
| last_counted_at | date | Last inventory count date |
| updated_at | timestamptz | Last update timestamp |

### inventory_movements
Inventory transaction log.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| product_id | uuid | FK to products |
| movement_type | text | purchase, sale, adjustment, damage, return |
| quantity | int | Quantity moved (positive or negative) |
| reference_type | text | Order, Invoice, Adjustment, etc. |
| reference_id | uuid | ID of related document |
| notes | text | Movement notes |
| recorded_by | uuid | FK to employees (who recorded it) |
| created_at | timestamptz | Creation timestamp |

### suppliers
Vendor/supplier information.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| name | text | Supplier name |
| code | text | Supplier code |
| contact_person | text | Primary contact name |
| email | text | Supplier email |
| phone | text | Supplier phone |
| address | text | Street address |
| city | text | City |
| country | text | Country |
| payment_terms | text | Payment terms |
| active | boolean | Is supplier active? |
| created_at | timestamptz | Creation timestamp |

---

## Sales & Customers

### customers
Customer/client information.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| code | text | Customer code |
| customer_name | text | Business or person name |
| customer_type | text | B2B, B2C, Distributor, etc. |
| email | text | Email address |
| phone | text | Phone number |
| address | text | Street address |
| city | text | City |
| country | text | Country |
| contact_person | text | Primary contact name |
| tax_id | text | Tax/VAT number |
| credit_limit | numeric | Maximum credit allowed |
| payment_terms | text | Default payment terms (e.g., Net 30) |
| active | boolean | Is customer active? |
| total_purchase_amount | numeric | Lifetime purchase total |
| created_at | timestamptz | Creation timestamp |
| updated_at | timestamptz | Last update timestamp |

### sales_orders
Customer orders for products.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| order_number | text | Unique order number |
| customer_id | uuid | FK to customers |
| sales_person_id | uuid | FK to employees (salesperson) |
| order_date | date | Order creation date |
| delivery_date | date | Expected delivery date |
| status | order_status | draft, confirmed, processing, shipped, delivered, cancelled |
| subtotal | numeric | Items total before tax/shipping |
| tax_amount | numeric | Tax amount |
| total_amount | numeric | Final total |
| discount_amount | numeric | Discount applied |
| shipping_cost | numeric | Shipping charge |
| notes | text | Order notes |
| created_at | timestamptz | Creation timestamp |
| updated_at | timestamptz | Last update timestamp |

### sales_order_items
Line items in a sales order.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| order_id | uuid | FK to sales_orders |
| product_id | uuid | FK to products |
| quantity | int | Ordered quantity |
| unit_price | numeric | Price per unit at time of order |
| discount_pct | numeric | Line item discount percentage |
| line_total | numeric | Generated: quantity × unit_price × (1 - discount_pct/100) |

### invoices
Customer invoices for payment.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| invoice_number | text | Unique invoice number |
| order_id | uuid | FK to sales_orders |
| customer_id | uuid | FK to customers |
| invoice_date | date | Invoice creation date |
| due_date | date | Payment due date |
| subtotal | numeric | Items total |
| tax_amount | numeric | Tax amount |
| total_amount | numeric | Total amount due |
| paid_amount | numeric | Amount paid so far |
| payment_status | payment_status | pending, partial, paid, overdue, cancelled |
| notes | text | Invoice notes |
| created_at | timestamptz | Creation timestamp |
| updated_at | timestamptz | Last update timestamp |

### invoice_payments
Payment records for invoices.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| invoice_id | uuid | FK to invoices |
| payment_date | date | Date of payment |
| amount | numeric | Payment amount |
| payment_method | text | cash, check, bank_transfer, credit_card |
| reference_number | text | Payment reference (check #, transaction ID, etc.) |
| notes | text | Payment notes |
| recorded_by | uuid | FK to employees |
| created_at | timestamptz | Creation timestamp |

---

## Courses & Training

### courses
Training courses offered by SingapoDent.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| code | text | Course code |
| title | text | Course title |
| description | text | Course description |
| category | text | Course category (Technology, Operations, Sales) |
| instructor_id | uuid | FK to employees (primary instructor) |
| course_status | course_status | draft, published, active, completed, archived |
| price | numeric | Course price |
| duration_hours | int | Total course duration in hours |
| max_students | int | Maximum enrollment |
| curriculum | jsonb | Course outline/curriculum in JSON |
| image_url | text | Course image/thumbnail URL |
| created_at | timestamptz | Creation timestamp |
| updated_at | timestamptz | Last update timestamp |

### course_sessions
Individual session/cohort of a course.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| course_id | uuid | FK to courses |
| session_number | int | Session/cohort number |
| title | text | Session title |
| start_date | date | Session start date |
| end_date | date | Session end date |
| start_time | time | Daily start time |
| location | text | Physical or virtual location |
| instructor_id | uuid | FK to employees (session instructor) |
| capacity | int | Maximum students for this session |
| enrolled_count | int | Current enrollments |
| created_at | timestamptz | Creation timestamp |

### course_enrollments
Student enrollment in courses.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| course_id | uuid | FK to courses |
| student_email | text | Student email address |
| student_name | text | Student full name |
| enrollment_date | date | Enrollment date |
| status | enrollment_status | registered, in_progress, completed, dropped, certified |
| completed_date | date | Course completion date |
| certificate_url | text | Certificate URL/path |
| progress_pct | numeric | Overall progress percentage |
| notes | text | Enrollment notes |
| created_at | timestamptz | Creation timestamp |
| updated_at | timestamptz | Last update timestamp |

### course_materials
Course content/materials.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| course_id | uuid | FK to courses |
| title | text | Material title |
| description | text | Material description |
| material_type | text | video, document, quiz, assignment |
| content_url | text | URL to material content |
| sort_order | int | Display order in course |
| created_at | timestamptz | Creation timestamp |

### student_progress
Track individual student progress through materials.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| enrollment_id | uuid | FK to course_enrollments |
| material_id | uuid | FK to course_materials |
| completed | boolean | Has student completed this material? |
| score | numeric | Score if applicable |
| completed_at | timestamptz | Completion timestamp |
| created_at | timestamptz | Creation timestamp |

---

## HR & Compensation

### employment_contracts
Employment contract details.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| employee_id | uuid | FK to employees |
| starts_at | date | Contract start date |
| ends_at | date | Contract end date (null if ongoing) |
| base_salary | numeric | Monthly base salary |
| allowances | jsonb | Allowances and benefits in JSON |
| document_url | text | Contract document URL |
| created_at | timestamptz | Creation timestamp |

### salary_components
Salary components for employees (allowances, bonuses, etc.).

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| employee_id | uuid | FK to employees |
| component_type | text | allowance, bonus, deduction, penalty |
| amount | numeric | Amount of component |
| effective_from | date | Start date for component |
| effective_to | date | End date for component |

### commission_rules
Rules for calculating sales commissions.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| name | text | Rule name |
| applies_to | jsonb | Roles/departments affected |
| definition | jsonb | Commission formula/definition |
| active | boolean | Is rule active? |
| created_at | timestamptz | Creation timestamp |

### payroll_periods
Payroll processing periods.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| period | text | Period identifier (e.g., "2025-01") |
| status | text | draft, calculated, approved, paid |
| closed_at | timestamptz | When payroll was finalized |

### payroll_entries
Calculated payroll for employees.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| payroll_period_id | uuid | FK to payroll_periods |
| employee_id | uuid | FK to employees |
| base_salary | numeric | Base salary for period |
| allowance_total | numeric | Total allowances |
| commission_total | numeric | Total commissions |
| bonus_total | numeric | Total bonuses |
| penalty_total | numeric | Total penalties/deductions |
| adjustment_total | numeric | Manual adjustments |
| gross_pay | numeric | Total before tax |
| net_pay | numeric | Amount after deductions |
| breakdown | jsonb | Detailed breakdown of all components |
| created_at | timestamptz | Creation timestamp |

---

## KPI & Performance

### kpis
Key Performance Indicators.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| code | text | KPI code |
| name | text | KPI name |
| description | text | KPI description |
| owner_employee_id | uuid | FK to employees (responsible person) |
| owner_department_id | uuid | FK to departments (responsible dept) |
| unit | text | Unit of measure (%, VND, Orders, etc.) |
| target_frequency | kpi_frequency | daily, weekly, monthly, quarterly, yearly |
| weight | numeric | Importance weight |
| parent_kpi_id | uuid | FK to kpis (for hierarchies) |
| active | boolean | Is KPI being tracked? |
| created_at | timestamptz | Creation timestamp |
| updated_at | timestamptz | Last update timestamp |

### kpi_targets
Target values for KPIs by period.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| kpi_id | uuid | FK to kpis |
| period | text | Period (e.g., "2025-01", "Q1-2025") |
| target_value | numeric | Target value |
| note | text | Notes about target |
| created_at | timestamptz | Creation timestamp |

### kpi_actuals
Actual achieved values for KPIs.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| kpi_id | uuid | FK to kpis |
| period | text | Period (e.g., "2025-01") |
| actual_value | numeric | Actual achieved value |
| completion_rate | numeric | % of target achieved |
| status | text | on_track, at_risk, exceeded, missed |
| note | text | Notes on performance |
| created_at | timestamptz | Creation timestamp |
| updated_at | timestamptz | Last update timestamp |

---

## Finance & Accounting

### chart_of_accounts
Account structure for financial statements.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| code | text | Account code |
| name | text | Account name |
| account_type | text | Asset, Liability, Equity, Revenue, Expense |
| parent_id | uuid | FK to chart_of_accounts (for hierarchy) |

### cost_centers
Cost allocation centers.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| name | text | Cost center name |
| department_id | uuid | FK to departments |
| code | text | Cost center code |

### accounting_entries
Journal entries for all transactions.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| entry_date | date | Transaction date |
| account_code | text | Account being affected |
| debit | numeric | Debit amount |
| credit | numeric | Credit amount |
| cost_center_id | uuid | FK to cost_centers |
| department_id | uuid | FK to departments |
| employee_id | uuid | FK to employees |
| reference_type | text | Order, Invoice, Payroll, etc. |
| reference_id | uuid | ID of related document |
| note | text | Transaction notes |
| created_at | timestamptz | Creation timestamp |

### budgets
Budget planning documents.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| name | text | Budget name |
| period | text | Budget period (e.g., "2025") |
| created_at | timestamptz | Creation timestamp |

### budget_lines
Individual line items in a budget.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| budget_id | uuid | FK to budgets |
| account_code | text | Account code |
| cost_center_id | uuid | FK to cost_centers |
| department_id | uuid | FK to departments |
| planned | numeric | Planned amount |
| actual | numeric | Actual spent/received |

### cashflow_records
Cash inflow/outflow tracking.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| tx_date | date | Transaction date |
| bucket | text | Category (e.g., Sales, Payroll, Supplies) |
| inflow | numeric | Cash received |
| outflow | numeric | Cash paid out |
| note | text | Transaction notes |
| created_at | timestamptz | Creation timestamp |

### financial_snapshots
Point-in-time snapshots of financial statements.

| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| company_id | uuid | FK to companies |
| period | text | Period (e.g., "2025-01") |
| kind | text | P&L (Income Statement), BS (Balance Sheet), CF (Cash Flow) |
| payload | jsonb | Financial statement data in JSON |
| created_at | timestamptz | Creation timestamp |

---

## Enums Reference

### employment_type
- `fulltime` - Full-time employee
- `parttime` - Part-time employee
- `contract` - Contract worker
- `intern` - Intern
- `freelance` - Freelancer

### employee_status
- `active` - Currently employed
- `onboarding` - In onboarding process
- `on_leave` - On leave
- `terminated` - No longer employed

### product_type
- `dental_equipment` - Dental tools/machines
- `3d_printer` - 3D printing equipment
- `materials` - Consumable materials
- `accessories` - Supporting items
- `other` - Other products

### order_status
- `draft` - Being prepared
- `confirmed` - Confirmed for processing
- `processing` - Being prepared
- `shipped` - In transit
- `delivered` - Delivered to customer
- `cancelled` - Order cancelled

### payment_status
- `pending` - No payment received
- `partial` - Partial payment received
- `paid` - Fully paid
- `overdue` - Past due date
- `cancelled` - Payment cancelled

### course_status
- `draft` - Course being created
- `published` - Available for enrollment
- `active` - Currently running
- `completed` - All sessions finished
- `archived` - Archived (no longer offered)

### enrollment_status
- `registered` - Enrolled in course
- `in_progress` - Currently taking course
- `completed` - Finished course
- `dropped` - Withdrew from course
- `certified` - Completed and certified

### kpi_frequency
- `daily` - Daily tracking
- `weekly` - Weekly tracking
- `monthly` - Monthly tracking
- `quarterly` - Quarterly tracking
- `yearly` - Yearly tracking

### app_role
- `admin` - Full system access
- `sales_manager` - Manage sales team
- `sales_staff` - Create orders, view data
- `course_manager` - Create/manage courses
- `instructor` - Teach courses
- `warehouse` - Manage inventory
- `finance` - Financial management
- `hr` - HR operations
- `viewer` - Read-only access
