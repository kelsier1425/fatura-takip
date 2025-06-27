import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../widgets/premium_features_card.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/current_plan_status.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  bool _isLoading = false;
  bool _isAnnual = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    setState(() => _isLoading = true);
    // TODO: Load subscription data
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Premium Üyelik'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                _showHelpDialog();
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadSubscriptionData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CurrentPlanStatus(
                  isActive: false, // TODO: Get from provider
                  planName: 'Ücretsiz',
                  expiryDate: null,
                ).animate().fadeIn(),
                const SizedBox(height: 24),
                PremiumFeaturesCard().animate().slideY(
                  begin: 0.1,
                  duration: 300.ms,
                  delay: 100.ms,
                ),
                const SizedBox(height: 24),
                _buildPlanToggle().animate().slideY(
                  begin: 0.1,
                  duration: 300.ms,
                  delay: 200.ms,
                ),
                const SizedBox(height: 16),
                _buildSubscriptionPlans(),
                const SizedBox(height: 24),
                _buildFeaturesComparison().animate().slideY(
                  begin: 0.1,
                  duration: 300.ms,
                  delay: 400.ms,
                ),
                const SizedBox(height: 24),
                _buildFAQ().animate().slideY(
                  begin: 0.1,
                  duration: 300.ms,
                  delay: 500.ms,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAnnual = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isAnnual ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !_isAnnual
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Aylık',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: !_isAnnual ? FontWeight.w600 : FontWeight.normal,
                    color: !_isAnnual ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAnnual = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isAnnual ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _isAnnual
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Yıllık',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: _isAnnual ? FontWeight.w600 : FontWeight.normal,
                        color: _isAnnual ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    if (_isAnnual) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '%20 İndirim',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans() {
    return Column(
      children: [
        SubscriptionPlanCard(
          title: 'Premium',
          subtitle: 'Tam özellikli deneyim',
          monthlyPrice: 49.99,
          annualPrice: 479.99,
          isAnnual: _isAnnual,
          isPremium: true,
          features: [
            'Sınırsız gider kategorisi',
            'Gelişmiş raporlar ve analizler',
            'Bütçe hedefleri ve uyarılar',
            'Veri yedekleme ve senkronizasyon',
            'Premium müşteri desteği',
            'Reklamsız deneyim',
          ],
          isPopular: true,
          onSubscribe: () => _handleSubscription('premium'),
        ).animate().slideX(
          begin: 0.1,
          duration: 300.ms,
          delay: 300.ms,
        ),
        const SizedBox(height: 16),
        SubscriptionPlanCard(
          title: 'Temel',
          subtitle: 'Basit gider takibi',
          monthlyPrice: 19.99,
          annualPrice: 191.99,
          isAnnual: _isAnnual,
          isPremium: false,
          features: [
            '10 gider kategorisi',
            'Temel raporlar',
            'Aylık bütçe takibi',
            'Veri yedeği (sadece yerel)',
          ],
          onSubscribe: () => _handleSubscription('basic'),
        ).animate().slideX(
          begin: 0.1,
          duration: 300.ms,
          delay: 350.ms,
        ),
      ],
    );
  }

  Widget _buildFeaturesComparison() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Özellik Karşılaştırması',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildFeatureRow('Gider kategorisi sayısı', 'Sınırlı', 'Sınırsız', 'Sınırsız'),
            _buildFeatureRow('Gelişmiş raporlar', '❌', '✅', '✅'),
            _buildFeatureRow('Bütçe hedefleri', '❌', '✅', '✅'),
            _buildFeatureRow('Veri senkronizasyonu', '❌', '❌', '✅'),
            _buildFeatureRow('Premium destek', '❌', '❌', '✅'),
            _buildFeatureRow('Reklamsız', '❌', '❌', '✅'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, String free, String basic, String premium) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              basic,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              premium,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sık Sorulan Sorular',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              'Üyeliğimi nasıl iptal edebilirim?',
              'Profil sayfasından "Abonelik Yönetimi" bölümüne giderek üyeliğinizi istediğiniz zaman iptal edebilirsiniz.',
            ),
            _buildFAQItem(
              'Para iadesi alabilir miyim?',
              'İlk 7 gün içerisinde herhangi bir sebep göstermeden tam para iadesi alabilirsiniz.',
            ),
            _buildFAQItem(
              'Verilerim güvende mi?',
              'Tüm verileriniz şifrelenerek saklanır ve sadece sizin erişebileceğiniz şekilde korunur.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubscription(String planType) {
    // TODO: Implement subscription logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abonelik'),
        content: Text('$planType planına abone olmak istediğinizi onaylıyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Process subscription
            },
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yardım'),
        content: const Text(
          'Premium üyelik hakkında daha fazla bilgi almak için müşteri hizmetleri ile iletişime geçebilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open support
            },
            child: const Text('İletişim'),
          ),
        ],
      ),
    );
  }
}