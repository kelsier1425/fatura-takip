import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/providers/theme_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_tile.dart';
import '../widgets/premium_banner.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const ProfileHeader(
              name: 'Betül Karaca',
              email: 'betul@example.com',
              isPremium: false,
              photoUrl: null,
            ),
            const SizedBox(height: 16),
            
            // Premium Banner
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: PremiumBanner(),
            ),
            const SizedBox(height: 24),
            
            // Preferences Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Tercihler',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.child_care_outlined,
                    title: 'Çocuğum var',
                    subtitle: 'Çocuk giderleri kategorisi aktif',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.pets_outlined,
                    title: 'Evcil hayvanım var',
                    subtitle: 'Evcil hayvan giderleri kategorisi aktif',
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {},
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.currency_lira_outlined,
                    title: 'Para Birimi',
                    subtitle: 'Türk Lirası',
                    onTap: () => _showCurrencyDialog(),
                  ),
                  SettingsTile(
                    icon: Icons.language_outlined,
                    title: 'Dil',
                    subtitle: 'Türkçe',
                    onTap: () => _showLanguageDialog(),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 100.ms)
            .slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 16),
            
            // Notifications Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Bildirimler',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Bildirimler',
                    subtitle: 'Uygulama bildirimleri açık',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.alarm_outlined,
                    title: 'Ödeme hatırlatıcıları',
                    subtitle: '3 gün önceden hatırlat',
                    onTap: () => _showReminderDialog(),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 16),
            
            // App Settings Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Uygulama',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.diamond_outlined,
                    title: 'Premium Üyelik',
                    subtitle: 'Özellikler ve fiyatlar',
                    onTap: () => context.push('/subscription'),
                  ),
                  SettingsTile(
                    icon: themeState.themeIcon,
                    title: 'Tema',
                    subtitle: themeState.themeDisplayName,
                    onTap: () => _showThemeDialog(),
                  ),
                  SettingsTile(
                    icon: Icons.security_outlined,
                    title: 'Gizlilik ve Güvenlik',
                    onTap: () => context.push('/privacy'),
                  ),
                  SettingsTile(
                    icon: Icons.help_outline,
                    title: 'Yardım ve Destek',
                    onTap: () => context.push('/help'),
                  ),
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: 'Hakkında',
                    subtitle: 'Versiyon 1.0.0',
                    onTap: () => _showAboutDialog(),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 300.ms)
            .slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 24),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedButton(
                onPressed: () => _showLogoutDialog(),
                backgroundColor: AppColors.error,
                width: double.infinity,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Çıkış Yap'),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Para Birimi Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Türk Lirası (₺)'),
              value: 'TRY',
              groupValue: 'TRY',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('Amerikan Doları (\$)'),
              value: 'USD',
              groupValue: 'TRY',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('Euro (€)'),
              value: 'EUR',
              groupValue: 'TRY',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Türkçe'),
              value: 'tr',
              groupValue: 'tr',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('English'),
              value: 'en',
              groupValue: 'tr',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hatırlatma Zamanı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Aynı gün'),
              value: 0,
              groupValue: 3,
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('1 gün önce'),
              value: 1,
              groupValue: 3,
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('3 gün önce'),
              value: 3,
              groupValue: 3,
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('7 gün önce'),
              value: 7,
              groupValue: 3,
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const FlutterLogo(size: 48),
      children: [
        const Text('Fatura Takip, tüm faturalarınızı ve aboneliklerinizi tek yerden yönetmenizi sağlayan akıllı bir uygulamadır.'),
      ],
    );
  }
  
  void _showThemeDialog() {
    final currentTheme = ref.read(themeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.palette_outlined),
            SizedBox(width: 8),
            Text('Tema Seç'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(ThemeState(themeMode: mode, isSystemDark: false).themeDisplayName),
              subtitle: Text(_getThemeDescription(mode)),
              value: mode,
              groupValue: currentTheme.themeMode,
              secondary: Icon(ThemeState(themeMode: mode, isSystemDark: false).themeIcon),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }
  
  String _getThemeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Her zaman açık tema';
      case AppThemeMode.dark:
        return 'Her zaman koyu tema';
      case AppThemeMode.system:
        return 'Sistem ayarını takip et';
    }
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}