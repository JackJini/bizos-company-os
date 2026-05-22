-- =============================================================================
-- SingapoDent Demo Data Seed
-- Run AFTER singapodent_schema.sql
-- =============================================================================

-- 1. Company
insert into companies (id, name, code, currency, timezone, settings)
values ('00000000-0000-0000-0000-00000000c001', 'SingapoDent', 'SPD', 'VND', 'Asia/Ho_Chi_Minh', '{"brand":"SingapoDent","fiscal_year_start":"01-01"}'::jsonb)
on conflict do nothing;

-- 2. Departments
insert into departments (id, company_id, name, code)
values 
  ('00000000-0000-0000-0000-00000000d001', '00000000-0000-0000-0000-00000000c001', 'Sales', 'SALES'),
  ('00000000-0000-0000-0000-00000000d002', '00000000-0000-0000-0000-00000000c001', 'Marketing', 'MKT'),
  ('00000000-0000-0000-0000-00000000d003', '00000000-0000-0000-0000-00000000c001', 'Warehouse', 'WH'),
  ('00000000-0000-0000-0000-00000000d004', '00000000-0000-0000-0000-00000000c001', 'Finance', 'FIN'),
  ('00000000-0000-0000-0000-00000000d005', '00000000-0000-0000-0000-00000000c001', 'HR', 'HR'),
  ('00000000-0000-0000-0000-00000000d006', '00000000-0000-0000-0000-00000000c001', 'Training', 'TRN')
on conflict do nothing;

-- 3. Positions
insert into positions (id, company_id, name, level, base_salary_min, base_salary_max)
values
  ('00000000-0000-0000-0000-00000000p001', '00000000-0000-0000-0000-00000000c001', 'CEO', 'C-Level', 80000000, 120000000),
  ('00000000-0000-0000-0000-00000000p002', '00000000-0000-0000-0000-00000000c001', 'Sales Manager', 'Manager', 40000000, 60000000),
  ('00000000-0000-0000-0000-00000000p003', '00000000-0000-0000-0000-00000000c001', 'Sales Staff', 'Staff', 15000000, 25000000),
  ('00000000-0000-0000-0000-00000000p004', '00000000-0000-0000-0000-00000000c001', 'Instructor', 'Staff', 20000000, 30000000),
  ('00000000-0000-0000-0000-00000000p005', '00000000-0000-0000-0000-00000000c001', 'Warehouse Manager', 'Manager', 30000000, 45000000),
  ('00000000-0000-0000-0000-00000000p006', '00000000-0000-0000-0000-00000000c001', 'Finance Manager', 'Manager', 45000000, 65000000)
on conflict do nothing;

-- 4. Employees
insert into employees (id, company_id, code, full_name, email, phone, department_id, position_id, base_salary, status)
values
  ('00000000-0000-0000-0000-0000000000e1', '00000000-0000-0000-0000-00000000c001', 'CEO001', 'Nguyễn Văn A', 'ceo@singapodent.demo', '+84901234567', null, '00000000-0000-0000-0000-00000000p001', 80000000, 'active'),
  ('00000000-0000-0000-0000-0000000000e2', '00000000-0000-0000-0000-00000000c001', 'SALES001', 'Trần Thị B', 'sales.manager@singapodent.demo', '+84902234567', '00000000-0000-0000-0000-00000000d001', '00000000-0000-0000-0000-00000000p002', 45000000, 'active'),
  ('00000000-0000-0000-0000-0000000000e3', '00000000-0000-0000-0000-00000000c001', 'SALES002', 'Lê Văn C', 'sales1@singapodent.demo', '+84903234567', '00000000-0000-0000-0000-00000000d001', '00000000-0000-0000-0000-00000000p003', 18000000, 'active'),
  ('00000000-0000-0000-0000-0000000000e4', '00000000-0000-0000-0000-00000000c001', 'SALES003', 'Phạm Thu D', 'sales2@singapodent.demo', '+84904234567', '00000000-0000-0000-0000-00000000d001', '00000000-0000-0000-0000-00000000p003', 17000000, 'active'),
  ('00000000-0000-0000-0000-0000000000e5', '00000000-0000-0000-0000-00000000c001', 'TRN001', 'Hoàng Minh E', 'instructor1@singapodent.demo', '+84905234567', '00000000-0000-0000-0000-00000000d006', '00000000-0000-0000-0000-00000000p004', 22000000, 'active'),
  ('00000000-0000-0000-0000-0000000000e6', '00000000-0000-0000-0000-00000000c001', 'WH001', 'Đỗ Quỳnh F', 'warehouse@singapodent.demo', '+84906234567', '00000000-0000-0000-0000-00000000d003', '00000000-0000-0000-0000-00000000p005', 32000000, 'active'),
  ('00000000-0000-0000-0000-0000000000e7', '00000000-0000-0000-0000-00000000c001', 'FIN001', 'Vũ Thanh G', 'finance@singapodent.demo', '+84907234567', '00000000-0000-0000-0000-00000000d004', '00000000-0000-0000-0000-00000000p006', 48000000, 'active')
on conflict do nothing;

-- Update department heads
update departments set head_employee_id = '00000000-0000-0000-0000-0000000000e2' where id = '00000000-0000-0000-0000-00000000d001';
update departments set head_employee_id = '00000000-0000-0000-0000-0000000000e5' where id = '00000000-0000-0000-0000-00000000d006';
update departments set head_employee_id = '00000000-0000-0000-0000-0000000000e6' where id = '00000000-0000-0000-0000-00000000d003';
update departments set head_employee_id = '00000000-0000-0000-0000-0000000000e7' where id = '00000000-0000-0000-0000-00000000d004';

-- 5. Product Categories
insert into product_categories (id, company_id, name, description)
values
  ('00000000-0000-0000-0000-00000000cat01', '00000000-0000-0000-0000-00000000c001', 'Dental Equipment', 'Professional dental equipment and instruments'),
  ('00000000-0000-0000-0000-00000000cat02', '00000000-0000-0000-0000-00000000c001', '3D Printers', 'Dental 3D printers and related devices'),
  ('00000000-0000-0000-0000-00000000cat03', '00000000-0000-0000-0000-00000000c001', 'Materials', 'Dental materials and consumables'),
  ('00000000-0000-0000-0000-00000000cat04', '00000000-0000-0000-0000-00000000c001', 'Accessories', 'Dental accessories and supplies')
on conflict do nothing;

-- 6. Products
insert into products (id, company_id, code, name, description, product_type, category_id, unit_price, cost_price, sku)
values
  ('00000000-0000-0000-0000-00000000prod01', '00000000-0000-0000-0000-00000000c001', 'DRILL-3000', 'Dental High Speed Drill X-3000', 'Professional dental drill', 'dental_equipment', '00000000-0000-0000-0000-00000000cat01', 15000000, 10000000, 'DRILL-3000-SKU'),
  ('00000000-0000-0000-0000-00000000prod02', '00000000-0000-0000-0000-00000000c001', 'PRINTER-PRO', 'LS 3D Dental Printer Pro', 'High-precision dental 3D printer', '3d_printer', '00000000-0000-0000-0000-00000000cat02', 450000000, 300000000, 'PRINTER-PRO-SKU'),
  ('00000000-0000-0000-0000-00000000prod03', '00000000-0000-0000-0000-00000000c001', 'RESIN-CLEAR', 'Dental Resin Clear - 1kg', 'Transparent resin for crowns', 'materials', '00000000-0000-0000-0000-00000000cat03', 2000000, 1200000, 'RESIN-CLEAR-1KG'),
  ('00000000-0000-0000-0000-00000000prod04', '00000000-0000-0000-0000-00000000c001', 'SUCTION-UNIT', 'Dental Suction Unit', 'Portable suction system', 'dental_equipment', '00000000-0000-0000-0000-00000000cat01', 25000000, 18000000, 'SUCTION-UNIT-SKU'),
  ('00000000-0000-0000-0000-00000000prod05', '00000000-0000-0000-0000-00000000c001', 'LED-LIGHT', 'Surgical LED Light Kit', 'Adjustable LED light for dental work', 'accessories', '00000000-0000-0000-0000-00000000cat04', 8000000, 5000000, 'LED-LIGHT-SKU')
on conflict do nothing;

-- 7. Inventory
insert into inventory_stock (company_id, product_id, warehouse_location, quantity_on_hand, reorder_level, reorder_quantity)
values
  ('00000000-0000-0000-0000-00000000c001', '00000000-0000-0000-0000-00000000prod01', 'Shelf A1', 5, 2, 5),
  ('00000000-0000-0000-0000-00000000c001', '00000000-0000-0000-0000-00000000prod02', 'Shelf B2', 2, 1, 2),
  ('00000000-0000-0000-0000-00000000c001', '00000000-0000-0000-0000-00000000prod03', 'Cabinet C1', 50, 20, 100),
  ('00000000-0000-0000-0000-00000000c001', '00000000-0000-0000-0000-00000000prod04', 'Shelf A2', 3, 1, 3),
  ('00000000-0000-0000-0000-00000000c001', '00000000-0000-0000-0000-00000000prod05', 'Shelf B1', 12, 5, 15)
on conflict do nothing;

-- 8. Customers
insert into customers (id, company_id, code, customer_name, customer_type, email, phone, city, country)
values
  ('00000000-0000-0000-0000-00000000cust01', '00000000-0000-0000-0000-00000000c001', 'CUST001', 'Dental Clinic A', 'B2B', 'clinic1@email.com', '+84911111111', 'Ho Chi Minh', 'Vietnam'),
  ('00000000-0000-0000-0000-00000000cust02', '00000000-0000-0000-0000-00000000c001', 'CUST002', 'Dr. Tuan Dental', 'B2B', 'dr.tuan@email.com', '+84912121212', 'Hanoi', 'Vietnam'),
  ('00000000-0000-0000-0000-00000000cust03', '00000000-0000-0000-0000-00000000c001', 'CUST003', 'Smile Dental Lab', 'B2B', 'lab@email.com', '+84913131313', 'Da Nang', 'Vietnam')
on conflict do nothing;

-- 9. Courses
insert into courses (id, company_id, code, title, description, category, instructor_id, course_status, price, duration_hours)
values
  ('00000000-0000-0000-0000-00000000crs01', '00000000-0000-0000-0000-00000000c001', 'COURSE-3D-INTRO', '3D Printing in Dentistry 101', 'Introduction to 3D printing technology for dental professionals', 'Technology', '00000000-0000-0000-0000-0000000000e5', 'published', 5000000, 16),
  ('00000000-0000-0000-0000-00000000crs02', '00000000-0000-0000-0000-00000000c001', 'COURSE-EQUIP', 'Dental Equipment Management', 'Proper maintenance and operation of dental equipment', 'Operations', '00000000-0000-0000-0000-0000000000e5', 'published', 3000000, 12),
  ('00000000-0000-0000-0000-00000000crs03', '00000000-0000-0000-0000-00000000c001', 'COURSE-SALES', 'Dental Equipment Sales Mastery', 'Advanced sales techniques for dental products', 'Sales', '00000000-0000-0000-0000-0000000000e2', 'published', 4000000, 20)
on conflict do nothing;

-- 10. Course Sessions
insert into course_sessions (id, course_id, session_number, title, start_date, end_date, start_time, location, instructor_id, capacity)
values
  ('00000000-0000-0000-0000-00000000sess01', '00000000-0000-0000-0000-00000000crs01', 1, 'Week 1 - Basics', '2025-06-01', '2025-06-07', '09:00:00', 'Training Room A', '00000000-0000-0000-0000-0000000000e5', 20),
  ('00000000-0000-0000-0000-00000000sess02', '00000000-0000-0000-0000-00000000crs01', 2, 'Week 2 - Advanced', '2025-06-08', '2025-06-14', '09:00:00', 'Training Room A', '00000000-0000-0000-0000-0000000000e5', 20),
  ('00000000-0000-0000-0000-00000000sess03', '00000000-0000-0000-0000-00000000crs02', 1, 'Full Course', '2025-06-15', '2025-07-15', '10:00:00', 'Training Room B', '00000000-0000-0000-0000-0000000000e5', 25)
on conflict do nothing;

-- 11. KPIs
insert into kpis (id, company_id, code, name, owner_department_id, unit, target_frequency)
values
  ('00000000-0000-0000-0000-00000000kpi01', '00000000-0000-0000-0000-00000000c001', 'REVENUE', 'Monthly Revenue', '00000000-0000-0000-0000-00000000d001', 'VND', 'monthly'),
  ('00000000-0000-0000-0000-00000000kpi02', '00000000-0000-0000-0000-00000000c001', 'SALES-TARGET', 'Sales Order Count', '00000000-0000-0000-0000-00000000d001', 'Orders', 'monthly'),
  ('00000000-0000-0000-0000-00000000kpi03', '00000000-0000-0000-0000-00000000c001', 'INVENTORY-HEALTH', 'Inventory Turnover', '00000000-0000-0000-0000-00000000d003', 'Ratio', 'monthly'),
  ('00000000-0000-0000-0000-00000000kpi04', '00000000-0000-0000-0000-00000000c001', 'COURSE-ENROLLMENT', 'Course Enrollments', '00000000-0000-0000-0000-00000000d006', 'Students', 'monthly')
on conflict do nothing;

-- 12. App Settings
insert into app_settings (company_id, settings)
values ('00000000-0000-0000-0000-00000000c001', '{"brand":"SingapoDent","fiscal_year_start":"01-01","currency":"VND"}'::jsonb)
on conflict do nothing;

-- 13. User Roles (if auth users are set up)
-- These will be populated when auth users are created in Supabase
-- insert into user_roles (auth_user_id, company_id, role) values
--   ('<ceo-auth-id>', '00000000-0000-0000-0000-00000000c001', 'admin'),
--   ('<sales-manager-auth-id>', '00000000-0000-0000-0000-00000000c001', 'sales_manager');
