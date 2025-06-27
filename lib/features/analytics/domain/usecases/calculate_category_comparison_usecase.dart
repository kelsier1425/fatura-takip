import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../entities/category_comparison_entity.dart';
import '../entities/trend_analytics_entity.dart' show TrendDirection;
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';

class CalculateCategoryComparisonUseCase {
  
  Future<CategoryComparisonEntity> execute(
    CategoryComparisonParams params,
    List<ExpenseEntity> expenses,
    List<CategoryEntity> categories,
  ) async {
    // Filter expenses by date range
    final filteredExpenses = _filterExpensesByDateRange(
      expenses,
      params.filter.startDate,
      params.filter.endDate,
    );

    // Group expenses by categories
    final categoryGroups = _groupExpensesByCategory(
      filteredExpenses,
      categories,
      params.filter.selectedCategoryIds,
    );

    // Calculate category data
    final categoryDataList = await _calculateCategoryData(
      categoryGroups,
      categories,
      params.filter,
      params.calculateTrends,
    );

    // Calculate comparison summary
    final summary = _calculateComparisonSummary(categoryDataList, filteredExpenses);

    // Generate insights
    final insights = params.includeInsights
        ? _generateCategoryInsights(categoryDataList, summary)
        : <CategoryInsight>[];

    return CategoryComparisonEntity(
      comparisonId: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _generateComparisonTitle(params.filter),
      startDate: params.filter.startDate,
      endDate: params.filter.endDate,
      categories: categoryDataList,
      summary: summary,
      insights: insights,
      type: params.filter.chartType,
    );
  }

  List<ExpenseEntity> _filterExpensesByDateRange(
    List<ExpenseEntity> expenses,
    DateTime startDate,
    DateTime endDate,
  ) {
    return expenses.where((expense) {
      return expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             expense.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Map<String, List<ExpenseEntity>> _groupExpensesByCategory(
    List<ExpenseEntity> expenses,
    List<CategoryEntity> categories,
    List<String> selectedCategoryIds,
  ) {
    final Map<String, List<ExpenseEntity>> groups = {};

    // Initialize groups for selected categories
    for (final categoryId in selectedCategoryIds.isEmpty 
        ? categories.map((c) => c.id).toList() 
        : selectedCategoryIds) {
      groups[categoryId] = [];
    }

    // Group expenses
    for (final expense in expenses) {
      if (groups.containsKey(expense.categoryId)) {
        groups[expense.categoryId]!.add(expense);
      }
    }

    // Remove empty categories if no specific selection
    if (selectedCategoryIds.isEmpty) {
      groups.removeWhere((key, value) => value.isEmpty);
    }

    return groups;
  }

  Future<List<CategoryData>> _calculateCategoryData(
    Map<String, List<ExpenseEntity>> categoryGroups,
    List<CategoryEntity> categories,
    ComparisonFilter filter,
    bool calculateTrends,
  ) async {
    final List<CategoryData> categoryDataList = [];
    final totalAmount = categoryGroups.values
        .expand((expenses) => expenses)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    for (final entry in categoryGroups.entries) {
      final categoryId = entry.key;
      final expenses = entry.value;

      final category = categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => CategoryEntity(
          id: categoryId,
          name: 'Bilinmeyen Kategori',
          icon: Icons.help_outline,
          color: const Color(0xFF757575),
          type: CategoryType.personal,
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );

      final categoryTotal = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      final transactionCount = expenses.length;
      final averageAmount = transactionCount > 0 ? categoryTotal / transactionCount : 0.0;
      final percentage = totalAmount > 0 ? (categoryTotal / totalAmount) * 100 : 0.0;

      // Calculate subcategories
      final subcategories = _calculateSubcategories(expenses);

      // Calculate time series
      final timeSeries = _calculateTimeSeries(expenses, filter.groupBy);

      // Calculate trend
      final trend = calculateTrends
          ? _calculateCategoryTrend(timeSeries)
          : const CategoryTrend(
              direction: TrendDirection.stable,
              changePercentage: 0.0,
              slope: 0.0,
              description: 'Trend hesaplanmadı',
            );

      categoryDataList.add(CategoryData(
        categoryId: categoryId,
        categoryName: category.name,
        iconName: category.icon.toString(),
        colorValue: category.color.value,
        totalAmount: categoryTotal,
        transactionCount: transactionCount,
        averageAmount: averageAmount,
        percentage: percentage,
        subcategories: subcategories,
        timeSeries: timeSeries,
        trend: trend,
      ));
    }

    // Sort by total amount (descending)
    categoryDataList.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return categoryDataList;
  }

  List<SubcategoryData> _calculateSubcategories(List<ExpenseEntity> expenses) {
    final Map<String, List<ExpenseEntity>> subcategoryGroups = {};
    
    // Group by subcategory
    for (final expense in expenses) {
      final subcategoryId = expense.subcategoryId ?? 'Genel';
      if (!subcategoryGroups.containsKey(subcategoryId)) {
        subcategoryGroups[subcategoryId] = [];
      }
      subcategoryGroups[subcategoryId]!.add(expense);
    }

    final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final List<SubcategoryData> subcategories = [];

    for (final entry in subcategoryGroups.entries) {
      final subcategoryId = entry.key;
      final subcategoryExpenses = entry.value;
      final subcategoryTotal = subcategoryExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
      final subcategoryPercentage = totalAmount > 0 ? (subcategoryTotal / totalAmount) * 100 : 0.0;

      subcategories.add(SubcategoryData(
        subcategoryId: subcategoryId,
        subcategoryName: subcategoryId == 'Genel' ? 'Genel Harcamalar' : subcategoryId,
        amount: subcategoryTotal,
        percentage: subcategoryPercentage,
        transactionCount: subcategoryExpenses.length,
      ));
    }

    // Sort by amount (descending)
    subcategories.sort((a, b) => b.amount.compareTo(a.amount));

    return subcategories;
  }

  List<TimeSeriesPoint> _calculateTimeSeries(List<ExpenseEntity> expenses, String groupBy) {
    final Map<DateTime, List<ExpenseEntity>> timeGroups = {};

    for (final expense in expenses) {
      DateTime groupKey;
      
      switch (groupBy) {
        case 'month':
          groupKey = DateTime(expense.date.year, expense.date.month, 1);
          break;
        case 'week':
          final weekday = expense.date.weekday;
          final daysToSubtract = weekday == 7 ? 0 : weekday;
          groupKey = expense.date.subtract(Duration(days: daysToSubtract));
          break;
        case 'quarter':
          final quarter = ((expense.date.month - 1) ~/ 3) + 1;
          groupKey = DateTime(expense.date.year, (quarter - 1) * 3 + 1, 1);
          break;
        default:
          groupKey = DateTime(expense.date.year, expense.date.month, expense.date.day);
      }

      if (!timeGroups.containsKey(groupKey)) {
        timeGroups[groupKey] = [];
      }
      timeGroups[groupKey]!.add(expense);
    }

    final List<TimeSeriesPoint> timeSeries = [];
    final sortedKeys = timeGroups.keys.toList()..sort();

    for (final date in sortedKeys) {
      final dateExpenses = timeGroups[date]!;
      final amount = dateExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
      
      timeSeries.add(TimeSeriesPoint(
        date: date,
        amount: amount,
        transactionCount: dateExpenses.length,
      ));
    }

    return timeSeries;
  }

  CategoryTrend _calculateCategoryTrend(List<TimeSeriesPoint> timeSeries) {
    if (timeSeries.length < 2) {
      return const CategoryTrend(
        direction: TrendDirection.stable,
        changePercentage: 0.0,
        slope: 0.0,
        description: 'Yetersiz veri',
      );
    }

    // Calculate linear regression slope
    final n = timeSeries.length;
    final sumX = List.generate(n, (i) => i).fold(0, (sum, x) => sum + x).toDouble();
    final sumY = timeSeries.fold(0.0, (sum, point) => sum + point.amount);
    final sumXY = timeSeries.asMap().entries.fold(0.0, (sum, entry) => 
        sum + (entry.key * entry.value.amount));
    final sumX2 = List.generate(n, (i) => i).fold(0, (sum, x) => sum + (x * x)).toDouble();

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    // Calculate percentage change from first to last period
    final firstAmount = timeSeries.first.amount;
    final lastAmount = timeSeries.last.amount;
    final changePercentage = firstAmount != 0 
        ? ((lastAmount - firstAmount) / firstAmount) * 100 
        : 0.0;

    // Determine trend direction
    TrendDirection direction;
    String description;
    
    if (changePercentage.abs() < 5) {
      direction = TrendDirection.stable;
      description = 'Stabil harcama';
    } else if (changePercentage > 0) {
      direction = TrendDirection.increasing;
      description = 'Artan harcama trendi';
    } else {
      direction = TrendDirection.decreasing;
      description = 'Azalan harcama trendi';
    }

    return CategoryTrend(
      direction: direction,
      changePercentage: changePercentage,
      slope: slope,
      description: description,
    );
  }

  ComparisonSummary _calculateComparisonSummary(
    List<CategoryData> categoryDataList,
    List<ExpenseEntity> allExpenses,
  ) {
    if (categoryDataList.isEmpty) {
      return const ComparisonSummary(
        totalAmount: 0,
        totalTransactions: 0,
        dominantCategoryId: '',
        dominantPercentage: 0,
        averagePerCategory: 0,
        standardDeviation: 0,
        rankings: [],
      );
    }

    final totalAmount = categoryDataList.fold(0.0, (sum, cat) => sum + cat.totalAmount);
    final totalTransactions = categoryDataList.fold(0, (sum, cat) => sum + cat.transactionCount);
    final averagePerCategory = totalAmount / categoryDataList.length;

    // Find dominant category
    final dominantCategory = categoryDataList.first; // Already sorted by amount
    final dominantPercentage = dominantCategory.percentage;

    // Calculate standard deviation
    final variance = categoryDataList.fold(0.0, (sum, cat) => 
        sum + math.pow(cat.totalAmount - averagePerCategory, 2)) / categoryDataList.length;
    final standardDeviation = math.sqrt(variance);

    // Create rankings
    final rankings = categoryDataList.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryData = entry.value;
      
      return CategoryRanking(
        categoryId: categoryData.categoryId,
        categoryName: categoryData.categoryName,
        rank: index + 1,
        amount: categoryData.totalAmount,
        percentage: categoryData.percentage,
        change: RankingChange.same, // TODO: Implement comparison with previous period
      );
    }).toList();

    return ComparisonSummary(
      totalAmount: totalAmount,
      totalTransactions: totalTransactions,
      dominantCategoryId: dominantCategory.categoryId,
      dominantPercentage: dominantPercentage,
      averagePerCategory: averagePerCategory,
      standardDeviation: standardDeviation,
      rankings: rankings,
    );
  }

  List<CategoryInsight> _generateCategoryInsights(
    List<CategoryData> categoryDataList,
    ComparisonSummary summary,
  ) {
    final List<CategoryInsight> insights = [];

    // Dominance insight
    if (summary.dominantPercentage > 50) {
      final dominantCategory = categoryDataList.firstWhere(
        (cat) => cat.categoryId == summary.dominantCategoryId,
      );
      
      insights.add(CategoryInsight(
        type: CategoryInsightType.dominance,
        title: 'Dominant Kategori',
        description: '${dominantCategory.categoryName} toplam harcamanızın %${summary.dominantPercentage.toStringAsFixed(1)}\'ini oluşturuyor',
        actionText: 'Bu kategoride tasarruf yapabilirsiniz',
        affectedCategoryIds: [summary.dominantCategoryId],
        relevantPercentage: summary.dominantPercentage,
      ));
    }

    // Balance/Imbalance insight
    if (summary.standardDeviation > summary.averagePerCategory * 0.5) {
      insights.add(const CategoryInsight(
        type: CategoryInsightType.imbalance,
        title: 'Dengesiz Harcama Dağılımı',
        description: 'Kategori harcamalarınız arasında büyük farklar var',
        actionText: 'Bütçe planlaması yapın',
        affectedCategoryIds: [],
      ));
    } else {
      insights.add(const CategoryInsight(
        type: CategoryInsightType.balance,
        title: 'Dengeli Harcama',
        description: 'Kategoriler arası harcama dağılımınız dengeli',
        affectedCategoryIds: [],
      ));
    }

    // Category growth insights
    for (final categoryData in categoryDataList.take(3)) { // Top 3 categories
      if (categoryData.trend.direction == TrendDirection.increasing && 
          categoryData.trend.changePercentage > 20) {
        insights.add(CategoryInsight(
          type: CategoryInsightType.categoryGrowth,
          title: '${categoryData.categoryName} Artışı',
          description: 'Bu kategoride %${categoryData.trend.changePercentage.toStringAsFixed(1)} artış var',
          actionText: 'Kontrol altına alın',
          affectedCategoryIds: [categoryData.categoryId],
          relevantPercentage: categoryData.trend.changePercentage,
        ));
      } else if (categoryData.trend.direction == TrendDirection.decreasing && 
                 categoryData.trend.changePercentage.abs() > 15) {
        insights.add(CategoryInsight(
          type: CategoryInsightType.categoryDecline,
          title: '${categoryData.categoryName} Azalışı',
          description: 'Bu kategoride %${categoryData.trend.changePercentage.abs().toStringAsFixed(1)} azalma var',
          actionText: 'Başarıyı sürdürün',
          affectedCategoryIds: [categoryData.categoryId],
          relevantPercentage: categoryData.trend.changePercentage.abs(),
        ));
      }
    }

    // Cost efficiency insight
    final highTransactionCategories = categoryDataList
        .where((cat) => cat.transactionCount > 10 && cat.averageAmount < 100)
        .toList();
    
    if (highTransactionCategories.isNotEmpty) {
      final categoryNames = highTransactionCategories
          .take(2)
          .map((cat) => cat.categoryName)
          .join(', ');
      
      insights.add(CategoryInsight(
        type: CategoryInsightType.costEfficiency,
        title: 'Küçük Harcamalar',
        description: '$categoryNames kategorilerinde çok sayıda küçük harcama var',
        actionText: 'Harcama alışkanlıklarınızı gözden geçirin',
        affectedCategoryIds: highTransactionCategories.map((cat) => cat.categoryId).toList(),
      ));
    }

    return insights;
  }

  String _generateComparisonTitle(ComparisonFilter filter) {
    final period = _formatPeriod(filter.startDate, filter.endDate);
    final categoryCount = filter.selectedCategoryIds.isEmpty 
        ? 'Tüm Kategoriler' 
        : '${filter.selectedCategoryIds.length} Kategori';
    
    return '$categoryCount Karşılaştırması - $period';
  }

  String _formatPeriod(DateTime startDate, DateTime endDate) {
    final start = '${startDate.day}/${startDate.month}/${startDate.year}';
    final end = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$start - $end';
  }
}