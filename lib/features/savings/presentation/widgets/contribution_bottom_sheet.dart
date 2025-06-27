import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/savings_goal_entity.dart';

class ContributionBottomSheet extends StatefulWidget {
  final SavingsGoalEntity goal;
  final Function(double amount, String? note) onContribute;

  const ContributionBottomSheet({
    Key? key,
    required this.goal,
    required this.onContribute,
  }) : super(key: key);

  @override
  State<ContributionBottomSheet> createState() => _ContributionBottomSheetState();
}

class _ContributionBottomSheetState extends State<ContributionBottomSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  double? _selectedAmount;
  bool _isCustomAmount = false;

  final List<double> _quickAmounts = [50, 100, 250, 500, 1000];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Row(
                children: [
                  Text(
                    widget.goal.emoji ?? '🎯',
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Katkı Ekle',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.goal.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Progress Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.getCardBorderColor(context),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mevcut',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '₺${widget.goal.currentAmount.toStringAsFixed(0)}',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.goal.progressPercentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          _getCategoryColor(widget.goal.category),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hedef',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '₺${widget.goal.targetAmount.toStringAsFixed(0)}',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Quick Amount Selection
              Text(
                'Hızlı Tutar Seçimi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._quickAmounts.map((amount) => _buildQuickAmountChip(amount)),
                  _buildCustomAmountChip(),
                ],
              ).animate().fadeIn(duration: 300.ms),
              
              // Custom Amount Input
              if (_isCustomAmount) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Tutar Girin',
                    hintText: '0',
                    prefixText: '₺ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: widget.goal.monthlyRequiredSaving != null
                        ? TextButton(
                            onPressed: () {
                              _amountController.text = 
                                  widget.goal.monthlyRequiredSaving!.toStringAsFixed(0);
                            },
                            child: Text(
                              'Aylık\n₺${widget.goal.monthlyRequiredSaving!.toStringAsFixed(0)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : null,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir tutar girin';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Geçerli bir tutar girin';
                    }
                    return null;
                  },
                ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1),
              ],
              const SizedBox(height: 16),
              
              // Note Input
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Not (İsteğe bağlı)',
                  hintText: 'Bu katkı için bir not ekleyin...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.note_outlined),
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getCategoryColor(widget.goal.category),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Katkı Ekle'),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(double amount) {
    final isSelected = _selectedAmount == amount && !_isCustomAmount;
    
    return ChoiceChip(
      label: Text('₺${amount.toStringAsFixed(0)}'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedAmount = selected ? amount : null;
          _isCustomAmount = false;
          _amountController.clear();
        });
      },
      selectedColor: _getCategoryColor(widget.goal.category),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.w600 : null,
      ),
    );
  }

  Widget _buildCustomAmountChip() {
    return ChoiceChip(
      label: const Text('Farklı Tutar'),
      selected: _isCustomAmount,
      onSelected: (selected) {
        setState(() {
          _isCustomAmount = selected;
          _selectedAmount = null;
        });
      },
      selectedColor: _getCategoryColor(widget.goal.category),
      labelStyle: TextStyle(
        color: _isCustomAmount ? Colors.white : null,
        fontWeight: _isCustomAmount ? FontWeight.w600 : null,
      ),
    );
  }

  void _onSubmit() {
    double? amount;
    
    if (_isCustomAmount) {
      if (_formKey.currentState!.validate()) {
        amount = double.tryParse(_amountController.text);
      }
    } else {
      amount = _selectedAmount;
    }
    
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir tutar seçin veya girin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    widget.onContribute(
      amount,
      _noteController.text.isEmpty ? null : _noteController.text,
    );
  }

  Color _getCategoryColor(SavingsGoalCategory category) {
    switch (category) {
      case SavingsGoalCategory.emergency:
        return Colors.red;
      case SavingsGoalCategory.vacation:
        return Colors.orange;
      case SavingsGoalCategory.house:
        return Colors.blue;
      case SavingsGoalCategory.car:
        return Colors.green;
      case SavingsGoalCategory.education:
        return Colors.purple;
      case SavingsGoalCategory.wedding:
        return Colors.pink;
      case SavingsGoalCategory.retirement:
        return Colors.brown;
      case SavingsGoalCategory.health:
        return Colors.teal;
      case SavingsGoalCategory.technology:
        return Colors.indigo;
      case SavingsGoalCategory.gift:
        return Colors.amber;
      case SavingsGoalCategory.debt:
        return Colors.grey;
      case SavingsGoalCategory.investment:
        return Colors.deepPurple;
      case SavingsGoalCategory.other:
        return AppColors.primary;
    }
  }
}