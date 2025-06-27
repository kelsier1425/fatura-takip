-- FIX AUTH TRIGGER
-- Bu kodu Supabase SQL Editor'de çalıştırın

-- 1. Önce mevcut trigger'ı kaldır
DROP TRIGGER IF EXISTS copy_categories_on_user_create ON auth.users;
DROP FUNCTION IF EXISTS copy_system_categories_for_user();

-- 2. Profiles tablosuna otomatik insert için trigger oluştur
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  category_record RECORD;
  new_category_id UUID;
  parent_mapping JSONB DEFAULT '{}';
BEGIN
  -- Create profile for new user
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'name');
  
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
  END LOOP;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't fail user creation
    RAISE WARNING 'Error in handle_new_user: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Yeni trigger oluştur
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Test query
SELECT 
  EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'on_auth_user_created') as trigger_exists,
  COUNT(*) as system_categories_count
FROM public.categories 
WHERE is_system = true;