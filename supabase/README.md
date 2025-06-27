# Supabase Backend Kurulum Rehberi

## 1. Supabase Projesi Oluşturma

1. [Supabase Dashboard](https://app.supabase.com)'a gidin
2. "New Project" butonuna tıklayın
3. Proje bilgilerini girin:
   - Project name: `fatura-takip`
   - Database Password: Güçlü bir şifre belirleyin
   - Region: `Frankfurt (eu-central-1)` (Türkiye'ye en yakın)
   - Pricing Plan: Free tier ile başlayabilirsiniz

## 2. Database Schema Kurulumu

Proje oluşturulduktan sonra:

1. Sol menüden "SQL Editor" sekmesine gidin
2. Sırasıyla şu SQL dosyalarını çalıştırın:
   - `migrations/001_initial_schema.sql`
   - `migrations/002_row_level_security.sql`
   - `migrations/003_default_categories.sql`

## 3. Authentication Ayarları

1. Sol menüden "Authentication" > "Providers" sekmesine gidin
2. Email provider'ı aktifleştirin:
   - Enable Email provider: ✓
   - Confirm email: ✓ (önerilir)
   - Secure email change: ✓
   - Secure password change: ✓

## 4. Flutter Uygulamasına Bağlama

1. "Settings" > "API" sekmesinden şu bilgileri alın:
   - Project URL (örn: `https://xxxxx.supabase.co`)
   - anon/public key

2. `lib/config/supabase/supabase_config.dart` dosyasını güncelleyin:
```dart
static const String supabaseUrl = 'YOUR_PROJECT_URL';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

## 5. Storage Bucket Oluşturma (Opsiyonel)

Fatura fotoğrafları için:

1. "Storage" sekmesine gidin
2. "New bucket" tıklayın:
   - Name: `receipts`
   - Public bucket: Hayır (güvenlik için)
   - File size limit: 5MB
   - Allowed MIME types: `image/*,application/pdf`

## 6. Edge Functions (İleri Seviye - Opsiyonel)

Otomatik tekrarlayan harcamalar için:

1. Supabase CLI kurulumu yapın
2. `supabase/functions` klasöründe edge function'lar oluşturun
3. Cron job'lar ile otomatik tetikleme ayarlayın

## 7. Güvenlik Kontrol Listesi

- [ ] Row Level Security (RLS) tüm tablolarda aktif
- [ ] API anahtarları güvenli şekilde saklanıyor
- [ ] Email doğrulama aktif
- [ ] Rate limiting ayarları yapıldı (Settings > Auth)
- [ ] Allowed redirect URLs ayarlandı (mobil için)

## 8. Test Kullanıcısı Oluşturma

SQL Editor'de:
```sql
-- Test user will be created through Flutter app
-- Categories will be automatically copied via trigger
```

## Notlar

- Free tier limitleri:
  - 500MB database
  - 1GB storage
  - 50,000 auth kullanıcı/ay
  - 2GB bandwidth/ay

- Production için öneriler:
  - Database backup'larını düzenli alın
  - Point-in-time recovery'yi aktifleştirin (Pro plan)
  - Custom domain ekleyin
  - Analytics dashboard'u kurun