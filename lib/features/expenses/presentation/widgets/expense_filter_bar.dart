import 'package:flutter/material.dart';
import '../../../categories/data/datasources/default_categories.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../../core/constants/app_colors.dart';

class ExpenseFilterBar extends StatelessWidget {
  final String? selectedCategoryId;
  final bool showOnlyUnpaid;
  final Function(String?) onCategoryChanged;
  final Function(bool) onUnpaidFilterChanged;
  
  const ExpenseFilterBar({
    Key? key,
    required this.selectedCategoryId,
    required this.showOnlyUnpaid,
    required this.onCategoryChanged,
    required this.onUnpaidFilterChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = DefaultCategories.getDefaultCategories();
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // All Categories
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: selectedCategoryId == null && !showOnlyUnpaid,
              onSelected: (_) => onCategoryChanged(null),
              label: const Text('Tümü'),
              avatar: const Icon(Icons.apps, size: 18),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
            ),
          ),
          
          // Unpaid Only
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: showOnlyUnpaid,
              onSelected: onUnpaidFilterChanged,
              label: const Text('Ödenmemiş'),
              avatar: Icon(
                Icons.access_time,
                size: 18,
                color: showOnlyUnpaid ? Colors.white : AppColors.warning,
              ),
              backgroundColor: AppColors.warning.withOpacity(0.1),
              selectedColor: AppColors.warning,
              checkmarkColor: Colors.white,
            ),
          ),
          
          // Category Filters
          ...categories.map((category) {
            final isSelected = selectedCategoryId == category.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                onSelected: (_) => onCategoryChanged(category.id),
                label: Text(category.name),
                avatar: Icon(
                  category.icon,
                  size: 18,
                  color: isSelected ? Colors.white : category.color,
                ),
                backgroundColor: category.color.withOpacity(0.1),
                selectedColor: category.color,
                checkmarkColor: Colors.white,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}