import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../categories/data/datasources/default_categories.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/animated_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';

class RecurringExpenseSetupPage extends ConsumerStatefulWidget {
  const RecurringExpenseSetupPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RecurringExpenseSetupPage> createState() => _RecurringExpenseSetupPageState();
}

class _RecurringExpenseSetupPageState extends ConsumerState<RecurringExpenseSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  RecurrenceType _recurrenceType = RecurrenceType.monthly;
  int _recurrenceInterval = 1;
  CategoryEntity? _selectedCategory;
  CategoryEntity? _selectedSubcategory;
  bool _isLoading = false;
  bool _skipThisMonth = false;
  
  final List<CategoryEntity> _categories = DefaultCategories.getDefaultCategories();
  final List<CategoryEntity> _subcategories = DefaultCategories.getDefaultSubcategories();
  
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  List<CategoryEntity> get _filteredSubcategories {
    if (_selectedCategory == null) return [];
    return _subcategories
        .where((sub) => sub.parentId == _selectedCategory!.id)
        .toList();
  }
  
  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }
  
  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    
    setState(() {
      _endDate = picked;
    });
  }
  
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kategori seçin')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // TODO: Create recurring expense automation
      await Future.delayed(const Duration(seconds: 2));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tekrarlayan harcama oluşturuldu'),
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
      loadingText: 'Otomasyon oluşturuluyor...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tekrarlayan Harcama'),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bu ayarlar ile belirlediğiniz tarihlerde otomatik olarak harcama kaydı oluşturulacak.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                AnimatedTextField(
                  controller: _titleController,
                  labelText: 'Harcama Başlığı',
                  hintText: 'Örn: Elektrik Faturası',
                  prefixIcon: const Icon(Icons.receipt_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Başlık gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Amount
                AnimatedTextField(
                  controller: _amountController,
                  labelText: 'Tutar (₺)',
                  hintText: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.attach_money),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tutar gerekli';
                    }
                    final amount = double.tryParse(value.replaceAll(',', '.'));
                    if (amount == null || amount <= 0) {
                      return 'Geçerli bir tutar girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Category Selection
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<CategoryEntity>(
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
                              children: [
                                Icon(category.icon, size: 20, color: category.color),
                                const SizedBox(width: 12),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                            _selectedSubcategory = null;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Kategori seçin';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_filteredSubcategories.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<CategoryEntity>(
                          value: _selectedSubcategory,
                          decoration: InputDecoration(
                            labelText: 'Alt Kategori',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _filteredSubcategories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubcategory = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                
                // Recurrence Settings
                Text(
                  'Tekrar Ayarları',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Recurrence Type
                DropdownButtonFormField<RecurrenceType>(
                  value: _recurrenceType,
                  decoration: InputDecoration(
                    labelText: 'Tekrar Sıklığı',
                    prefixIcon: const Icon(Icons.repeat),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    RecurrenceType.weekly,
                    RecurrenceType.monthly,
                    RecurrenceType.yearly,
                  ].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getRecurrenceTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _recurrenceType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Recurrence Interval
                if (_recurrenceType != RecurrenceType.weekly) ...[
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _recurrenceInterval,
                          decoration: InputDecoration(
                            labelText: 'Her',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: List.generate(12, (index) => index + 1)
                              .map((interval) {
                            return DropdownMenuItem(
                              value: interval,
                              child: Text('$interval'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _recurrenceInterval = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _recurrenceType == RecurrenceType.monthly ? 'Ay' : 'Yıl',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Date Settings
                Text(
                  'Tarih Ayarları',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Start Date
                InkWell(
                  onTap: _selectStartDate,
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
                                'Başlangıç Tarihi',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMMM yyyy', 'tr').format(_startDate),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // End Date (Optional)
                InkWell(
                  onTap: _selectEndDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_outlined, color: AppColors.secondary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bitiş Tarihi (Opsiyonel)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _endDate != null 
                                    ? DateFormat('dd MMMM yyyy', 'tr').format(_endDate!)
                                    : 'Süresiz devam et',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: _endDate != null 
                                      ? null 
                                      : theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_endDate != null)
                          IconButton(
                            onPressed: () => setState(() => _endDate = null),
                            icon: const Icon(Icons.clear),
                          )
                        else
                          const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Skip This Month Option
                SwitchListTile(
                  title: const Text('Bu ay atla'),
                  subtitle: const Text('İlk harcama bir sonraki dönemde oluşturulsun'),
                  value: _skipThisMonth,
                  onChanged: (value) {
                    setState(() => _skipThisMonth = value);
                  },
                  activeColor: AppColors.primary,
                  tileColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                AnimatedTextField(
                  controller: _descriptionController,
                  labelText: 'Açıklama (Opsiyonel)',
                  hintText: 'Bu otomasyon hakkında notlar',
                  prefixIcon: const Icon(Icons.description_outlined),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                
                // Save Button
                AnimatedButton(
                  onPressed: _handleSave,
                  child: const Text('Otomasyonu Oluştur'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
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