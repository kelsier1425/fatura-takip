import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class AddCategoryFab extends StatefulWidget {
  const AddCategoryFab({Key? key}) : super(key: key);

  @override
  State<AddCategoryFab> createState() => _AddCategoryFabState();
}

class _AddCategoryFabState extends State<AddCategoryFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.125, // 45 degrees
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _addMainCategory() {
    _toggleExpanded();
    context.push('/category/add?type=main');
  }

  void _addSubCategory() {
    _toggleExpanded();
    context.push('/category/add?type=sub');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Add Subcategory FAB
        AnimatedSlide(
          duration: AppConstants.mediumAnimation,
          offset: _isExpanded ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: AppConstants.mediumAnimation,
            opacity: _isExpanded ? 1.0 : 0.0,
            child: FloatingActionButton(
              heroTag: "add_subcategory",
              onPressed: _isExpanded ? _addSubCategory : null,
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.subdirectory_arrow_right),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Add Main Category FAB
        AnimatedSlide(
          duration: AppConstants.mediumAnimation,
          offset: _isExpanded ? Offset.zero : const Offset(0, 1),
          child: AnimatedOpacity(
            duration: AppConstants.mediumAnimation,
            opacity: _isExpanded ? 1.0 : 0.0,
            child: FloatingActionButton(
              heroTag: "add_main_category",
              onPressed: _isExpanded ? _addMainCategory : null,
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.category_outlined),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Main FAB
        FloatingActionButton(
          heroTag: "main_fab",
          onPressed: _toggleExpanded,
          backgroundColor: AppColors.primary,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Icon(
                  _isExpanded ? Icons.close : Icons.add,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CategoryOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const CategoryOptionTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}