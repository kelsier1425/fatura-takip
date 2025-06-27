import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class PremiumFeaturesCard extends StatelessWidget {
  const PremiumFeaturesCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.primaryLight.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.diamond,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Premium Özellikler',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tüm özellikleri keşfedin',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...List.generate(
              _premiumFeatures.length,
              (index) => _buildFeatureItem(_premiumFeatures[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(Map<String, dynamic> feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (feature['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature['icon'] as IconData,
              color: feature['color'] as Color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature['description'] as String,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static final List<Map<String, dynamic>> _premiumFeatures = [
    {
      'icon': Icons.analytics,
      'title': 'Gelişmiş Analiz Raporları',
      'description': 'Detaylı harcama analizleri ve trendler',
      'color': AppColors.primary,
    },
    {
      'icon': Icons.sync,
      'title': 'Otomatik Veri Senkronizasyonu',
      'description': 'Tüm cihazlarınızda verileriniz senkronize',
      'color': AppColors.info,
    },
    {
      'icon': Icons.category,
      'title': 'Sınırsız Kategori',
      'description': 'İstediğiniz kadar kategori oluşturun',
      'color': AppColors.secondary,
    },
    {
      'icon': Icons.backup,
      'title': 'Bulut Yedekleme',
      'description': 'Verileriniz güvenli şekilde yedeklenir',
      'color': AppColors.success,
    },
    {
      'icon': Icons.notifications_active,
      'title': 'Akıllı Hatırlatıcılar',
      'description': 'Özelleştirilebilir bildirimler',
      'color': AppColors.warning,
    },
    {
      'icon': Icons.support_agent,
      'title': 'Premium Destek',
      'description': '7/24 öncelikli müşteri desteği',
      'color': AppColors.accent,
    },
  ];
}