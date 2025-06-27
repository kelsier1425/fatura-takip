import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../categories/data/datasources/default_categories.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/animated_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/expense_provider.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  final String? categoryId;
  
  const AddExpensePage({
    Key? key,
    this.categoryId,
  }) : super(key: key);

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  ExpenseType _selectedType = ExpenseType.oneTime;
  RecurrenceType _recurrenceType = RecurrenceType.monthly;
  CategoryEntity? _selectedCategory;
  CategoryEntity? _selectedSubcategory;
  CategoryEntity? _selectedSubSubcategory;
  bool _isPaid = false;
  
  final List<CategoryEntity> _categories = DefaultCategories.getDefaultCategories();
  final List<CategoryEntity> _subcategories = DefaultCategories.getDefaultSubcategories();
  final List<CategoryEntity> _subsubcategories = DefaultCategories.getDefaultSubSubcategories();
  
  static const _uuid = Uuid();
  
  @override
  void initState() {
    super.initState();
    _initializeCategory();
  }
  
  void _initializeCategory() {
    if (widget.categoryId != null) {
      // Önce tüm kategorilerde ara
      final allCategories = [
        ..._categories,
        ..._subcategories,
        ..._subsubcategories,
      ];
      
      final foundCategory = allCategories.firstWhere(
        (c) => c.id == widget.categoryId,
        orElse: () => _categories.first,
      );
      
      if (foundCategory.isMainCategory) {
        // Ana kategori
        _selectedCategory = foundCategory;
      } else if (foundCategory.isSubcategory) {
        // Alt kategori - parent'ını bul
        _selectedCategory = _categories.firstWhere(
          (c) => c.id == foundCategory.parentId,
          orElse: () => _categories.first,
        );
        _selectedSubcategory = foundCategory;
      } else if (foundCategory.isSubSubcategory) {
        // Alt-alt kategori - parent ve grandparent'ını bul
        _selectedCategory = _categories.firstWhere(
          (c) => c.id == foundCategory.parentId,
          orElse: () => _categories.first,
        );
        _selectedSubcategory = _subcategories.firstWhere(
          (c) => c.id == foundCategory.subParentId,
          orElse: () => _subcategories.first,
        );
        _selectedSubSubcategory = foundCategory;
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  List<CategoryEntity> get _filteredSubcategories {
    if (_selectedCategory == null) return [];
    return _subcategories
        .where((sub) => sub.parentId == _selectedCategory!.id)
        .toList();
  }
  
  List<CategoryEntity> get _filteredSubSubcategories {
    if (_selectedSubcategory == null) return [];
    return _subsubcategories
        .where((subsub) => subsub.subParentId == _selectedSubcategory!.id)
        .toList();
  }
  
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kategori seçin')),
      );
      return;
    }
    
    final expenseNotifier = ref.read(expenseProvider.notifier);
    
    try {
      // Parse amount
      final amountText = _amountController.text.replaceAll('₺', '').replaceAll(',', '.').trim();
      final amount = double.parse(amountText);
      
      // Determine category ID
      String categoryId;
      if (_selectedSubSubcategory != null) {
        categoryId = _selectedSubSubcategory!.id;
      } else if (_selectedSubcategory != null) {
        categoryId = _selectedSubcategory!.id;
      } else {
        categoryId = _selectedCategory!.id;
      }
      
      // Create expense
      final expense = ExpenseEntity(
        id: _uuid.v4(),
        userId: 'user_123', // Mock user ID
        categoryId: categoryId,
        title: _titleController.text,
        description: _notesController.text.isEmpty ? null : _notesController.text,
        amount: amount,
        date: _selectedDate,
        type: _selectedType,
        isPaid: _isPaid,
        receiptUrl: null,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        isRecurring: _selectedType == ExpenseType.recurring,
        recurrenceType: _selectedType == ExpenseType.recurring ? _recurrenceType : RecurrenceType.none,
        recurrenceInterval: _selectedType == ExpenseType.recurring ? 1 : null,
        recurrenceEndDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await expenseNotifier.addExpense(expense);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harcama başarıyla eklendi'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
  
  DateTime? _calculateNextDueDate() {
    switch (_recurrenceType) {
      case RecurrenceType.none:
        return null;
      case RecurrenceType.daily:
        return _selectedDate.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        return _selectedDate.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        return DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
      case RecurrenceType.yearly:
        return DateTime(_selectedDate.year + 1, _selectedDate.month, _selectedDate.day);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseState = ref.watch(expenseProvider);
    final isLoading = expenseState.status == ExpenseStatus.loading;
    
    return Scaffold(
        appBar: AppBar(
          title: const Text('Harcama Ekle'),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Amount Input
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tutar',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          prefixText: '₺ ',
                          prefixStyle: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: theme.textTheme.displaySmall?.copyWith(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        validator: Validators.amount,
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.9, 0.9))
                .shimmer(delay: 400.ms, duration: 1.5.seconds),
                const SizedBox(height: 24),
                
                // Title
                AnimatedTextField(
                  controller: _titleController,
                  labelText: 'Başlık',
                  hintText: 'Örn: Elektrik Faturası',
                  prefixIcon: const Icon(Icons.receipt_outlined),
                  validator: Validators.description,
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideX(begin: -0.1, end: 0),
                const SizedBox(height: 16),
                
                // Category Selection
                Column(
                  children: [
                    // Ana Kategori
                    DropdownButtonFormField<CategoryEntity>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category.icon,
                                color: category.color,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _selectedSubcategory = null; // Reset subcategory
                          _selectedSubSubcategory = null; // Reset sub-subcategory
                        });
                      },
                      validator: (value) => value == null ? 'Lütfen bir kategori seçin' : null,
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),
                    
                    // Alt Kategori
                    if (_filteredSubcategories.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<CategoryEntity>(
                        value: _selectedSubcategory,
                        decoration: InputDecoration(
                          labelText: 'Alt Kategori (Opsiyonel)',
                          prefixIcon: const Icon(Icons.subdirectory_arrow_right),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _filteredSubcategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    category.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (category.isPremium)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'PRO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubcategory = value;
                            _selectedSubSubcategory = null; // Reset sub-subcategory
                          });
                        },
                      )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 500.ms)
                      .slideX(begin: 0.1, end: 0),
                    ],
                    
                    // Alt-Alt Kategori
                    if (_filteredSubSubcategories.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<CategoryEntity>(
                        value: _selectedSubSubcategory,
                        decoration: InputDecoration(
                          labelText: 'Detay Kategori (Opsiyonel)',
                          prefixIcon: const Icon(Icons.double_arrow_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _filteredSubSubcategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    category.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (category.isPremium)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'PRO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubSubcategory = value;
                          });
                        },
                      )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 500.ms)
                      .slideX(begin: 0.2, end: 0),
                    ],
                  ],
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms),
                const SizedBox(height: 16),
                
                // Date Selection
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tarih',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMMM yyyy', 'tr').format(_selectedDate),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms)
                .scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: 16),
                
                // Expense Type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harcama Türü',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: ExpenseType.values.map((type) {
                        final isSelected = _selectedType == type;
                        return FilterChip(
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = type;
                              if (type != ExpenseType.recurring) {
                                _recurrenceType = RecurrenceType.none;
                              }
                            });
                          },
                          label: Text(_getExpenseTypeName(type)),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: 700.ms, duration: 500.ms)
                .slideY(begin: 0.1, end: 0),
                
                // Recurrence Options
                if (_selectedType == ExpenseType.recurring) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<RecurrenceType>(
                    value: _recurrenceType,
                    decoration: InputDecoration(
                      labelText: 'Tekrar Sıklığı',
                      prefixIcon: const Icon(Icons.repeat),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: RecurrenceType.values
                        .where((type) => type != RecurrenceType.none)
                        .map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getRecurrenceTypeName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _recurrenceType = value ?? RecurrenceType.monthly;
                      });
                    },
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: -0.1, end: 0),
                ],
                const SizedBox(height: 16),
                
                // Payment Status
                SwitchListTile(
                  title: const Text('Ödendi mi?'),
                  subtitle: Text(
                    _isPaid ? 'Ödeme yapıldı' : 'Ödeme bekliyor',
                    style: TextStyle(
                      color: _isPaid ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  value: _isPaid,
                  onChanged: (value) {
                    setState(() => _isPaid = value);
                  },
                  activeColor: AppColors.success,
                  tileColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
                .animate()
                .fadeIn(delay: 900.ms, duration: 500.ms)
                .scale(begin: const Offset(0.9, 0.9)),
                const SizedBox(height: 16),
                
                // Description
                AnimatedTextField(
                  controller: _descriptionController,
                  labelText: 'Açıklama (Opsiyonel)',
                  hintText: 'Harcama hakkında detaylar',
                  prefixIcon: const Icon(Icons.description_outlined),
                  maxLines: 2,
                )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 500.ms)
                .slideX(begin: -0.1, end: 0),
                const SizedBox(height: 16),
                
                // Notes
                AnimatedTextField(
                  controller: _notesController,
                  labelText: 'Notlar (Opsiyonel)',
                  hintText: 'Özel notlarınız',
                  prefixIcon: const Icon(Icons.note_outlined),
                  maxLines: 3,
                  validator: Validators.notes,
                )
                .animate()
                .fadeIn(delay: 1100.ms, duration: 500.ms)
                .slideX(begin: 0.1, end: 0),
                const SizedBox(height: 32),
                
                // Save Button
                AnimatedButton(
                  onPressed: isLoading ? null : _handleSave,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Harcamayı Kaydet'),
                )
                .animate()
                .fadeIn(delay: 1200.ms, duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8))
                .shimmer(delay: 1800.ms, duration: 1.5.seconds),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
    );
  }
  
  String _getExpenseTypeName(ExpenseType type) {
    switch (type) {
      case ExpenseType.bill:
        return 'Fatura';
      case ExpenseType.subscription:
        return 'Abonelik';
      case ExpenseType.oneTime:
        return 'Tek Seferlik';
      case ExpenseType.recurring:
        return 'Tekrarlayan';
    }
  }
  
  String _getRecurrenceTypeName(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return 'Tekrar Yok';
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