import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../categories/data/datasources/default_categories.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../../core/constants/app_colors.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseEntity expense;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePaid;
  
  static final Map<String, CategoryEntity?> _categoryCache = {};
  static final Map<String, CategoryEntity?> _subcategoryCache = {};
  
  const ExpenseCard({
    Key? key,
    required this.expense,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePaid,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = _getCategoryById(expense.categoryId);
    final subcategory = expense.subcategoryId != null 
        ? _getSubcategoryById(expense.subcategoryId!) 
        : null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: category?.color.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category?.icon ?? Icons.category_outlined,
                      color: category?.color ?? Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              category?.name ?? 'Kategori',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: category?.color ?? Colors.grey,
                              ),
                            ),
                            if (subcategory != null) ...[
                              Text(
                                ' • ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                                ),
                              ),
                              Text(
                                subcategory.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₺${expense.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: expense.isPaid ? AppColors.success : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: expense.isPaid 
                              ? AppColors.success.withOpacity(0.1) 
                              : AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          expense.isPaid ? 'Ödendi' : 'Bekliyor',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: expense.isPaid ? AppColors.success : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Date and Type
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy', 'tr').format(expense.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (expense.isRecurring) ...[
                    Icon(
                      Icons.repeat,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getRecurrenceText(expense.recurrenceType),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              
              // Description
              if (expense.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  expense.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Actions
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onTogglePaid,
                    icon: Icon(
                      expense.isPaid ? Icons.check_circle_outline : Icons.circle_outlined,
                      size: 18,
                    ),
                    label: Text(expense.isPaid ? 'Ödendi' : 'Öde'),
                    style: TextButton.styleFrom(
                      foregroundColor: expense.isPaid ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  CategoryEntity? _getCategoryById(String id) {
    if (_categoryCache.containsKey(id)) {
      return _categoryCache[id];
    }
    
    final categories = DefaultCategories.getDefaultCategories();
    try {
      final category = categories.firstWhere((c) => c.id == id);
      _categoryCache[id] = category;
      return category;
    } catch (_) {
      _categoryCache[id] = null;
      return null;
    }
  }
  
  CategoryEntity? _getSubcategoryById(String id) {
    if (_subcategoryCache.containsKey(id)) {
      return _subcategoryCache[id];
    }
    
    final subcategories = DefaultCategories.getDefaultSubcategories();
    try {
      final subcategory = subcategories.firstWhere((c) => c.id == id);
      _subcategoryCache[id] = subcategory;
      return subcategory;
    } catch (_) {
      _subcategoryCache[id] = null;
      return null;
    }
  }
  
  String _getRecurrenceText(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return '';
      case RecurrenceType.daily:
        return 'Günlük';
      case RecurrenceType.weekly:
        return 'Haftalık';
      case RecurrenceType.monthly:
        return 'Aylık';
      case RecurrenceType.yearly:
        return 'Yıllık';
    }
  }
}