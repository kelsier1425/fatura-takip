import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  final List<({IconData icon, String label, String route})> _menuItems = [
    (icon: Icons.dashboard_outlined, label: 'Özet', route: '/home'),
    (icon: Icons.receipt_long_outlined, label: 'Harcamalar', route: '/expenses'),
    (icon: Icons.category_outlined, label: 'Kategoriler', route: '/categories'),
    (icon: Icons.person_outline, label: 'Profil', route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isAuthenticated = authState.status == AuthStatus.authenticated;
    final isGuest = authState.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fatura Takip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bildirimler yakında gelecek!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hoş Geldiniz! 👋',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAuthenticated && currentUser != null 
                              ? currentUser.name
                              : 'Misafir Kullanıcı',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!isAuthenticated || isGuest)
                          ElevatedButton(
                            onPressed: () => context.go('/login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                            ),
                            child: const Text('Giriş Yap'),
                          )
                        else
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => context.push('/expense/add'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                ),
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('Harcama Ekle'),
                              ),
                              const SizedBox(width: 8),
                              if (currentUser?.isPremium != true)
                                TextButton(
                                  onPressed: () => context.go('/subscription'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Premium\'a Geç'),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Text(
              'Bu Ay',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme: theme,
                    title: 'Toplam Harcama',
                    value: '₺12,450',
                    subtitle: 'Bütçe: ₺15,000',
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.primary,
                    progress: 0.83,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme: theme,
                    title: 'Fatura Sayısı',
                    value: '28',
                    subtitle: '+5 bu hafta',
                    icon: Icons.receipt_outlined,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme: theme,
                    title: 'Tasarruf',
                    value: '₺2,550',
                    subtitle: 'Hedef: ₺3,000',
                    icon: Icons.savings_outlined,
                    color: AppColors.success,
                    progress: 0.85,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme: theme,
                    title: 'Ortalama/Gün',
                    value: '₺415',
                    subtitle: 'Son 30 gün',
                    icon: Icons.trending_up,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Mini Chart
            Text(
              'Son 7 Gün Trendi',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMiniChart(theme),
            const SizedBox(height: 24),

            // Menu Grid
            Text(
              'Hızlı Erişim',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              children: [
                _buildMenuCard(
                  theme: theme,
                  icon: Icons.add_circle_outline,
                  label: 'Harcama Ekle',
                  onTap: () => context.push('/expense/add'),
                  color: AppColors.primary,
                ),
                _buildMenuCard(
                  theme: theme,
                  icon: Icons.receipt_long_outlined,
                  label: 'Harcamalar',
                  onTap: () => context.go('/expenses'),
                  color: AppColors.secondary,
                ),
                _buildMenuCard(
                  theme: theme,
                  icon: Icons.analytics_outlined,
                  label: 'Analizler',
                  onTap: () => context.go('/analytics'),
                  color: AppColors.info,
                ),
                _buildMenuCard(
                  theme: theme,
                  icon: Icons.bar_chart,
                  label: 'Grafikler',
                  onTap: () => context.go('/visualization'),
                  color: AppColors.success,
                ),
                _buildMenuCard(
                  theme: theme,
                  icon: Icons.category_outlined,
                  label: 'Kategoriler',
                  onTap: () => context.go('/categories'),
                  color: AppColors.accent,
                ),
                _buildMenuCard(
                  theme: theme,
                  icon: Icons.autorenew,
                  label: 'Otomasyon',
                  onTap: () => context.go('/automation'),
                  color: AppColors.warning,
                ),
                _buildMenuCard(
                  theme: theme,
                  icon: Icons.account_balance_wallet,
                  label: 'Bütçe',
                  onTap: () => context.go('/budget'),
                  color: AppColors.accent,
                ),
                _buildMenuCard(
                  theme: theme,
                  icon: Icons.savings_outlined,
                  label: 'Tasarruf',
                  onTap: () => context.go('/savings'),
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          context.go(_menuItems[index].route);
        },
        items: _menuItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              if (progress != null)
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.grey.shade300,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: color,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniChart(ThemeData theme) {
    final weeklyData = [420.0, 380.0, 520.0, 310.0, 590.0, 450.0, 415.0];
    final maxValue = weeklyData.reduce((a, b) => a > b ? a : b);
    
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weeklyData.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          final height = (value / maxValue) * 40;
          final isToday = index == 6; // Son gün bugün
          
          return Container(
            width: 8,
            height: height,
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : AppColors.primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuCard({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color ?? AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}