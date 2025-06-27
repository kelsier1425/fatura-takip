import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../categories/data/datasources/default_categories.dart';
import '../../domain/entities/budget_entity.dart';

class BudgetListItem extends StatelessWidget {
  final BudgetEntity budget;
  final bool showCategory;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetListItem({
    Key? key,
    required this.budget,
    this.showCategory = false,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usagePercentage = budget.usagePercentage;
    final category = budget.categoryId != null 
        ? DefaultCategories.getDefaultCategories()
            .where((cat) => cat.id == budget.categoryId)
            .firstOrNull
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Budget icon and category
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getBudgetStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category?.icon ?? _getBudgetTypeIcon(),
                      color: _getBudgetStatusColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Budget info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                budget.name,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getBudgetStatusColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: _getBudgetStatusColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        
                        if (showCategory && category != null)
                          Text(
                            category.name,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        
                        if (budget.description != null)
                          Text(
                            budget.description!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  
                  // Actions menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Budget amounts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kullanılan',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₺${budget.spent.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: budget.isExceeded ? AppColors.error : null,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Toplam Bütçe',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₺${budget.amount.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        budget.isExceeded ? 'Aşım' : 'Kalan',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        budget.isExceeded 
                            ? '₺${(budget.spent - budget.amount).toStringAsFixed(2)}'
                            : '₺${budget.remaining.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: budget.isExceeded ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '%${(usagePercentage * 100).toInt()} kullanıldı',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (budget.daysRemaining > 0)
                        Text(
                          '${budget.daysRemaining} gün kaldı',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: budget.daysRemaining < 7 
                                ? AppColors.warning 
                                : AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: usagePercentage.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_getBudgetStatusColor()),
                    minHeight: 6,
                  ),
                ],
              ),
              
              // Period info
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(budget.startDate)} - ${_formatDate(budget.endDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getPeriodText(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBudgetStatusColor() {
    if (budget.isExceeded) {
      return AppColors.error;
    } else if (budget.isWarningReached) {
      return AppColors.warning;
    } else if (budget.usagePercentage > 0.5) {
      return AppColors.accent;
    } else {
      return AppColors.success;
    }
  }

  String _getStatusText() {
    if (budget.isExceeded) {
      return 'Aşıldı';
    } else if (budget.isWarningReached) {
      return 'Uyarı';
    } else if (budget.usagePercentage > 0.5) {
      return 'Dikkat';
    } else {
      return 'İyi';
    }
  }

  IconData _getBudgetTypeIcon() {
    switch (budget.type) {
      case BudgetType.general:
        return Icons.account_balance_wallet;
      case BudgetType.category:
        return Icons.category;
      case BudgetType.subcategory:
        return Icons.subdirectory_arrow_right;
    }
  }

  String _getPeriodText() {
    switch (budget.period) {
      case BudgetPeriod.weekly:
        return 'Haftalık';
      case BudgetPeriod.monthly:
        return 'Aylık';
      case BudgetPeriod.quarterly:
        return 'Üç Aylık';
      case BudgetPeriod.yearly:
        return 'Yıllık';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yy').format(date);
  }
}