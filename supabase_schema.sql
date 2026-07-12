-- LeafFlow Supabase Schema Initialization
-- Run this directly in the Supabase SQL Editor

-- 1. Create custom enum types
CREATE TYPE user_role AS ENUM ('manager', 'supervisor', 'clerk');
CREATE TYPE section_status AS ENUM ('Active', 'Resting', 'Pruning');
CREATE TYPE plan_status AS ENUM ('pending', 'active', 'completed');
CREATE TYPE dispatch_status AS ENUM ('Pending', 'In-Transit', 'Factory');

-- 2. Profiles Table (Extends auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  role user_role NOT NULL DEFAULT 'supervisor',
  full_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. Sections Table
CREATE TABLE public.sections (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  area_hectares DECIMAL(10, 2) NOT NULL,
  clone_type TEXT NOT NULL,
  plant_year INTEGER NOT NULL,
  current_status section_status NOT NULL DEFAULT 'Active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.sections ENABLE ROW LEVEL SECURITY;

-- 4. Workers Table
CREATE TABLE public.workers (
  pf_number TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  gang_id TEXT NOT NULL,
  phone_number TEXT,
  daily_quota_kg DECIMAL(5, 2) NOT NULL DEFAULT 20.0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.workers ENABLE ROW LEVEL SECURITY;

-- 5. Estate Plans (Formerly Tasks)
CREATE TABLE public.estate_plans (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  plan_date DATE NOT NULL,
  section_id UUID REFERENCES public.sections(id) ON DELETE CASCADE,
  supervisor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  target_kg DECIMAL(10, 2) NOT NULL,
  gang_ids TEXT[] NOT NULL DEFAULT '{}',
  status plan_status NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.estate_plans ENABLE ROW LEVEL SECURITY;

-- 6. Attendance (Hazira) Table
CREATE TABLE public.attendance (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  plan_id UUID REFERENCES public.estate_plans(id) ON DELETE CASCADE,
  worker_id TEXT REFERENCES public.workers(pf_number) ON DELETE CASCADE,
  record_date DATE NOT NULL,
  is_present BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(plan_id, worker_id, record_date) 
);

ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;

-- 7. Inspections Table
CREATE TABLE public.inspections (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  plan_id UUID REFERENCES public.estate_plans(id) ON DELETE CASCADE,
  gang_id TEXT NOT NULL,
  supervisor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  fine_leaf_percentage INTEGER NOT NULL CHECK (fine_leaf_percentage >= 0 AND fine_leaf_percentage <= 100),
  checked_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.inspections ENABLE ROW LEVEL SECURITY;

-- 8. Harvest Logs (Ticca/Weight) Table
CREATE TABLE public.harvest_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  worker_id TEXT REFERENCES public.workers(pf_number) ON DELETE CASCADE,
  section_id UUID REFERENCES public.sections(id) ON DELETE SET NULL,
  gang_id TEXT,
  supervisor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  harvest_date DATE NOT NULL,
  weight_kg DECIMAL(8, 2) NOT NULL,
  leaf_quality TEXT DEFAULT 'Fine', 
  clerk_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.harvest_logs ENABLE ROW LEVEL SECURITY;

-- 9. Dispatch Logs
CREATE TABLE public.dispatch_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  plan_id UUID REFERENCES public.estate_plans(id) ON DELETE CASCADE,
  vehicle_number TEXT NOT NULL,
  driver_name TEXT NOT NULL,
  total_weight_kg DECIMAL(10, 2) NOT NULL,
  status dispatch_status NOT NULL DEFAULT 'Pending',
  dispatch_time TIMESTAMP WITH TIME ZONE,
  clerk_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.dispatch_logs ENABLE ROW LEVEL SECURITY;

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

-- (Basic RLS policies - allowing authenticated users to read, limiting writes to specific roles)

CREATE POLICY "Authenticated users can read profiles" ON public.profiles FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Trigger can insert profiles" ON public.profiles FOR INSERT WITH CHECK (true);

CREATE POLICY "Authenticated users can read sections" ON public.sections FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can read workers" ON public.workers FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Managers can insert workers" ON public.workers FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'manager'));
CREATE POLICY "Managers can update workers" ON public.workers FOR UPDATE USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'manager'));

CREATE POLICY "Authenticated users can read estate plans" ON public.estate_plans FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Managers have full access to estate plans" ON public.estate_plans FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'manager'));
CREATE POLICY "Supervisors can update own plans" ON public.estate_plans FOR UPDATE USING (auth.uid() = supervisor_id);

CREATE POLICY "Supervisors can insert attendance" ON public.attendance FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.estate_plans WHERE id = plan_id AND supervisor_id = auth.uid()));
CREATE POLICY "Anyone can read attendance" ON public.attendance FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Supervisors can insert inspections" ON public.inspections FOR INSERT WITH CHECK (auth.uid() = supervisor_id);
CREATE POLICY "Anyone can read inspections" ON public.inspections FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Clerks can insert harvest logs" ON public.harvest_logs FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'clerk'));
CREATE POLICY "Anyone can read harvest logs" ON public.harvest_logs FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Clerks can insert dispatch logs" ON public.dispatch_logs FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'clerk'));
CREATE POLICY "Anyone can read dispatch logs" ON public.dispatch_logs FOR SELECT USING (auth.role() = 'authenticated');

-- ==========================================
-- AUTH TRIGGERS
-- ==========================================

-- Trigger to automatically create a profile for new users
create or replace function public.handle_new_user() 
returns trigger as $$
begin
  insert into public.profiles (id, full_name, role)
  values (
    new.id, 
    COALESCE(new.raw_user_meta_data->>'full_name', 'Unknown User'), 
    COALESCE((new.raw_user_meta_data->>'role')::public.user_role, 'supervisor'::public.user_role)
  );
  return new;
end;
$$ language plpgsql security definer;

-- Drop trigger if exists to prevent errors on re-run
drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
