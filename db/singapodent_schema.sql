-- =============================================================================
-- SingapoDent — Dental Equipment & 3D Printer Sales + Training Platform
-- Modules: Product Management, Inventory, Sales, Courses, HR, Finance
-- =============================================================================

create extension if not exists "pgcrypto";

-- =============================================================================
-- ENUMS
-- =============================================================================
do $$ begin
  create type employment_type as enum ('fulltime','parttime','contract','intern','freelance');
exception when duplicate_object then null; end $$;

do $$ begin
  create type employee_status as enum ('active','onboarding','on_leave','terminated');
exception when duplicate_object then null; end $$;

do $$ begin
  create type product_type as enum ('dental_equipment','3d_printer','materials','accessories','other');
exception when duplicate_object then null; end $$;

do $$ begin
  create type order_status as enum ('draft','confirmed','processing','shipped','delivered','cancelled');
exception when duplicate_object then null; end $$;

do $$ begin
  create type payment_status as enum ('pending','partial','paid','overdue','cancelled');
exception when duplicate_object then null; end $$;

do $$ begin
  create type course_status as enum ('draft','published','active','completed','archived');
exception when duplicate_object then null; end $$;

do $$ begin
  create type enrollment_status as enum ('registered','in_progress','completed','dropped','certified');
exception when duplicate_object then null; end $$;

do $$ begin
  create type kpi_frequency as enum ('daily','weekly','monthly','quarterly','yearly');
exception when duplicate_object then null; end $$;

do $$ begin
  create type app_role as enum ('admin','sales_manager','sales_staff','course_manager','instructor','warehouse','finance','hr','viewer');
exception when duplicate_object then null; end $$;

-- =============================================================================
-- ORGANIZATION & CORE
-- =============================================================================
create table if not exists companies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text unique,
  currency text not null default 'VND',
  timezone text not null default 'Asia/Ho_Chi_Minh',
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists departments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  name text not null,
  code text,
  head_employee_id uuid,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists positions (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  name text not null,
  level text,
  base_salary_min numeric(18,2),
  base_salary_max numeric(18,2),
  created_at timestamptz not null default now()
);

create table if not exists employees (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  auth_user_id uuid unique,
  code text,
  full_name text not null,
  email text,
  phone text,
  avatar_url text,
  department_id uuid references departments(id) on delete set null,
  position_id uuid references positions(id) on delete set null,
  manager_id uuid references employees(id) on delete set null,
  join_date date,
  status employee_status not null default 'active',
  base_salary numeric(18,2) default 0,
  employment_type employment_type default 'fulltime',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table departments add constraint departments_head_fk
  foreign key (head_employee_id) references employees(id) on delete set null deferrable initially deferred;

create table if not exists user_roles (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null,
  company_id uuid not null references companies(id) on delete cascade,
  role app_role not null,
  scope_department_id uuid references departments(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(auth_user_id, company_id, role, scope_department_id)
);

-- =============================================================================
-- PRODUCTS & INVENTORY
-- =============================================================================
create table if not exists product_categories (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  name text not null,
  description text,
  parent_category_id uuid references product_categories(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  code text not null,
  name text not null,
  description text,
  product_type product_type not null,
  category_id uuid references product_categories(id) on delete set null,
  unit_price numeric(18,2) not null default 0,
  cost_price numeric(18,2) not null default 0,
  sku text unique,
  barcode text,
  supplier_id uuid,
  specifications jsonb default '{}'::jsonb,
  image_url text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists products_category_idx on products(category_id);
create index if not exists products_code_idx on products(code);

create table if not exists inventory_stock (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  product_id uuid not null references products(id) on delete cascade,
  warehouse_location text,
  quantity_on_hand int not null default 0,
  quantity_reserved int not null default 0,
  quantity_available int generated always as (quantity_on_hand - quantity_reserved) stored,
  reorder_level int default 10,
  reorder_quantity int default 50,
  last_counted_at date,
  updated_at timestamptz not null default now(),
  unique(product_id, warehouse_location)
);

create table if not exists inventory_movements (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  product_id uuid not null references products(id) on delete cascade,
  movement_type text not null,
  quantity int not null,
  reference_type text,
  reference_id uuid,
  notes text,
  recorded_by uuid references employees(id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists inventory_movements_product_idx on inventory_movements(product_id);
create index if not exists inventory_movements_date_idx on inventory_movements(created_at);

create table if not exists suppliers (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  name text not null,
  code text,
  contact_person text,
  email text,
  phone text,
  address text,
  city text,
  country text,
  payment_terms text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

-- =============================================================================
-- SALES & CUSTOMERS
-- =============================================================================
create table if not exists customers (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  code text,
  customer_name text not null,
  customer_type text,
  email text,
  phone text,
  address text,
  city text,
  country text,
  contact_person text,
  tax_id text,
  credit_limit numeric(18,2) default 0,
  payment_terms text default 'Net 30',
  active boolean not null default true,
  total_purchase_amount numeric(18,2) default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists customers_code_idx on customers(code);

create table if not exists sales_orders (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  order_number text unique not null,
  customer_id uuid not null references customers(id) on delete restrict,
  sales_person_id uuid references employees(id) on delete set null,
  order_date date not null default current_date,
  delivery_date date,
  status order_status not null default 'draft',
  subtotal numeric(18,2) default 0,
  tax_amount numeric(18,2) default 0,
  total_amount numeric(18,2) default 0,
  discount_amount numeric(18,2) default 0,
  shipping_cost numeric(18,2) default 0,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists sales_orders_customer_idx on sales_orders(customer_id);
create index if not exists sales_orders_date_idx on sales_orders(order_date);
create index if not exists sales_orders_status_idx on sales_orders(status);

create table if not exists sales_order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references sales_orders(id) on delete cascade,
  product_id uuid not null references products(id) on delete restrict,
  quantity int not null,
  unit_price numeric(18,2) not null,
  discount_pct numeric(5,2) default 0,
  line_total numeric(18,2) generated always as (quantity * unit_price * (1 - discount_pct/100)) stored
);

create index if not exists sales_order_items_order_idx on sales_order_items(order_id);

create table if not exists invoices (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  invoice_number text unique not null,
  order_id uuid references sales_orders(id) on delete set null,
  customer_id uuid not null references customers(id) on delete restrict,
  invoice_date date not null default current_date,
  due_date date,
  subtotal numeric(18,2) default 0,
  tax_amount numeric(18,2) default 0,
  total_amount numeric(18,2) default 0,
  paid_amount numeric(18,2) default 0,
  payment_status payment_status not null default 'pending',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists invoices_customer_idx on invoices(customer_id);
create index if not exists invoices_date_idx on invoices(invoice_date);

create table if not exists invoice_payments (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references invoices(id) on delete cascade,
  payment_date date not null,
  amount numeric(18,2) not null,
  payment_method text,
  reference_number text,
  notes text,
  recorded_by uuid references employees(id) on delete set null,
  created_at timestamptz not null default now()
);

-- =============================================================================
-- COURSES & TRAINING
-- =============================================================================
create table if not exists courses (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  code text not null unique,
  title text not null,
  description text,
  category text,
  instructor_id uuid references employees(id) on delete set null,
  course_status course_status not null default 'draft',
  price numeric(18,2) not null default 0,
  duration_hours int,
  max_students int,
  curriculum jsonb default '{}'::jsonb,
  image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists courses_code_idx on courses(code);

create table if not exists course_sessions (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references courses(id) on delete cascade,
  session_number int not null,
  title text,
  start_date date not null,
  end_date date,
  start_time time,
  location text,
  instructor_id uuid references employees(id) on delete set null,
  capacity int default 30,
  enrolled_count int default 0,
  created_at timestamptz not null default now()
);

create index if not exists course_sessions_course_idx on course_sessions(course_id);

create table if not exists course_enrollments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  student_email text not null,
  student_name text not null,
  enrollment_date date not null default current_date,
  status enrollment_status not null default 'registered',
  completed_date date,
  certificate_url text,
  progress_pct numeric(5,2) default 0,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists course_enrollments_course_idx on course_enrollments(course_id);
create index if not exists course_enrollments_email_idx on course_enrollments(student_email);

create table if not exists course_materials (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references courses(id) on delete cascade,
  title text not null,
  description text,
  material_type text,
  content_url text,
  sort_order int default 0,
  created_at timestamptz not null default now()
);

create table if not exists student_progress (
  id uuid primary key default gen_random_uuid(),
  enrollment_id uuid not null references course_enrollments(id) on delete cascade,
  material_id uuid references course_materials(id) on delete set null,
  completed boolean default false,
  score numeric(5,2),
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

-- =============================================================================
-- HR & COMPENSATION
-- =============================================================================
create table if not exists employment_contracts (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  employee_id uuid not null references employees(id) on delete cascade,
  starts_at date not null,
  ends_at date,
  base_salary numeric(18,2) not null default 0,
  allowances jsonb not null default '{}'::jsonb,
  document_url text,
  created_at timestamptz not null default now()
);

create table if not exists salary_components (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  employee_id uuid not null references employees(id) on delete cascade,
  component_type text not null,
  amount numeric(18,2) not null default 0,
  effective_from date not null default current_date,
  effective_to date
);

create table if not exists commission_rules (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  name text not null,
  applies_to jsonb not null default '{}'::jsonb,
  definition jsonb not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists payroll_periods (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  period text not null,
  status text not null default 'draft',
  closed_at timestamptz,
  unique(company_id, period)
);

create table if not exists payroll_entries (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  payroll_period_id uuid not null references payroll_periods(id) on delete cascade,
  employee_id uuid not null references employees(id) on delete cascade,
  base_salary numeric(18,2) default 0,
  allowance_total numeric(18,2) default 0,
  commission_total numeric(18,2) default 0,
  bonus_total numeric(18,2) default 0,
  penalty_total numeric(18,2) default 0,
  adjustment_total numeric(18,2) default 0,
  gross_pay numeric(18,2) default 0,
  net_pay numeric(18,2) default 0,
  breakdown jsonb default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique(payroll_period_id, employee_id)
);

-- =============================================================================
-- KPI & PERFORMANCE
-- =============================================================================
create table if not exists kpis (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  code text,
  name text not null,
  description text,
  owner_employee_id uuid references employees(id) on delete set null,
  owner_department_id uuid references departments(id) on delete set null,
  unit text default '%',
  target_frequency kpi_frequency not null default 'monthly',
  weight numeric(6,3) default 1,
  parent_kpi_id uuid references kpis(id) on delete set null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists kpi_targets (
  id uuid primary key default gen_random_uuid(),
  kpi_id uuid not null references kpis(id) on delete cascade,
  period text not null,
  target_value numeric(20,4) not null default 0,
  note text,
  created_at timestamptz not null default now(),
  unique(kpi_id, period)
);

create table if not exists kpi_actuals (
  id uuid primary key default gen_random_uuid(),
  kpi_id uuid not null references kpis(id) on delete cascade,
  period text not null,
  actual_value numeric(20,4) not null default 0,
  completion_rate numeric(8,4),
  status text,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(kpi_id, period)
);

-- =============================================================================
-- FINANCE & ACCOUNTING
-- =============================================================================
create table if not exists chart_of_accounts (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  code text not null,
  name text not null,
  account_type text not null,
  parent_id uuid references chart_of_accounts(id) on delete set null,
  unique(company_id, code)
);

create table if not exists cost_centers (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  name text not null,
  department_id uuid references departments(id) on delete set null,
  code text
);

create table if not exists accounting_entries (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  entry_date date not null,
  account_code text not null,
  debit numeric(18,2) default 0,
  credit numeric(18,2) default 0,
  cost_center_id uuid references cost_centers(id) on delete set null,
  department_id uuid references departments(id) on delete set null,
  employee_id uuid references employees(id) on delete set null,
  reference_type text,
  reference_id uuid,
  note text,
  created_at timestamptz not null default now()
);

create index if not exists accounting_entries_date_idx on accounting_entries(entry_date);

create table if not exists budgets (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  name text not null,
  period text not null,
  created_at timestamptz not null default now()
);

create table if not exists budget_lines (
  id uuid primary key default gen_random_uuid(),
  budget_id uuid not null references budgets(id) on delete cascade,
  account_code text,
  cost_center_id uuid references cost_centers(id) on delete set null,
  department_id uuid references departments(id) on delete set null,
  planned numeric(18,2) default 0,
  actual numeric(18,2) default 0
);

create table if not exists cashflow_records (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  tx_date date not null,
  bucket text not null,
  inflow numeric(18,2) default 0,
  outflow numeric(18,2) default 0,
  note text,
  created_at timestamptz not null default now()
);

create table if not exists financial_snapshots (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  period text not null,
  kind text not null,
  payload jsonb not null,
  created_at timestamptz not null default now(),
  unique(company_id, period, kind)
);

-- =============================================================================
-- APP SETTINGS & METADATA
-- =============================================================================
create table if not exists app_settings (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade unique,
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists audit_logs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  actor_id uuid,
  action text not null,
  entity_type text,
  entity_id uuid,
  changes jsonb,
  created_at timestamptz not null default now()
);

create index if not exists audit_logs_date_idx on audit_logs(created_at);
