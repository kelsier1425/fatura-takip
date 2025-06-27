-- DEBUG AUTH ISSUE
-- Bu sorguları sırayla çalıştırın

-- 1. Tabloların varlığını kontrol et
SELECT 
  'profiles' as table_name, 
  EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') as exists
UNION ALL
SELECT 
  'categories' as table_name, 
  EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'categories') as exists
UNION ALL
SELECT 
  'expenses' as table_name, 
  EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'expenses') as exists;

-- 2. RLS durumunu kontrol et
SELECT 
  schemaname, 
  tablename, 
  rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('profiles', 'categories', 'expenses');

-- 3. Sistem kategorilerini kontrol et
SELECT COUNT(*) as system_category_count 
FROM public.categories 
WHERE is_system = true;

-- 4. Mevcut trigger'ları kontrol et
SELECT 
  trigger_name,
  event_object_table,
  action_timing,
  action_orientation,
  action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
AND event_object_table = 'users';

-- 5. Test insert (manuel kullanıcı oluşturma)
-- NOT: Bu sadece test amaçlıdır, normalde auth.users'a direkt insert yapılmaz
/*
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES (
  gen_random_uuid(),
  'test_manual@example.com',
  '{"name": "Test Manual User"}'::jsonb
);
*/