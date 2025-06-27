import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/category_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/animated_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../widgets/color_picker_grid.dart';
import '../widgets/icon_picker_grid.dart';

class AddCategoryPage extends ConsumerStatefulWidget {
  final bool isSubcategory;
  final String? parentCategoryId;

  const AddCategoryPage({
    Key? key,
    this.isSubcategory = false,
    this.parentCategoryId,
  }) : super(key: key);

  @override
  ConsumerState<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends ConsumerState<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  CategoryType _selectedType = CategoryType.personal;
  Color _selectedColor = AppColors.primary;
  IconData _selectedIcon = Icons.category_outlined;
  bool _isLoading = false;
  bool _isPremium = false;

  static const _uuid = Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final category = CategoryEntity(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        type: _selectedType,
        color: _selectedColor,
        icon: _selectedIcon,
        parentId: widget.parentCategoryId,
        isPremium: _isPremium,
        createdAt: DateTime.now(),
      );

      // TODO: Save category to repository
      await Future.delayed(const Duration(seconds: 1));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${category.name} kategorisi oluşturuldu'),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LoadingOverlay(
      isLoading: _isLoading,
      loadingText: 'Kategori oluşturuluyor...',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isSubcategory ? 'Alt Kategori Ekle' : 'Kategori Ekle',
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category Preview
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _selectedIcon,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty 
                                  ? 'Kategori Adı' 
                                  : _nameController.text,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _selectedColor,
                              ),
                            ),
                            if (_descriptionController.text.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _descriptionController.text,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _selectedColor.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn()
                .scale(begin: const Offset(0.9, 0.9)),

                const SizedBox(height: 32),

                // Category Name
                AnimatedTextField(
                  controller: _nameController,
                  labelText: 'Kategori Adı',
                  hintText: 'Örn: Sağlık, Giyim, Eğitim',
                  prefixIcon: const Icon(Icons.label_outline),
                  onChanged: (value) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kategori adı gerekli';
                    }
                    if (value.trim().length < 2) {
                      return 'Kategori adı en az 2 karakter olmalı';
                    }
                    return null;
                  },
                )
                .animate()
                .fadeIn(delay: 100.ms)
                .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                // Category Description
                AnimatedTextField(
                  controller: _descriptionController,
                  labelText: 'Açıklama (Opsiyonel)',
                  hintText: 'Kategori hakkında kısa açıklama',
                  prefixIcon: const Icon(Icons.description_outlined),
                  maxLines: 2,
                  onChanged: (value) => setState(() {}),
                )
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // Category Type (if main category)
                if (!widget.isSubcategory) ...[
                  Text(
                    'Kategori Türü',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoryType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return FilterChip(
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedType = type);
                          }
                        },
                        label: Text(_getCategoryTypeName(type)),
                        backgroundColor: _getCategoryTypeColor(type).withOpacity(0.1),
                        selectedColor: _getCategoryTypeColor(type),
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
                  )
                  .animate()
                  .fadeIn(delay: 300.ms),
                  const SizedBox(height: 24),
                ],

                // Color Selection
                Text(
                  'Renk Seç',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ColorPickerGrid(
                  selectedColor: _selectedColor,
                  onColorSelected: (color) {
                    setState(() => _selectedColor = color);
                  },
                )
                .animate()
                .fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                // Icon Selection
                Text(
                  'İkon Seç',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                IconPickerGrid(
                  selectedIcon: _selectedIcon,
                  selectedColor: _selectedColor,
                  onIconSelected: (icon) {
                    setState(() => _selectedIcon = icon);
                  },
                )
                .animate()
                .fadeIn(delay: 500.ms),

                const SizedBox(height: 24),

                // Premium Option
                SwitchListTile(
                  title: const Text('Premium Özellik'),
                  subtitle: const Text('Bu kategori sadece premium üyeler için görünür'),
                  value: _isPremium,
                  onChanged: (value) {
                    setState(() => _isPremium = value);
                  },
                  tileColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms),

                const SizedBox(height: 32),

                // Save Button
                AnimatedButton(
                  onPressed: _handleSave,
                  child: const Text('Kategori Oluştur'),
                )
                .animate()
                .fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoryTypeName(CategoryType type) {
    switch (type) {
      case CategoryType.personal:
        return 'Kişisel';
      case CategoryType.child:
        return 'Çocuk';
      case CategoryType.pet:
        return 'Evcil Hayvan';
      case CategoryType.subscription:
        return 'Abonelik';
      case CategoryType.home:
        return 'Ev Gideri';
      case CategoryType.food:
        return 'Gıda';
      case CategoryType.professional:
        return 'Profesyonel Araçlar';
      case CategoryType.health:
        return 'Sağlık & Wellness';
      case CategoryType.technology:
        return 'Teknoloji & Yapay Zeka';
      case CategoryType.digital:
        return 'Dijital İçerik & Medya';
      case CategoryType.gaming:
        return 'Oyun & Eğlence';
      case CategoryType.vehicle:
        return 'Araç';
    }
  }

  Color _getCategoryTypeColor(CategoryType type) {
    switch (type) {
      case CategoryType.personal:
        return AppColors.categoryPersonal;
      case CategoryType.child:
        return AppColors.categoryChild;
      case CategoryType.pet:
        return AppColors.categoryPet;
      case CategoryType.subscription:
        return AppColors.categorySubscription;
      case CategoryType.home:
        return AppColors.categoryHome;
      case CategoryType.food:
        return AppColors.categoryFood;
      case CategoryType.professional:
        return AppColors.categoryProfessional;
      case CategoryType.health:
        return AppColors.categoryHealth;
      case CategoryType.technology:
        return AppColors.categoryTechnology;
      case CategoryType.digital:
        return AppColors.categoryDigital;
      case CategoryType.gaming:
        return AppColors.categoryGaming;
      case CategoryType.vehicle:
        return AppColors.categoryVehicle;
    }
  }
}