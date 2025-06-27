import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/category_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class CategoryFilterChips extends StatelessWidget {
  final CategoryType? selectedFilter;
  final Function(CategoryType?) onFilterChanged;

  const CategoryFilterChips({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filters = [
      {
        'type': null,
        'label': 'Tümü',
        'color': AppColors.primary,
        'icon': Icons.apps,
      },
      {
        'type': CategoryType.personal,
        'label': 'Kişisel',
        'color': AppColors.categoryPersonal,
        'icon': Icons.person_outline,
      },
      {
        'type': CategoryType.child,
        'label': 'Çocuk',
        'color': AppColors.categoryChild,
        'icon': Icons.child_care_outlined,
      },
      {
        'type': CategoryType.pet,
        'label': 'Pet',
        'color': AppColors.categoryPet,
        'icon': Icons.pets_outlined,
      },
      {
        'type': CategoryType.subscription,
        'label': 'Abonelik',
        'color': AppColors.categorySubscription,
        'icon': Icons.subscriptions_outlined,
      },
      {
        'type': CategoryType.home,
        'label': 'Ev',
        'color': AppColors.categoryHome,
        'icon': Icons.home_outlined,
      },
      {
        'type': CategoryType.food,
        'label': 'Gıda',
        'color': AppColors.categoryFood,
        'icon': Icons.restaurant_outlined,
      },
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['type'];
          final color = filter['color'] as Color;

          return FilterChip(
            selected: isSelected,
            onSelected: (selected) {
              onFilterChanged(filter['type'] as CategoryType?);
            },
            avatar: Icon(
              filter['icon'] as IconData,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            label: Text(
              filter['label'] as String,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: color.withOpacity(0.1),
            selectedColor: color,
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: isSelected ? color : color.withOpacity(0.3),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: index * 50),
            duration: AppConstants.shortAnimation,
          )
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            delay: Duration(milliseconds: index * 50),
            duration: AppConstants.shortAnimation,
          );
        },
      ),
    );
  }
}