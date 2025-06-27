import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/usecases/create_savings_goal_usecase.dart';
import '../providers/savings_goal_provider.dart';

class CreateGoalBottomSheet extends ConsumerStatefulWidget {
  const CreateGoalBottomSheet({super.key});

  @override
  ConsumerState<CreateGoalBottomSheet> createState() => _CreateGoalBottomSheetState();
}

class _CreateGoalBottomSheetState extends ConsumerState<CreateGoalBottomSheet>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  
  int _currentStep = 0;
  final int _totalSteps = 4;
  
  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _initialAmountController = TextEditingController();
  
  // Form data
  SavingsGoalCategory _selectedCategory = SavingsGoalCategory.other;
  String _selectedEmoji = '💰';
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  SavingsPlanType _planType = SavingsPlanType.fixed;
  SavingsPlanFrequency _planFrequency = SavingsPlanFrequency.monthly;
  bool _enableAutoSave = false;
  double? _fixedAmount;

  final Map<SavingsGoalCategory, List<String>> _categoryEmojis = {
    SavingsGoalCategory.emergency: ['🚨', '⛑️', '🆘', '🛡️'],
    SavingsGoalCategory.vacation: ['🏖️', '✈️', '🌴', '🗺️'],
    SavingsGoalCategory.house: ['🏠', '🏡', '🏘️', '🔑'],
    SavingsGoalCategory.car: ['🚗', '🚙', '🚘', '🏎️'],
    SavingsGoalCategory.education: ['🎓', '📚', '🎒', '✏️'],
    SavingsGoalCategory.wedding: ['💒', '💍', '👰', '🤵'],
    SavingsGoalCategory.retirement: ['👴', '👵', '🏖️', '⛳'],
    SavingsGoalCategory.health: ['🏥', '💊', '🩺', '💉'],
    SavingsGoalCategory.technology: ['💻', '📱', '⌚', '🎮'],
    SavingsGoalCategory.gift: ['🎁', '🎉', '🎈', '💝'],
    SavingsGoalCategory.debt: ['💳', '💰', '🏦', '📄'],
    SavingsGoalCategory.investment: ['📈', '💹', '🏛️', '💎'],
    SavingsGoalCategory.other: ['💰', '🎯', '⭐', '🔮'],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _initialAmountController.text = '0';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _initialAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          _buildHeader(),
          
          // Progress indicator
          _buildProgressIndicator(),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildBasicInfoStep(),
                _buildCategoryStep(),
                _buildTargetStep(),
                _buildPlanStep(),
              ],
            ),
          ),
          
          // Bottom navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
          Expanded(
            child: Text(
              'Yeni Tasarruf Hedefi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hedef Bilgileri',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tasarruf hedefinin temel bilgilerini girin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Hedef Adı *',
              hintText: 'örn: Yaz Tatili',
              prefixIcon: Icon(Icons.flag),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Açıklama (isteğe bağlı)',
              hintText: 'Hedefin hakkında kısa bir açıklama',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ).animate()
       .slideX(begin: 1, duration: 400.ms)
       .fadeIn(duration: 400.ms),
    );
  }

  Widget _buildCategoryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori ve Emoji',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hedefin için uygun kategori ve emoji seç',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Category selection
          Text(
            'Kategori',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            height: 300, // Fixed height to prevent overflow
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: SavingsGoalCategory.values.length,
              itemBuilder: (context, index) {
                final category = SavingsGoalCategory.values[index];
                final isSelected = category == _selectedCategory;
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _selectedEmoji = _categoryEmojis[category]!.first;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.grey[100],
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getCategoryName(category),
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Emoji selection
          Text(
            'Emoji',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 12,
            children: _categoryEmojis[_selectedCategory]!.map((emoji) {
              final isSelected = emoji == _selectedEmoji;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedEmoji = emoji;
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.grey[100],
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ).animate()
       .slideX(begin: 1, duration: 400.ms)
       .fadeIn(duration: 400.ms),
    );
  }

  Widget _buildTargetStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hedef ve Tarih',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ne kadar biriktirmek istiyorsun ve ne zamana kadar?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          TextField(
            controller: _targetAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Hedef Miktar (₺) *',
              hintText: '10000',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _initialAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Başlangıç Miktarı (₺)',
              hintText: '0',
              prefixIcon: Icon(Icons.savings),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          InkWell(
            onTap: () => _selectTargetDate(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hedef Tarihi',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ).animate()
       .slideX(begin: 1, duration: 400.ms)
       .fadeIn(duration: 400.ms),
    );
  }

  Widget _buildPlanStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasarruf Planı',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nasıl tasarruf yapmak istiyorsun?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Plan type
          Row(
            children: [
              Expanded(
                child: _buildPlanTypeCard(
                  'Sabit Miktar',
                  'Düzenli olarak belirli bir miktar',
                  Icons.schedule,
                  SavingsPlanType.fixed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlanTypeCard(
                  'Esnek',
                  'İstediğin zaman istediğin kadar',
                  Icons.gesture,
                  SavingsPlanType.flexible,
                ),
              ),
            ],
          ),
          
          if (_planType == SavingsPlanType.fixed) ...[
            const SizedBox(height: 16),
            
            // Frequency selection
            Text(
              'Sıklık',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              children: SavingsPlanFrequency.values.map((frequency) {
                final isSelected = frequency == _planFrequency;
                return ChoiceChip(
                  label: Text(_getFrequencyName(frequency)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _planFrequency = frequency;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Calculate suggested amount
            if (_targetAmountController.text.isNotEmpty) ...[
              _buildSuggestedAmountCard(),
              const SizedBox(height: 16),
            ],
          ],
          
          // Auto-save option
          SwitchListTile(
            title: const Text('Otomatik Tasarruf'),
            subtitle: const Text('Belirlenen miktar otomatik olarak ayrılsın'),
            value: _enableAutoSave,
            onChanged: (value) {
              setState(() {
                _enableAutoSave = value;
              });
            },
          ),
        ],
      ).animate()
       .slideX(begin: 1, duration: 400.ms)
       .fadeIn(duration: 400.ms),
    );
  }

  Widget _buildPlanTypeCard(String title, String subtitle, IconData icon, SavingsPlanType type) {
    final isSelected = type == _planType;
    
    return InkWell(
      onTap: () {
        setState(() {
          _planType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[100],
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedAmountCard() {
    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;
    final initialAmount = double.tryParse(_initialAmountController.text) ?? 0;
    final remainingAmount = targetAmount - initialAmount;
    
    if (remainingAmount <= 0) return const SizedBox.shrink();
    
    final daysRemaining = _targetDate.difference(DateTime.now()).inDays;
    if (daysRemaining <= 0) return const SizedBox.shrink();
    
    double suggestedAmount = 0;
    String frequencyText = '';
    
    switch (_planFrequency) {
      case SavingsPlanFrequency.daily:
        suggestedAmount = remainingAmount / daysRemaining;
        frequencyText = 'günlük';
        break;
      case SavingsPlanFrequency.weekly:
        suggestedAmount = remainingAmount / (daysRemaining / 7);
        frequencyText = 'haftalık';
        break;
      case SavingsPlanFrequency.biweekly:
        suggestedAmount = remainingAmount / (daysRemaining / 14);
        frequencyText = '2 haftada bir';
        break;
      case SavingsPlanFrequency.monthly:
        suggestedAmount = remainingAmount / (daysRemaining / 30);
        frequencyText = 'aylık';
        break;
      case SavingsPlanFrequency.quarterly:
        suggestedAmount = remainingAmount / (daysRemaining / 90);
        frequencyText = '3 ayda bir';
        break;
    }
    
    _fixedAmount = suggestedAmount;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Önerilen Miktar',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₺${suggestedAmount.toStringAsFixed(0)} $frequencyText',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hedefine ulaşmak için önerilen miktar',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Geri'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == _totalSteps - 1
                  ? _createGoal
                  : _nextStep,
              child: Text(
                _currentStep == _totalSteps - 1
                    ? 'Hedef Oluştur'
                    : 'İleri',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_titleController.text.trim().isEmpty) {
          _showErrorDialog('Lütfen hedef adını girin');
          return false;
        }
        break;
      case 2:
        if (_targetAmountController.text.trim().isEmpty) {
          _showErrorDialog('Lütfen hedef miktarını girin');
          return false;
        }
        final targetAmount = double.tryParse(_targetAmountController.text);
        if (targetAmount == null || targetAmount <= 0) {
          _showErrorDialog('Geçerli bir hedef miktarı girin');
          return false;
        }
        final initialAmount = double.tryParse(_initialAmountController.text) ?? 0;
        if (initialAmount < 0) {
          _showErrorDialog('Başlangıç miktarı negatif olamaz');
          return false;
        }
        if (initialAmount >= targetAmount) {
          _showErrorDialog('Başlangıç miktarı hedef miktarından küçük olmalı');
          return false;
        }
        break;
    }
    return true;
  }

  void _createGoal() async {
    if (!_validateCurrentStep()) return;
    
    final targetAmount = double.tryParse(_targetAmountController.text);
    final initialAmount = double.tryParse(_initialAmountController.text) ?? 0;
    
    if (targetAmount == null) return;
    
    final params = CreateSavingsGoalParams(
      userId: 'user_1', // TODO: Get from auth
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      targetAmount: targetAmount,
      currentAmount: initialAmount,
      targetDate: _targetDate,
      category: _selectedCategory,
      emoji: _selectedEmoji,
      enableAutoSave: _enableAutoSave,
      customPlan: _planType == SavingsPlanType.fixed
          ? SavingsPlan(
              type: _planType,
              fixedAmount: _fixedAmount,
              frequency: _planFrequency,
              autoSave: _enableAutoSave,
            )
          : SavingsPlan(
              type: _planType,
              frequency: SavingsPlanFrequency.monthly,
              autoSave: false,
            ),
    );
    
    try {
      await ref.read(savingsGoalProvider.notifier).createGoal(params);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tasarruf hedefi başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Hedef oluşturulurken hata oluştu: $e');
      }
    }
  }

  void _selectTargetDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(SavingsGoalCategory category) {
    switch (category) {
      case SavingsGoalCategory.emergency:
        return 'Acil Durum';
      case SavingsGoalCategory.vacation:
        return 'Tatil';
      case SavingsGoalCategory.house:
        return 'Ev';
      case SavingsGoalCategory.car:
        return 'Araba';
      case SavingsGoalCategory.education:
        return 'Eğitim';
      case SavingsGoalCategory.wedding:
        return 'Düğün';
      case SavingsGoalCategory.retirement:
        return 'Emeklilik';
      case SavingsGoalCategory.health:
        return 'Sağlık';
      case SavingsGoalCategory.technology:
        return 'Teknoloji';
      case SavingsGoalCategory.gift:
        return 'Hediye';
      case SavingsGoalCategory.debt:
        return 'Borç';
      case SavingsGoalCategory.investment:
        return 'Yatırım';
      case SavingsGoalCategory.other:
        return 'Diğer';
    }
  }

  String _getFrequencyName(SavingsPlanFrequency frequency) {
    switch (frequency) {
      case SavingsPlanFrequency.daily:
        return 'Günlük';
      case SavingsPlanFrequency.weekly:
        return 'Haftalık';
      case SavingsPlanFrequency.biweekly:
        return '2 Haftalık';
      case SavingsPlanFrequency.monthly:
        return 'Aylık';
      case SavingsPlanFrequency.quarterly:
        return '3 Aylık';
    }
  }
}