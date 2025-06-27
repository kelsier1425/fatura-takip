import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category_comparison_entity.dart';
import '../../domain/usecases/calculate_category_comparison_usecase.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../categories/data/datasources/default_categories.dart';

enum CategoryComparisonStatus {
  initial,
  loading,
  loaded,
  error,
}

class CategoryComparisonState {
  final CategoryComparisonStatus status;
  final CategoryComparisonEntity? comparisonData;
  final String? errorMessage;
  final ComparisonFilter currentFilter;
  final List<String> selectedCategoryIds;

  const CategoryComparisonState({
    required this.status,
    this.comparisonData,
    this.errorMessage,
    required this.currentFilter,
    required this.selectedCategoryIds,
  });

  CategoryComparisonState copyWith({
    CategoryComparisonStatus? status,
    CategoryComparisonEntity? comparisonData,
    String? errorMessage,
    ComparisonFilter? currentFilter,
    List<String>? selectedCategoryIds,
  }) {
    return CategoryComparisonState(
      status: status ?? this.status,
      comparisonData: comparisonData ?? this.comparisonData,
      errorMessage: errorMessage ?? this.errorMessage,
      currentFilter: currentFilter ?? this.currentFilter,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
    );
  }
}

class CategoryComparisonNotifier extends StateNotifier<CategoryComparisonState> {
  final CalculateCategoryComparisonUseCase _calculateComparisonUseCase;
  final Ref _ref;

  CategoryComparisonNotifier(this._calculateComparisonUseCase, this._ref)
      : super(CategoryComparisonState(
          status: CategoryComparisonStatus.initial,
          currentFilter: _createDefaultFilter(),
          selectedCategoryIds: [],
        ));

  static ComparisonFilter _createDefaultFilter() {
    final now = DateTime.now();
    return ComparisonFilter(
      startDate: DateTime(now.year, now.month - 2, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
      selectedCategoryIds: [],
      chartType: ComparisonType.pie,
      groupBy: 'month',
      includeSubcategories: false,
      maxCategories: 8,
    );
  }

  Future<void> loadCategoryComparison({
    ComparisonFilter? filter,
    List<String>? specificCategoryIds,
  }) async {
    state = state.copyWith(status: CategoryComparisonStatus.loading);

    try {
      final expenseState = _ref.read(expenseProvider);
      final expenses = expenseState.expenses;
      final categories = DefaultCategories.getDefaultCategories();

      // Check if we have any expenses to analyze
      if (expenses.isEmpty) {
        state = state.copyWith(
          status: CategoryComparisonStatus.loaded,
          comparisonData: null,
          errorMessage: null,
        );
        return;
      }

      final activeFilter = filter ?? state.currentFilter;
      final categoryIds = specificCategoryIds ?? state.selectedCategoryIds;

      // If no specific categories selected, use top spending categories
      List<String> targetCategoryIds = categoryIds;
      if (targetCategoryIds.isEmpty) {
        targetCategoryIds = _getTopSpendingCategories(expenses, activeFilter.maxCategories);
      }

      // Ensure we have at least some categories to compare
      if (targetCategoryIds.isEmpty) {
        state = state.copyWith(
          status: CategoryComparisonStatus.loaded,
          comparisonData: null,
          errorMessage: null,
        );
        return;
      }

      final updatedFilter = activeFilter.copyWith(
        selectedCategoryIds: targetCategoryIds,
      );

      final params = CategoryComparisonParams(
        filter: updatedFilter,
        specificCategoryIds: targetCategoryIds.isNotEmpty ? targetCategoryIds : null,
        calculateTrends: true,
        includeInsights: true,
      );

      final comparisonData = await _calculateComparisonUseCase.execute(
        params,
        expenses,
        categories,
      );

      state = state.copyWith(
        status: CategoryComparisonStatus.loaded,
        comparisonData: comparisonData,
        currentFilter: updatedFilter,
        selectedCategoryIds: targetCategoryIds,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: CategoryComparisonStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  List<String> _getTopSpendingCategories(List<ExpenseEntity> expenses, int maxCount) {
    final categoryTotals = <String, double>{};
    
    for (final expense in expenses) {
      categoryTotals[expense.categoryId] = 
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedCategories
        .take(maxCount)
        .map((entry) => entry.key)
        .toList();
  }

  void changeChartType(ComparisonType chartType) {
    final updatedFilter = state.currentFilter.copyWith(chartType: chartType);
    loadCategoryComparison(filter: updatedFilter);
  }

  void changeDateRange(DateTime startDate, DateTime endDate) {
    final updatedFilter = state.currentFilter.copyWith(
      startDate: startDate,
      endDate: endDate,
    );
    loadCategoryComparison(filter: updatedFilter);
  }

  void changeGroupBy(String groupBy) {
    final updatedFilter = state.currentFilter.copyWith(groupBy: groupBy);
    loadCategoryComparison(filter: updatedFilter);
  }

  void toggleCategorySelection(String categoryId) {
    final currentSelection = List<String>.from(state.selectedCategoryIds);
    
    if (currentSelection.contains(categoryId)) {
      currentSelection.remove(categoryId);
    } else {
      currentSelection.add(categoryId);
    }

    loadCategoryComparison(specificCategoryIds: currentSelection);
  }

  void selectCategories(List<String> categoryIds) {
    loadCategoryComparison(specificCategoryIds: categoryIds);
  }

  void clearCategorySelection() {
    loadCategoryComparison(specificCategoryIds: []);
  }

  Future<void> refreshData() async {
    await loadCategoryComparison();
  }

  // Specific comparisons
  Future<void> compareTopCategories({int count = 5}) async {
    final expenseState = _ref.read(expenseProvider);
    final expenses = expenseState.expenses;
    final topCategories = _getTopSpendingCategories(expenses, count);
    
    await loadCategoryComparison(specificCategoryIds: topCategories);
  }

  Future<void> compareCategoriesByTimeRange(
    DateTime startDate,
    DateTime endDate,
    List<String> categoryIds,
  ) async {
    final updatedFilter = state.currentFilter.copyWith(
      startDate: startDate,
      endDate: endDate,
      selectedCategoryIds: categoryIds,
    );
    
    await loadCategoryComparison(
      filter: updatedFilter,
      specificCategoryIds: categoryIds,
    );
  }

  // Analysis helpers
  Future<Map<String, dynamic>> getCategoryAnalytics(String categoryId) async {
    final comparisonData = state.comparisonData;
    if (comparisonData == null) return {};

    final categoryData = comparisonData.categories.firstWhere(
      (cat) => cat.categoryId == categoryId,
      orElse: () => throw Exception('Category not found'),
    );

    return {
      'totalAmount': categoryData.totalAmount,
      'percentage': categoryData.percentage,
      'transactionCount': categoryData.transactionCount,
      'averageAmount': categoryData.averageAmount,
      'trend': categoryData.trend,
      'subcategories': categoryData.subcategories,
      'ranking': comparisonData.summary.rankings
          .indexWhere((rank) => rank.categoryId == categoryId) + 1,
    };
  }

  CategoryData? getCategoryData(String categoryId) {
    final comparisonData = state.comparisonData;
    if (comparisonData == null) return null;

    try {
      return comparisonData.categories.firstWhere(
        (cat) => cat.categoryId == categoryId,
      );
    } catch (e) {
      return null;
    }
  }
}

// Provider
final categoryComparisonProvider = StateNotifierProvider<CategoryComparisonNotifier, CategoryComparisonState>((ref) {
  return CategoryComparisonNotifier(
    CalculateCategoryComparisonUseCase(),
    ref,
  );
});

// Helper providers
final currentComparisonDataProvider = Provider<CategoryComparisonEntity?>((ref) {
  final state = ref.watch(categoryComparisonProvider);
  return state.comparisonData;
});

final comparisonSummaryProvider = Provider<ComparisonSummary?>((ref) {
  final comparisonData = ref.watch(currentComparisonDataProvider);
  return comparisonData?.summary;
});

final comparisonInsightsProvider = Provider<List<CategoryInsight>>((ref) {
  final comparisonData = ref.watch(currentComparisonDataProvider);
  return comparisonData?.insights ?? [];
});

final topCategoriesProvider = Provider<List<CategoryData>>((ref) {
  final comparisonData = ref.watch(currentComparisonDataProvider);
  return comparisonData?.categories.take(5).toList() ?? [];
});

// Specific category provider
final categoryDataProvider = Provider.family<CategoryData?, String>((ref, categoryId) {
  final notifier = ref.read(categoryComparisonProvider.notifier);
  return notifier.getCategoryData(categoryId);
});