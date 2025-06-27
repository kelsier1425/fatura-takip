-- SUPABASE QUICK SETUP
-- Copy and paste this entire file into Supabase SQL Editor

-- 1. Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Users profile table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Categories table (3-level hierarchy)
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES public.categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  icon TEXT,
  color TEXT,
  emoji TEXT,
  level INTEGER NOT NULL CHECK (level IN (1, 2, 3)),
  is_system BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Expenses table
CREATE TABLE IF NOT EXISTS public.expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES public.categories(id),
  title TEXT NOT NULL,
  description TEXT,
  amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
  date DATE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('bill', 'subscription', 'one_time', 'recurring')),
  is_paid BOOLEAN DEFAULT FALSE,
  receipt_url TEXT,
  notes TEXT,
  is_recurring BOOLEAN DEFAULT FALSE,
  recurrence_type TEXT CHECK (recurrence_type IN ('none', 'daily', 'weekly', 'monthly', 'yearly')),
  recurrence_interval INTEGER,
  recurrence_end_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

-- 6. Create RLS Policies for Profiles
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 7. Create RLS Policies for Categories
CREATE POLICY "Users can view own and system categories" ON public.categories
  FOR SELECT USING (auth.uid() = user_id OR is_system = true);

CREATE POLICY "Users can insert own categories" ON public.categories
  FOR INSERT WITH CHECK (auth.uid() = user_id AND is_system = false);

CREATE POLICY "Users can update own categories" ON public.categories
  FOR UPDATE USING (auth.uid() = user_id AND is_system = false);

CREATE POLICY "Users can delete own categories" ON public.categories
  FOR DELETE USING (auth.uid() = user_id AND is_system = false);

-- 8. Create RLS Policies for Expenses
CREATE POLICY "Users can view own expenses" ON public.expenses
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own expenses" ON public.expenses
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own expenses" ON public.expenses
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own expenses" ON public.expenses
  FOR DELETE USING (auth.uid() = user_id);

-- 9. Insert default categories
INSERT INTO public.categories (id, user_id, name, icon, color, emoji, level, is_system) VALUES
  ('11111111-1111-1111-1111-111111111111', NULL, 'Ev', 'home', '#4CAF50', '🏠', 1, true),
  ('22222222-2222-2222-2222-222222222222', NULL, 'Yemek', 'restaurant', '#FF9800', '🍽️', 1, true),
  ('33333333-3333-3333-3333-333333333333', NULL, 'Ulaşım', 'directions_car', '#2196F3', '🚗', 1, true),
  ('44444444-4444-4444-4444-444444444444', NULL, 'Sağlık', 'local_hospital', '#F44336', '⚕️', 1, true),
  ('55555555-5555-5555-5555-555555555555', NULL, 'Kişisel', 'person', '#9C27B0', '👤', 1, true),
  ('99999999-9999-9999-9999-999999999999', NULL, 'Diğer', 'more_horiz', '#9E9E9E', '📦', 1, true);

-- 10. Insert subcategories
INSERT INTO public.categories (id, user_id, parent_id, name, icon, color, emoji, level, is_system) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, '11111111-1111-1111-1111-111111111111', 'Kira', 'home', '#4CAF50', '🏠', 2, true),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NULL, '11111111-1111-1111-1111-111111111111', 'Faturalar', 'receipt', '#4CAF50', '💡', 2, true),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', NULL, '22222222-2222-2222-2222-222222222222', 'Market', 'shopping_cart', '#FF9800', '🛒', 2, true),
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', NULL, '22222222-2222-2222-2222-222222222222', 'Restoran', 'restaurant', '#FF9800', '🍕', 2, true);

-- 11. Create function to copy system categories for new users
CREATE OR REPLACE FUNCTION copy_system_categories_for_user()
RETURNS TRIGGER AS $$
DECLARE
  category_record RECORD;
  new_category_id UUID;
  parent_mapping JSONB DEFAULT '{}';
BEGIN
  -- Copy level 1 categories
  FOR category_record IN 
    SELECT * FROM public.categories 
    WHERE is_system = true AND level = 1
    ORDER BY created_at
  LOOP
    new_category_id := uuid_generate_v4();
    
    INSERT INTO public.categories (
      id, user_id, parent_id, name, icon, color, emoji, level, is_system
    ) VALUES (
      new_category_id,
      NEW.id,
      NULL,
      category_record.name,
      category_record.icon,
      category_record.color,
      category_record.emoji,
      category_record.level,
      false
    );
    
    parent_mapping := parent_mapping || jsonb_build_object(category_record.id::text, new_category_id::text);
  END LOOP;
  
  -- Copy level 2 categories
  FOR category_record IN 
    SELECT * FROM public.categories 
    WHERE is_system = true AND level = 2
    ORDER BY created_at
  LOOP
    new_category_id := uuid_generate_v4();
    
    INSERT INTO public.categories (
      id, user_id, parent_id, name, icon, color, emoji, level, is_system
    ) VALUES (
      new_category_id,
      NEW.id,
      (parent_mapping->>(category_record.parent_id::text))::UUID,
      category_record.name,
      category_record.icon,
      category_record.color,
      category_record.emoji,
      category_record.level,
      false
    );
    
    parent_mapping := parent_mapping || jsonb_build_object(category_record.id::text, new_category_id::text);
  END LOOP;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 12. Create trigger to copy categories for new users
CREATE TRIGGER copy_categories_on_user_create
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION copy_system_categories_for_user();