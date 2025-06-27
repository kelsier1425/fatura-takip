-- SUPABASE REMAINING SETUP
-- Only run the parts that are missing

-- 1. Check if default categories exist, if not insert them
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.categories WHERE is_system = true LIMIT 1) THEN
    -- Insert default categories
    INSERT INTO public.categories (id, user_id, name, icon, color, emoji, level, is_system) VALUES
      ('11111111-1111-1111-1111-111111111111', NULL, 'Ev', 'home', '#4CAF50', '🏠', 1, true),
      ('22222222-2222-2222-2222-222222222222', NULL, 'Yemek', 'restaurant', '#FF9800', '🍽️', 1, true),
      ('33333333-3333-3333-3333-333333333333', NULL, 'Ulaşım', 'directions_car', '#2196F3', '🚗', 1, true),
      ('44444444-4444-4444-4444-444444444444', NULL, 'Sağlık', 'local_hospital', '#F44336', '⚕️', 1, true),
      ('55555555-5555-5555-5555-555555555555', NULL, 'Kişisel', 'person', '#9C27B0', '👤', 1, true),
      ('99999999-9999-9999-9999-999999999999', NULL, 'Diğer', 'more_horiz', '#9E9E9E', '📦', 1, true);

    -- Insert subcategories
    INSERT INTO public.categories (id, user_id, parent_id, name, icon, color, emoji, level, is_system) VALUES
      ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, '11111111-1111-1111-1111-111111111111', 'Kira', 'home', '#4CAF50', '🏠', 2, true),
      ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NULL, '11111111-1111-1111-1111-111111111111', 'Faturalar', 'receipt', '#4CAF50', '💡', 2, true),
      ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', NULL, '22222222-2222-2222-2222-222222222222', 'Market', 'shopping_cart', '#FF9800', '🛒', 2, true),
      ('ffffffff-ffff-ffff-ffff-ffffffffffff', NULL, '22222222-2222-2222-2222-222222222222', 'Restoran', 'restaurant', '#FF9800', '🍕', 2, true);
  END IF;
END $$;

-- 2. Create function to copy system categories for new users (replace if exists)
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
  END LOOP;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Create trigger (drop first if exists)
DROP TRIGGER IF EXISTS copy_categories_on_user_create ON auth.users;
CREATE TRIGGER copy_categories_on_user_create
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION copy_system_categories_for_user();

-- 4. Test query to check setup
SELECT 
  'Setup Complete!' as status,
  (SELECT COUNT(*) FROM public.categories WHERE is_system = true) as system_categories_count,
  (SELECT EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'copy_categories_on_user_create')) as trigger_exists;