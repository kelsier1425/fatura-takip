import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/expense_comparison_chart.dart';
import '../widgets/category_heatmap.dart';
import '../widgets/savings_goal_tracker.dart';

class VisualizationPage extends ConsumerStatefulWidget {
  const VisualizationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<VisualizationPage> createState() => _VisualizationPageState();
}

class _VisualizationPageState extends ConsumerState<VisualizationPage> {
  bool _isLoading = false;
  String _selectedView = 'Bütçe';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // TODO: Load visualization data
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Görselleştirme'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          actions: [
            PopupMenuButton<String>(
              initialValue: _selectedView,
              onSelected: (value) {
                setState(() => _selectedView = value);
                _loadData();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Bütçe', child: Text('Bütçe Takibi')),
                const PopupMenuItem(value: 'Karşılaştırma', child: Text('Dönem Karşılaştırma')),
                const PopupMenuItem(value: 'Isı Haritası', child: Text('Kategori Isı Haritası')),
                const PopupMenuItem(value: 'Hedefler', child: Text('Birikim Hedefleri')),
              ],
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getViewIcon(),
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedView,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: _buildSelectedView(),
        ),
      ),
    );
  }

  IconData _getViewIcon() {
    switch (_selectedView) {
      case 'Bütçe':
        return Icons.account_balance_wallet;
      case 'Karşılaştırma':
        return Icons.compare_arrows;
      case 'Isı Haritası':
        return Icons.grid_on;
      case 'Hedefler':
        return Icons.flag;
      default:
        return Icons.bar_chart;
    }
  }

  Widget _buildSelectedView() {
    switch (_selectedView) {
      case 'Bütçe':
        return _buildBudgetView();
      case 'Karşılaştırma':
        return _buildComparisonView();
      case 'Isı Haritası':
        return _buildHeatmapView();
      case 'Hedefler':
        return _buildGoalsView();
      default:
        return _buildBudgetView();
    }
  }

  Widget _buildBudgetView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aylık Bütçe Durumu',
            style: AppTextStyles.headlineSmall,
          ).animate().fadeIn(),
          const SizedBox(height: 16),
          BudgetProgressCard(
            totalBudget: 15000,
            spent: 12450,
            remaining: 2550,
            daysLeft: 8,
          ).animate().slideY(begin: 0.1, duration: 300.ms),
          const SizedBox(height: 24),
          Text(
            'Kategori Bazlı Bütçe',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          ...List.generate(
            6,
            (index) => _buildCategoryBudgetItem(
              name: _getCategoryName(index),
              budget: _getCategoryBudget(index),
              spent: _getCategorySpent(index),
              color: AppColors.chartColors[index],
            ).animate().slideX(
                  begin: 0.2,
                  duration: 300.ms,
                  delay: Duration(milliseconds: 100 + (index * 50)),
                ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(int index) {
    final categories = ['Ev', 'Market', 'Ulaşım', 'Sağlık', 'Eğlence', 'Diğer'];
    return categories[index];
  }

  double _getCategoryBudget(int index) {
    final budgets = [4000.0, 3000.0, 2000.0, 1500.0, 1000.0, 3500.0];
    return budgets[index];
  }

  double _getCategorySpent(int index) {
    final spent = [3200.0, 2800.0, 1500.0, 800.0, 900.0, 3250.0];
    return spent[index];
  }

  Widget _buildCategoryBudgetItem({
    required String name,
    required double budget,
    required double spent,
    required Color color,
  }) {
    final percentage = (spent / budget).clamp(0.0, 1.0);
    final isOverBudget = spent > budget;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.category,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      name,
                      style: AppTextStyles.titleMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₺${spent.toStringAsFixed(0)} / ₺${budget.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isOverBudget ? AppColors.error : null,
                      ),
                    ),
                    Text(
                      isOverBudget
                          ? '₺${(spent - budget).toStringAsFixed(0)} fazla'
                          : '₺${(budget - spent).toStringAsFixed(0)} kaldı',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isOverBudget ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? AppColors.error : color,
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dönemsel Karşılaştırma',
            style: AppTextStyles.headlineSmall,
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Son 6 aylık harcama trendi',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: const ExpenseComparisonChart()
                .animate()
                .fadeIn(duration: 300.ms),
          ),
          const SizedBox(height: 24),
          _buildComparisonStats(),
        ],
      ),
    );
  }

  Widget _buildComparisonStats() {
    return Column(
      children: [
        _buildStatRow('En Yüksek Ay', 'Ekim 2024', '₺15,750'),
        _buildStatRow('En Düşük Ay', 'Temmuz 2024', '₺8,250'),
        _buildStatRow('Aylık Ortalama', '6 Ay', '₺11,420'),
        _buildStatRow('Toplam Harcama', '6 Ay', '₺68,520'),
      ].animate(interval: 50.ms).slideX(begin: 0.1),
    );
  }

  Widget _buildStatRow(String label, String period, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        subtitle: Text(
          period,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        trailing: Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmapView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Isı Haritası',
            style: AppTextStyles.headlineSmall,
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Günlük harcama yoğunluğu',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const CategoryHeatmap().animate().scale(duration: 300.ms),
          const SizedBox(height: 24),
          _buildHeatmapLegend(),
        ],
      ),
    );
  }

  Widget _buildHeatmapLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yoğunluk Göstergesi',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Düşük', Colors.green.shade100),
                _buildLegendItem('Orta', Colors.orange.shade300),
                _buildLegendItem('Yüksek', Colors.red.shade400),
                _buildLegendItem('Çok Yüksek', Colors.red.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildGoalsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Birikim Hedefleri',
            style: AppTextStyles.headlineSmall,
          ).animate().fadeIn(),
          const SizedBox(height: 24),
          SavingsGoalTracker(
            goalName: 'Tatil Fonu',
            targetAmount: 20000,
            currentAmount: 12500,
            deadline: DateTime.now().add(const Duration(days: 90)),
            icon: Icons.flight,
            color: AppColors.info,
          ).animate().slideY(begin: 0.1, duration: 300.ms),
          SavingsGoalTracker(
            goalName: 'Acil Durum Fonu',
            targetAmount: 50000,
            currentAmount: 35000,
            deadline: DateTime.now().add(const Duration(days: 180)),
            icon: Icons.shield,
            color: AppColors.success,
          ).animate().slideY(begin: 0.1, duration: 300.ms, delay: 100.ms),
          SavingsGoalTracker(
            goalName: 'Yeni Telefon',
            targetAmount: 15000,
            currentAmount: 8000,
            deadline: DateTime.now().add(const Duration(days: 60)),
            icon: Icons.phone_android,
            color: AppColors.primary,
          ).animate().slideY(begin: 0.1, duration: 300.ms, delay: 200.ms),
          const SizedBox(height: 24),
          _buildAddGoalButton(),
        ],
      ),
    );
  }

  Widget _buildAddGoalButton() {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to add goal page
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Yeni Hedef Ekle',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 300.ms, delay: 300.ms);
  }
}