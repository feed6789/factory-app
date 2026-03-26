-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.assets (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  qr_code character varying UNIQUE,
  name character varying NOT NULL,
  department_id uuid,
  status character varying DEFAULT 'active'::character varying,
  CONSTRAINT assets_pkey PRIMARY KEY (id),
  CONSTRAINT assets_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id)
);
CREATE TABLE public.attendance_logs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  log_type USER-DEFINED NOT NULL,
  log_time timestamp with time zone DEFAULT now(),
  method character varying,
  location_data jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT attendance_logs_pkey PRIMARY KEY (id),
  CONSTRAINT attendance_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.compressed_air_readings (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  pressure_value numeric,
  flow_rate_value numeric,
  recorded_by uuid,
  recorded_at date NOT NULL UNIQUE,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT compressed_air_readings_pkey PRIMARY KEY (id),
  CONSTRAINT compressed_air_readings_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.profiles(id)
);
CREATE TABLE public.daily_timesheets (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  date date NOT NULL,
  shift_type character varying DEFAULT 'Ca Ngày'::character varying,
  status character varying DEFAULT 'Có mặt'::character varying,
  overtime_start time without time zone,
  overtime_end time without time zone,
  notes text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT daily_timesheets_pkey PRIMARY KEY (id),
  CONSTRAINT daily_timesheets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.departments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  division_id uuid,
  CONSTRAINT departments_pkey PRIMARY KEY (id),
  CONSTRAINT departments_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id)
);
CREATE TABLE public.divisions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT divisions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.electrical_cabinets (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  location text,
  department_id uuid,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT electrical_cabinets_pkey PRIMARY KEY (id),
  CONSTRAINT electrical_cabinets_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id)
);
CREATE TABLE public.electricity_readings (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  cabinet_id uuid NOT NULL,
  reading_value numeric NOT NULL,
  recorded_by uuid,
  recorded_at date NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT electricity_readings_pkey PRIMARY KEY (id),
  CONSTRAINT electricity_readings_cabinet_id_fkey FOREIGN KEY (cabinet_id) REFERENCES public.electrical_cabinets(id),
  CONSTRAINT electricity_readings_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.profiles(id)
);
CREATE TABLE public.employee_feedbacks (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  feedback_type character varying NOT NULL,
  content text NOT NULL,
  status character varying DEFAULT 'pending'::character varying,
  created_at timestamp with time zone DEFAULT now(),
  is_anonymous boolean DEFAULT false,
  CONSTRAINT employee_feedbacks_pkey PRIMARY KEY (id),
  CONSTRAINT employee_feedbacks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.factory_machines (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  description text,
  CONSTRAINT factory_machines_pkey PRIMARY KEY (id)
);
CREATE TABLE public.factory_materials (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  category character varying NOT NULL,
  name character varying NOT NULL,
  unit character varying NOT NULL,
  initial_qty numeric DEFAULT 0,
  total_import numeric DEFAULT 0,
  total_export numeric DEFAULT 0,
  current_qty numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  department_id uuid,
  CONSTRAINT factory_materials_pkey PRIMARY KEY (id),
  CONSTRAINT factory_materials_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id)
);
CREATE TABLE public.internal_communications (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  author_id uuid NOT NULL,
  title character varying NOT NULL,
  content text,
  comm_type character varying,
  target_roles jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT internal_communications_pkey PRIMARY KEY (id),
  CONSTRAINT internal_communications_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.inventory_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  qr_code character varying NOT NULL UNIQUE,
  name character varying NOT NULL,
  min_stock_level integer DEFAULT 0,
  current_stock integer DEFAULT 0,
  unit character varying,
  CONSTRAINT inventory_items_pkey PRIMARY KEY (id)
);
CREATE TABLE public.leave_requests (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  leave_type character varying NOT NULL,
  start_time timestamp with time zone NOT NULL,
  end_time timestamp with time zone NOT NULL,
  reason text,
  current_approver_id uuid,
  approval_history jsonb DEFAULT '[]'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  status USER-DEFINED DEFAULT 'pending_leader'::approval_status,
  place_of_leave text,
  CONSTRAINT leave_requests_pkey PRIMARY KEY (id),
  CONSTRAINT leave_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT leave_requests_current_approver_id_fkey FOREIGN KEY (current_approver_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.maintenance_logs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  asset_id uuid NOT NULL,
  technician_id uuid NOT NULL,
  maintenance_type character varying,
  details text,
  cost numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT maintenance_logs_pkey PRIMARY KEY (id),
  CONSTRAINT maintenance_logs_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id),
  CONSTRAINT maintenance_logs_technician_id_fkey FOREIGN KEY (technician_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.material_catalogs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  origin character varying,
  unit character varying NOT NULL,
  is_active boolean DEFAULT true,
  department_id uuid,
  CONSTRAINT material_catalogs_pkey PRIMARY KEY (id),
  CONSTRAINT material_catalogs_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id)
);
CREATE TABLE public.material_requests (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  requester_id uuid NOT NULL,
  items jsonb NOT NULL,
  status USER-DEFINED DEFAULT 'pending_leader'::approval_status,
  budget_approved boolean DEFAULT false,
  approval_history jsonb DEFAULT '[]'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  request_number character varying,
  manager_notes text,
  department_id uuid,
  CONSTRAINT material_requests_pkey PRIMARY KEY (id),
  CONSTRAINT material_requests_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.profiles(id),
  CONSTRAINT material_requests_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id)
);
CREATE TABLE public.material_transactions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  material_id uuid,
  trans_type character varying NOT NULL,
  quantity numeric NOT NULL,
  trans_date date NOT NULL,
  machine_id uuid,
  notes text,
  recorded_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT material_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT material_transactions_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.factory_materials(id),
  CONSTRAINT material_transactions_machine_id_fkey FOREIGN KEY (machine_id) REFERENCES public.factory_machines(id),
  CONSTRAINT material_transactions_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.profiles(id)
);
CREATE TABLE public.monthly_evaluations (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  manager_id uuid,
  month_year character varying NOT NULL,
  skill_rating character varying NOT NULL,
  attitude_rating character varying NOT NULL,
  working_days numeric DEFAULT 0,
  leave_days numeric DEFAULT 0,
  unpaid_leave_days numeric DEFAULT 0,
  unexcused_days numeric DEFAULT 0,
  violations text NOT NULL,
  monthly_grade character varying NOT NULL,
  proposed_action text NOT NULL,
  status character varying DEFAULT 'draft'::character varying,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT monthly_evaluations_pkey PRIMARY KEY (id),
  CONSTRAINT monthly_evaluations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT monthly_evaluations_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.payslips (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  month integer NOT NULL,
  year integer NOT NULL,
  salary_data jsonb NOT NULL,
  is_viewed boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT payslips_pkey PRIMARY KEY (id),
  CONSTRAINT payslips_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.production_logs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  shift_date date NOT NULL DEFAULT CURRENT_DATE,
  product_code character varying NOT NULL,
  quantity_ok integer DEFAULT 0,
  quantity_ng integer DEFAULT 0,
  electricity_kwh numeric,
  oee_metrics jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT production_logs_pkey PRIMARY KEY (id),
  CONSTRAINT production_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  employee_code character varying NOT NULL UNIQUE,
  full_name character varying NOT NULL,
  role text DEFAULT 'worker'::character varying,
  department_id uuid,
  manager_id uuid,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  email text,
  phone_number text,
  division_id uuid,
  can_manage_inventory boolean DEFAULT false,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id),
  CONSTRAINT profiles_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id),
  CONSTRAINT profiles_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.profiles(id),
  CONSTRAINT profiles_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id),
  CONSTRAINT profiles_role_fkey FOREIGN KEY (role) REFERENCES public.roles(code)
);
CREATE TABLE public.quality_issues (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  reporter_id uuid NOT NULL,
  machine_code character varying,
  issue_type character varying,
  downtime_minutes integer DEFAULT 0,
  images jsonb DEFAULT '[]'::jsonb,
  root_cause text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT quality_issues_pkey PRIMARY KEY (id),
  CONSTRAINT quality_issues_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.role_hierarchy (
  role text NOT NULL,
  managed_by_role text NOT NULL,
  CONSTRAINT role_hierarchy_role_fkey FOREIGN KEY (role) REFERENCES public.roles(code),
  CONSTRAINT role_hierarchy_managed_by_role_fkey FOREIGN KEY (managed_by_role) REFERENCES public.roles(code)
);
CREATE TABLE public.role_permissions (
  role text NOT NULL,
  allowed_features jsonb NOT NULL DEFAULT '[]'::jsonb,
  CONSTRAINT role_permissions_pkey PRIMARY KEY (role)
);
CREATE TABLE public.roles (
  code character varying NOT NULL,
  name character varying NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT roles_pkey PRIMARY KEY (code)
);
CREATE TABLE public.tasks (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  assigner_id uuid NOT NULL,
  assignee_id uuid,
  team_id uuid,
  title character varying NOT NULL,
  description text,
  deadline timestamp with time zone,
  status USER-DEFINED DEFAULT 'todo'::task_status,
  progress_images jsonb DEFAULT '[]'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tasks_pkey PRIMARY KEY (id),
  CONSTRAINT tasks_assigner_id_fkey FOREIGN KEY (assigner_id) REFERENCES public.profiles(id),
  CONSTRAINT tasks_assignee_id_fkey FOREIGN KEY (assignee_id) REFERENCES public.profiles(id),
  CONSTRAINT tasks_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.departments(id)
);
CREATE TABLE public.tool_borrow_logs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  item_id uuid NOT NULL,
  borrowed_at timestamp with time zone DEFAULT now(),
  expected_return timestamp with time zone,
  returned_at timestamp with time zone,
  status character varying DEFAULT 'borrowed'::character varying,
  CONSTRAINT tool_borrow_logs_pkey PRIMARY KEY (id),
  CONSTRAINT tool_borrow_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT tool_borrow_logs_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id)
);