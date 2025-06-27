-- Insert default main categories (level 1)
INSERT INTO public.categories (id, user_id, name, icon, color, emoji, level, is_system) VALUES
  ('11111111-1111-1111-1111-111111111111', NULL, 'Ev', 'home', '#4CAF50', '🏠', 1, true),
  ('22222222-2222-2222-2222-222222222222', NULL, 'Yemek', 'restaurant', '#FF9800', '🍽️', 1, true),
  ('33333333-3333-3333-3333-333333333333', NULL, 'Ulaşım', 'directions_car', '#2196F3', '🚗', 1, true),
  ('44444444-4444-4444-4444-444444444444', NULL, 'Sağlık', 'local_hospital', '#F44336', '⚕️', 1, true),
  ('55555555-5555-5555-5555-555555555555', NULL, 'Kişisel', 'person', '#9C27B0', '👤', 1, true),
  ('66666666-6666-6666-6666-666666666666', NULL, 'Eğlence', 'sports_esports', '#00BCD4', '🎮', 1, true),
  ('77777777-7777-7777-7777-777777777777', NULL, 'Eğitim', 'school', '#795548', '📚', 1, true),
  ('88888888-8888-8888-8888-888888888888', NULL, 'Abonelikler', 'subscriptions', '#607D8B', '📱', 1, true),
  ('99999999-9999-9999-9999-999999999999', NULL, 'Diğer', 'more_horiz', '#9E9E9E', '📦', 1, true);

-- Insert default subcategories (level 2) for Home
INSERT INTO public.categories (id, user_id, parent_id, name, icon, color, emoji, level, is_system) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, '11111111-1111-1111-1111-111111111111', 'Kira', 'home', '#4CAF50', '🏠', 2, true),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NULL, '11111111-1111-1111-1111-111111111111', 'Faturalar', 'receipt', '#4CAF50', '💡', 2, true),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', NULL, '11111111-1111-1111-1111-111111111111', 'Bakım/Onarım', 'build', '#4CAF50', '🔧', 2, true),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', NULL, '11111111-1111-1111-1111-111111111111', 'Mobilya', 'weekend', '#4CAF50', '🛋️', 2, true);

-- Insert default subcategories (level 2) for Food
INSERT INTO public.categories (id, user_id, parent_id, name, icon, color, emoji, level, is_system) VALUES
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', NULL, '22222222-2222-2222-2222-222222222222', 'Market', 'shopping_cart', '#FF9800', '🛒', 2, true),
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', NULL, '22222222-2222-2222-2222-222222222222', 'Restoran', 'restaurant', '#FF9800', '🍕', 2, true),
  ('10101010-1010-1010-1010-101010101010', NULL, '22222222-2222-2222-2222-222222222222', 'Yemek Siparişi', 'delivery_dining', '#FF9800', '🍔', 2, true),
  ('20202020-2020-2020-2020-202020202020', NULL, '22222222-2222-2222-2222-222222222222', 'Kafe', 'local_cafe', '#FF9800', '☕', 2, true);

-- Insert default subcategories (level 2) for Transport
INSERT INTO public.categories (id, user_id, parent_id, name, icon, color, emoji, level, is_system) VALUES
  ('30303030-3030-3030-3030-303030303030', NULL, '33333333-3333-3333-3333-333333333333', 'Yakıt', 'local_gas_station', '#2196F3', '⛽', 2, true),
  ('40404040-4040-4040-4040-404040404040', NULL, '33333333-3333-3333-3333-333333333333', 'Toplu Taşıma', 'directions_bus', '#2196F3', '🚌', 2, true),
  ('50505050-5050-5050-5050-505050505050', NULL, '33333333-3333-3333-3333-333333333333', 'Taksi/Uber', 'local_taxi', '#2196F3', '🚕', 2, true),
  ('60606060-6060-6060-6060-606060606060', NULL, '33333333-3333-3333-3333-333333333333', 'Araç Bakım', 'car_repair', '#2196F3', '🔧', 2, true);

-- Insert some level 3 subcategories for utilities
INSERT INTO public.categories (id, user_id, parent_id, name, icon, color, emoji, level, is_system) VALUES
  ('70707070-7070-7070-7070-707070707070', NULL, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Elektrik', 'electric_bolt', '#4CAF50', '⚡', 3, true),
  ('80808080-8080-8080-8080-808080808080', NULL, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Su', 'water_drop', '#4CAF50', '💧', 3, true),
  ('90909090-9090-9090-9090-909090909090', NULL, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Doğalgaz', 'local_fire_department', '#4CAF50', '🔥', 3, true),
  ('a0a0a0a0-a0a0-a0a0-a0a0-a0a0a0a0a0a0', NULL, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'İnternet', 'wifi', '#4CAF50', '📶', 3, true),
  ('b0b0b0b0-b0b0-b0b0-b0b0-b0b0b0b0b0b0', NULL, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Telefon', 'phone', '#4CAF50', '📱', 3, true);

-- Create a function to copy system categories for new users
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
    
    -- Store mapping for parent reference
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
    
    -- Store mapping for level 3 parent reference
    parent_mapping := parent_mapping || jsonb_build_object(category_record.id::text, new_category_id::text);
  END LOOP;
  
  -- Copy level 3 categories
  FOR category_record IN 
    SELECT * FROM public.categories 
    WHERE is_system = true AND level = 3
    ORDER BY created_at
  LOOP
    INSERT INTO public.categories (
      user_id, parent_id, name, icon, color, emoji, level, is_system
    ) VALUES (
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

-- Create trigger to copy categories for new users
CREATE TRIGGER copy_categories_on_user_create
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION copy_system_categories_for_user();