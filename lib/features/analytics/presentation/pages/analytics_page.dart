import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/monthly_trend_chart.dart';
import '../widgets/advanced_trend_chart.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/expense_summary_stats.dart';
import '../../../categories/data/datasources/default_categories.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../providers/trend_analytics_provider.dart';
import '../providers/category_comparison_provider.dart';
import '../../domain/entities/trend_analytics_entity.dart';
import '../../domain/entities/category_comparison_entity.dart';
import '../widgets/category_comparison_chart.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Bu Ay';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Tab değişikliklerini dinle
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Kategoriler sekmesine geçince veri yükle
        if (_tabController.index == 1) {
          ref.read(categoryComparisonProvider.notifier).loadCategoryComparison();
        }
        // Trendler sekmesine geçince veri yükle
        else if (_tabController.index == 2) {
          ref.read(trendAnalyticsProvider.notifier).loadTrendAnalytics();
        }
      }
    });
    
    // Analytics'leri yükle
    Future.microtask(() {
      ref.read(trendAnalyticsProvider.notifier).loadTrendAnalytics();
      ref.read(categoryComparisonProvider.notifier).loadCategoryComparison();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    try {
      // Analytics'leri yenile
      await Future.wait([
        ref.read(trendAnalyticsProvider.notifier).loadTrendAnalytics(),
        ref.read(categoryComparisonProvider.notifier).loadCategoryComparison(),
      ]);
    } catch (e) {
      // Hata durumunda kullanıcıya bildirim gösterilebilir
      debugPrint('Analytics yükleme hatası: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Analizler'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          actions: [
            PopupMenuButton<String>(
              initialValue: _selectedPeriod,
              onSelected: (value) {
                setState(() => _selectedPeriod = value);
                _loadAnalyticsData();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Bu Hafta', child: Text('Bu Hafta')),
                const PopupMenuItem(value: 'Bu Ay', child: Text('Bu Ay')),
                const PopupMenuItem(value: 'Son 3 Ay', child: Text('Son 3 Ay')),
                const PopupMenuItem(value: 'Bu Yıl', child: Text('Bu Yıl')),
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
                    Text(
                      _selectedPeriod,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Genel Bakış'),
              Tab(text: 'Kategoriler'),
              Tab(text: 'Trendler'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildCategoriesTab(),
            _buildTrendsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final expenseState = ref.watch(expenseProvider);
    final categories = DefaultCategories.getDefaultCategories();
    final expenses = expenseState.expenses;
    
    // Kategorilere göre harcamaları grupla ve sırala
    final categoryExpenses = <String, double>{};
    
    for (final expense in expenses) {
      final category = categories.firstWhere(
        (cat) => cat.id == expense.categoryId,
        orElse: () => categories.first,
      );
      
      categoryExpenses[category.id] = 
          (categoryExpenses[category.id] ?? 0) + expense.amount;
    }
    
    // En çok harcanan kategorileri al (top 5)
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topCategories = sortedCategories.take(5).toList();
    final totalExpense = categoryExpenses.values.fold(0.0, (sum, amount) => sum + amount);
    
    return RefreshIndicator(
      onRefresh: _loadAnalyticsData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ExpenseSummaryStats().animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 24),
            Text(
              'Harcama Dağılımı',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: const ExpensePieChart()
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 100.ms),
            ),
            const SizedBox(height: 24),
            Text(
              'En Çok Harcama Yapılan Kategoriler',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            if (topCategories.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Henüz harcama bulunamadı',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...topCategories.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final categoryEntry = entry.value;
                  final category = categories.firstWhere(
                    (cat) => cat.id == categoryEntry.key,
                    orElse: () => categories.first,
                  );
                  final amount = categoryEntry.value;
                  final percentage = totalExpense > 0 ? (amount / totalExpense) * 100 : 0.0;
                  
                  return CategoryBreakdownCard(
                    categoryName: category.name,
                    amount: amount,
                    percentage: percentage,
                    color: AppColors.chartColors[index % AppColors.chartColors.length],
                  ).animate().slideX(
                        begin: 0.2,
                        duration: 300.ms,
                        delay: Duration(milliseconds: 200 + (index * 50)),
                      );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return RefreshIndicator(
      onRefresh: _loadAnalyticsData,
      child: Consumer(
        builder: (context, ref, child) {
          final comparisonState = ref.watch(categoryComparisonProvider);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart type and filter controls
                _buildCategoryControls(ref),
                const SizedBox(height: 16),
                
                // Main comparison chart
                if (comparisonState.status == CategoryComparisonStatus.loaded && 
                    comparisonState.comparisonData != null &&
                    comparisonState.comparisonData!.categories.isNotEmpty)
                  CategoryComparisonChart(
                    key: ValueKey(comparisonState.comparisonData!.type),
                    comparisonData: comparisonState.comparisonData!,
                    onChartTypeChange: () {
                      _cycleCategoryChartType(ref, comparisonState.comparisonData!.type);
                    },
                    onCategorySelect: (categoryId) {
                      // Handle category selection for detailed view without losing data
                      print('Kategori seçildi: $categoryId');
                    },
                  ).animate().fadeIn(duration: 300.ms)
                else if (comparisonState.status == CategoryComparisonStatus.loading)
                  const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (comparisonState.status == CategoryComparisonStatus.error)
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Kategori karşılaştırması yüklenirken hata oluştu',
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => ref.read(categoryComparisonProvider.notifier).refreshData(),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Kategori karşılaştırması için yeterli veri bulunamadı',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                const SizedBox(height: 16),
                
                // Category rankings and additional details
                if (comparisonState.status == CategoryComparisonStatus.loaded && 
                    comparisonState.comparisonData != null)
                  _buildCategoryRankings(comparisonState.comparisonData!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryControls(WidgetRef ref) {
    final comparisonState = ref.watch(categoryComparisonProvider);
    
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.getCardBorderColor(context),
              ),
            ),
            child: Row(
              children: [
                _buildGroupByButton('Aylık', 'month', comparisonState.currentFilter.groupBy, ref),
                _buildGroupByButton('Haftalık', 'week', comparisonState.currentFilter.groupBy, ref),
                _buildGroupByButton('Çeyreklik', 'quarter', comparisonState.currentFilter.groupBy, ref),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(categoryComparisonProvider.notifier).compareTopCategories(count: 5);
          },
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: const Text('Top 5'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGroupByButton(String label, String groupBy, String currentGroupBy, WidgetRef ref) {
    final isSelected = groupBy == currentGroupBy;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(categoryComparisonProvider.notifier).changeGroupBy(groupBy);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? Colors.white : AppColors.getTextSecondaryColor(context),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  void _cycleCategoryChartType(WidgetRef ref, ComparisonType currentType) {
    const types = [ComparisonType.pie, ComparisonType.bar, ComparisonType.line];
    final currentIndex = types.indexOf(currentType);
    final nextIndex = (currentIndex + 1) % types.length;
    ref.read(categoryComparisonProvider.notifier).changeChartType(types[nextIndex]);
  }
  
  Widget _buildCategoryRankings(CategoryComparisonEntity comparisonData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Sıralaması',
          style: AppTextStyles.titleLarge,
        ),
        const SizedBox(height: 12),
        
        ...comparisonData.summary.rankings.take(5).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final ranking = entry.value;
          final categoryData = comparisonData.categories.firstWhere(
            (cat) => cat.categoryId == ranking.categoryId,
            orElse: () => comparisonData.categories.first,
          );
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getRankingColor(ranking.rank),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${ranking.rank}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(categoryData.colorValue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(categoryData.iconName),
                      color: Color(categoryData.colorValue),
                      size: 20,
                    ),
                  ),
                ],
              ),
              title: Text(
                ranking.categoryName,
                style: AppTextStyles.titleMedium,
              ),
              subtitle: Text(
                '${categoryData.transactionCount} işlem • ${ranking.percentage.toStringAsFixed(1)}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.getTextSecondaryColor(context),
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₺${ranking.amount.toStringAsFixed(0)}',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Color(categoryData.colorValue),
                    ),
                  ),
                  if (categoryData.trend.direction != TrendDirection.stable)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          categoryData.trend.direction == TrendDirection.increasing
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 16,
                          color: categoryData.trend.direction == TrendDirection.increasing
                              ? AppColors.error
                              : AppColors.success,
                        ),
                        Text(
                          '${categoryData.trend.changePercentage.abs().toStringAsFixed(1)}%',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: categoryData.trend.direction == TrendDirection.increasing
                                ? AppColors.error
                                : AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ).animate().slideX(
            begin: 0.3,
            duration: 300.ms,
            delay: Duration(milliseconds: index * 100),
          );
        }).toList(),
      ],
    );
  }
  
  Color _getRankingColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.primary;
    }
  }
  
  IconData _getCategoryIcon(String? iconName) {
    // Simple icon mapping - you can expand this
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'restaurant':
        return Icons.restaurant;
      case 'car':
        return Icons.directions_car;
      case 'health':
        return Icons.health_and_safety;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  Widget _buildTrendsTab() {
    return RefreshIndicator(
      onRefresh: _loadAnalyticsData,
      child: Consumer(
        builder: (context, ref, child) {
          final trendState = ref.watch(trendAnalyticsProvider);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period selector
                _buildPeriodSelector(ref),
                const SizedBox(height: 16),
                
                // Main trend chart
                if (trendState.status == TrendAnalyticsStatus.loaded && trendState.trendData != null)
                  AdvancedTrendChart(
                    trendData: trendState.trendData!,
                    chartType: trendState.currentChartType,
                    onPeriodTap: () {
                      // Chart type cycling
                      final types = ['line', 'bar', 'area'];
                      final currentIndex = types.indexOf(trendState.currentChartType);
                      final nextIndex = (currentIndex + 1) % types.length;
                      ref.read(trendAnalyticsProvider.notifier).changeChartType(types[nextIndex]);
                    },
                  ).animate().fadeIn(duration: 300.ms)
                else if (trendState.status == TrendAnalyticsStatus.loading)
                  const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (trendState.status == TrendAnalyticsStatus.error)
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Trend analizi yüklenirken hata oluştu',
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => ref.read(trendAnalyticsProvider.notifier).refreshData(),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Trend analizi için yeterli veri bulunamadı',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Additional insights from old chart
                if (trendState.status == TrendAnalyticsStatus.loaded && trendState.trendData != null) ...[
                  _buildQuickInsights(trendState.trendData!),
                ] else ...[
                  // Fallback legacy insights
                  _buildInsightCard(
                    'En Çok Artış Gösteren',
                    'Market Alışverişi',
                    '+23%',
                    Icons.trending_up,
                    AppColors.error,
                  ).animate().slideX(begin: 0.2, duration: 300.ms, delay: 100.ms),
                  _buildInsightCard(
                    'En Çok Azalan',
                    'Eğlence',
                    '-18%',
                    Icons.trending_down,
                    AppColors.success,
                  ).animate().slideX(begin: 0.2, duration: 300.ms, delay: 200.ms),
                  _buildInsightCard(
                    'Tahmini Ay Sonu',
                    '₺12,500',
                    'Bütçe: ₺15,000',
                    Icons.insights,
                    AppColors.info,
                  ).animate().slideX(begin: 0.2, duration: 300.ms, delay: 300.ms),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(WidgetRef ref) {
    final currentPeriod = ref.watch(trendAnalyticsProvider).currentPeriod;
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getCardBorderColor(context),
        ),
      ),
      child: Row(
        children: [
          _buildPeriodButton('Haftalık', 'weekly', currentPeriod, ref),
          _buildPeriodButton('Aylık', 'monthly', currentPeriod, ref),
          _buildPeriodButton('Yıllık', 'yearly', currentPeriod, ref),
        ],
      ),
    );
  }
  
  Widget _buildPeriodButton(String label, String period, String currentPeriod, WidgetRef ref) {
    final isSelected = period == currentPeriod;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(trendAnalyticsProvider.notifier).changePeriod(period);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.getTextSecondaryColor(context),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickInsights(TrendAnalyticsEntity trendData) {
    if (trendData.insights.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İstatistikler',
          style: AppTextStyles.titleLarge,
        ),
        const SizedBox(height: 12),
        
        // Projection insight
        _buildInsightCard(
          'Tahmini Gelecek Dönem',
          '₺${trendData.summary.projectedNextPeriod.toStringAsFixed(0)}',
          'Mevcut trend bazlı',
          Icons.insights,
          AppColors.info,
        ).animate().slideX(begin: 0.2, duration: 300.ms, delay: 100.ms),
        
        // High/Low insights
        _buildInsightCard(
          'En Yüksek Dönem',
          '₺${trendData.summary.highestAmount.toStringAsFixed(0)}',
          'Ortalama: ₺${trendData.summary.averageAmount.toStringAsFixed(0)}',
          Icons.trending_up,
          AppColors.error,
        ).animate().slideX(begin: 0.2, duration: 300.ms, delay: 200.ms),
        
        _buildInsightCard(
          'Toplam İşlem',
          '${trendData.summary.totalTransactions}',
          '${trendData.dataPoints.length} dönem',
          Icons.receipt_long,
          AppColors.success,
        ).animate().slideX(begin: 0.2, duration: 300.ms, delay: 300.ms),
      ],
    );
  }
  
  Widget _buildInsightCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.getTextSecondaryColor(context),
          ),
        ),
        subtitle: Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimaryColor(context),
          ),
        ),
        trailing: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.getTextSecondaryColor(context),
          ),
        ),
      ),
    );
  }
}