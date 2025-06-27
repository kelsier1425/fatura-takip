import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/trend_analytics_entity.dart';
import '../../domain/usecases/calculate_trend_analytics_usecase.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../categories/data/datasources/default_categories.dart';

enum TrendAnalyticsStatus {
  initial,
  loading,
  loaded,
  error,
}

class TrendAnalyticsState {
  final TrendAnalyticsStatus status;
  final TrendAnalyticsEntity? trendData;
  final String? errorMessage;
  final String currentPeriod;
  final String currentChartType;

  const TrendAnalyticsState({
    required this.status,
    this.trendData,
    this.errorMessage,
    this.currentPeriod = 'monthly',
    this.currentChartType = 'line',
  });

  TrendAnalyticsState copyWith({
    TrendAnalyticsStatus? status,
    TrendAnalyticsEntity? trendData,
    String? errorMessage,
    String? currentPeriod,
    String? currentChartType,
  }) {
    return TrendAnalyticsState(
      status: status ?? this.status,
      trendData: trendData ?? this.trendData,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      currentChartType: currentChartType ?? this.currentChartType,
    );
  }
}

class TrendAnalyticsNotifier extends StateNotifier<TrendAnalyticsState> {
  final CalculateTrendAnalyticsUseCase _calculateTrendUseCase;
  final Ref _ref;

  TrendAnalyticsNotifier(this._calculateTrendUseCase, this._ref)
      : super(const TrendAnalyticsState(status: TrendAnalyticsStatus.initial));

  Future<void> loadTrendAnalytics({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(status: TrendAnalyticsStatus.loading);

    try {
      final expenseState = _ref.read(expenseProvider);
      final expenses = expenseState.expenses;
      final categories = DefaultCategories.getDefaultCategories();

      // Default period settings
      final selectedPeriod = period ?? state.currentPeriod;
      final now = DateTime.now();
      
      DateTime filterStartDate;
      DateTime filterEndDate;
      int periodCount;

      switch (selectedPeriod) {
        case 'monthly':
          filterStartDate = startDate ?? DateTime(now.year, now.month - 11, 1);
          filterEndDate = endDate ?? DateTime(now.year, now.month + 1, 0);
          periodCount = 12;
          break;
        case 'weekly':
          filterStartDate = startDate ?? now.subtract(const Duration(days: 70)); // ~10 weeks
          filterEndDate = endDate ?? now;
          periodCount = 10;
          break;
        case 'yearly':
          filterStartDate = startDate ?? DateTime(now.year - 4, 1, 1);
          filterEndDate = endDate ?? DateTime(now.year, 12, 31);
          periodCount = 5;
          break;
        default:
          filterStartDate = DateTime(now.year, now.month - 11, 1);
          filterEndDate = DateTime(now.year, now.month + 1, 0);
          periodCount = 12;
      }

      final filter = PeriodFilter(
        startDate: filterStartDate,
        endDate: filterEndDate,
        periodType: selectedPeriod,
        periodCount: periodCount,
      );

      final params = CalculateTrendParams(
        expenses: expenses,
        categories: categories,
        filter: filter,
      );

      final trendData = await _calculateTrendUseCase.execute(params);

      state = state.copyWith(
        status: TrendAnalyticsStatus.loaded,
        trendData: trendData,
        currentPeriod: selectedPeriod,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: TrendAnalyticsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void changePeriod(String period) {
    if (period != state.currentPeriod) {
      loadTrendAnalytics(period: period);
    }
  }

  void changeChartType(String chartType) {
    state = state.copyWith(currentChartType: chartType);
  }

  Future<void> refreshData() async {
    await loadTrendAnalytics();
  }

  // Belirli bir kategori için trend analizi
  Future<void> loadCategoryTrend(String categoryId) async {
    state = state.copyWith(status: TrendAnalyticsStatus.loading);

    try {
      final expenseState = _ref.read(expenseProvider);
      final allExpenses = expenseState.expenses;
      
      // Sadece belirli kategorideki harcamaları filtrele
      final categoryExpenses = allExpenses
          .where((expense) => expense.categoryId == categoryId)
          .toList();

      final categories = DefaultCategories.getDefaultCategories();
      final now = DateTime.now();

      final filter = PeriodFilter(
        startDate: DateTime(now.year, now.month - 11, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        periodType: state.currentPeriod,
        periodCount: 12,
      );

      final params = CalculateTrendParams(
        expenses: categoryExpenses,
        categories: categories,
        filter: filter,
      );

      final trendData = await _calculateTrendUseCase.execute(params);

      state = state.copyWith(
        status: TrendAnalyticsStatus.loaded,
        trendData: trendData,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: TrendAnalyticsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Comparison analizi için
  Future<TrendAnalyticsEntity?> getComparisonData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenseState = _ref.read(expenseProvider);
      final expenses = expenseState.expenses;
      final categories = DefaultCategories.getDefaultCategories();

      final filter = PeriodFilter(
        startDate: startDate,
        endDate: endDate,
        periodType: state.currentPeriod,
        periodCount: 12,
      );

      final params = CalculateTrendParams(
        expenses: expenses,
        categories: categories,
        filter: filter,
      );

      return await _calculateTrendUseCase.execute(params);
    } catch (e) {
      return null;
    }
  }
}

// Provider
final trendAnalyticsProvider = StateNotifierProvider<TrendAnalyticsNotifier, TrendAnalyticsState>((ref) {
  return TrendAnalyticsNotifier(
    CalculateTrendAnalyticsUseCase(),
    ref,
  );
});

// Helper providers
final currentTrendDataProvider = Provider<TrendAnalyticsEntity?>((ref) {
  final state = ref.watch(trendAnalyticsProvider);
  return state.trendData;
});

final trendInsightsProvider = Provider<List<TrendInsight>>((ref) {
  final trendData = ref.watch(currentTrendDataProvider);
  return trendData?.insights ?? [];
});

final trendSummaryProvider = Provider<TrendSummary?>((ref) {
  final trendData = ref.watch(currentTrendDataProvider);
  return trendData?.summary;
});