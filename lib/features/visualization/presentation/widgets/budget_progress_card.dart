import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class BudgetProgressCard extends StatelessWidget {
  final double totalBudget;
  final double spent;
  final double remaining;
  final int daysLeft;

  const BudgetProgressCard({
    Key? key,
    required this.totalBudget,
    required this.spent,
    required this.remaining,
    required this.daysLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (spent / totalBudget).clamp(0.0, 1.0);
    final isOverBudget = spent > totalBudget;

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
              AppColors.primaryLight.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toplam Bütçe',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₺${totalBudget.toStringAsFixed(0)}',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isOverBudget
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOverBudget ? Icons.warning : Icons.check_circle,
                        size: 16,
                        color: isOverBudget ? AppColors.error : AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOverBudget
                            ? '%${(percentage * 100).toStringAsFixed(0)} Aşıldı'
                            : '%${(percentage * 100).toStringAsFixed(0)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isOverBudget ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  height: 12,
                  width: MediaQuery.of(context).size.width * percentage * 0.8,
                  decoration: BoxDecoration(
                    gradient: isOverBudget
                        ? LinearGradient(
                            colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                          )
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  icon: Icons.shopping_cart,
                  label: 'Harcanan',
                  value: '₺${spent.toStringAsFixed(0)}',
                  color: AppColors.primary,
                ),
                _buildStatItem(
                  icon: Icons.account_balance_wallet,
                  label: isOverBudget ? 'Aşım' : 'Kalan',
                  value: '₺${remaining.abs().toStringAsFixed(0)}',
                  color: isOverBudget ? AppColors.error : AppColors.success,
                ),
                _buildStatItem(
                  icon: Icons.calendar_today,
                  label: 'Kalan Gün',
                  value: '$daysLeft',
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}