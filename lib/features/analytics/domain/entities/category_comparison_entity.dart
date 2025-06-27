import 'package:equatable/equatable.dart';
import 'trend_analytics_entity.dart' show TrendDirection;

class CategoryComparisonEntity extends Equatable {
  final String comparisonId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<CategoryData> categories;
  final ComparisonSummary summary;
  final List<CategoryInsight> insights;
  final ComparisonType type;

  const CategoryComparisonEntity({
    required this.comparisonId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.categories,
    required this.summary,
    required this.insights,
    required this.type,
  });

  @override
  List<Object?> get props => [
        comparisonId,
        title,
        startDate,
        endDate,
        categories,
        summary,
        insights,
        type,
      ];
}

class CategoryData extends Equatable {
  final String categoryId;
  final String categoryName;
  final String? iconName;
  final int colorValue;
  final double totalAmount;
  final int transactionCount;
  final double averageAmount;
  final double percentage;
  final List<SubcategoryData> subcategories;
  final List<TimeSeriesPoint> timeSeries;
  final CategoryTrend trend;

  const CategoryData({
    required this.categoryId,
    required this.categoryName,
    this.iconName,
    required this.colorValue,
    required this.totalAmount,
    required this.transactionCount,
    required this.averageAmount,
    required this.percentage,
    required this.subcategories,
    required this.timeSeries,
    required this.trend,
  });

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        iconName,
        colorValue,
        totalAmount,
        transactionCount,
        averageAmount,
        percentage,
        subcategories,
        timeSeries,
        trend,
      ];
}

class SubcategoryData extends Equatable {
  final String subcategoryId;
  final String subcategoryName;
  final double amount;
  final double percentage;
  final int transactionCount;

  const SubcategoryData({
    required this.subcategoryId,
    required this.subcategoryName,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
        subcategoryId,
        subcategoryName,
        amount,
        percentage,
        transactionCount,
      ];
}

class TimeSeriesPoint extends Equatable {
  final DateTime date;
  final double amount;
  final int transactionCount;

  const TimeSeriesPoint({
    required this.date,
    required this.amount,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [date, amount, transactionCount];
}

class CategoryTrend extends Equatable {
  final TrendDirection direction;
  final double changePercentage;
  final double slope;
  final String description;

  const CategoryTrend({
    required this.direction,
    required this.changePercentage,
    required this.slope,
    required this.description,
  });

  @override
  List<Object?> get props => [direction, changePercentage, slope, description];
}

// TrendDirection enum moved to shared location to avoid conflicts
// Using the same enum from trend_analytics_entity.dart

class ComparisonSummary extends Equatable {
  final double totalAmount;
  final int totalTransactions;
  final String dominantCategoryId;
  final double dominantPercentage;
  final double averagePerCategory;
  final double standardDeviation;
  final List<CategoryRanking> rankings;

  const ComparisonSummary({
    required this.totalAmount,
    required this.totalTransactions,
    required this.dominantCategoryId,
    required this.dominantPercentage,
    required this.averagePerCategory,
    required this.standardDeviation,
    required this.rankings,
  });

  @override
  List<Object?> get props => [
        totalAmount,
        totalTransactions,
        dominantCategoryId,
        dominantPercentage,
        averagePerCategory,
        standardDeviation,
        rankings,
      ];
}

class CategoryRanking extends Equatable {
  final String categoryId;
  final String categoryName;
  final int rank;
  final double amount;
  final double percentage;
  final RankingChange change;

  const CategoryRanking({
    required this.categoryId,
    required this.categoryName,
    required this.rank,
    required this.amount,
    required this.percentage,
    required this.change,
  });

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        rank,
        amount,
        percentage,
        change,
      ];
}

enum RankingChange {
  up,
  down,
  same,
  new_entry,
}

class CategoryInsight extends Equatable {
  final CategoryInsightType type;
  final String title;
  final String description;
  final String? actionText;
  final List<String> affectedCategoryIds;
  final double? relevantAmount;
  final double? relevantPercentage;

  const CategoryInsight({
    required this.type,
    required this.title,
    required this.description,
    this.actionText,
    required this.affectedCategoryIds,
    this.relevantAmount,
    this.relevantPercentage,
  });

  @override
  List<Object?> get props => [
        type,
        title,
        description,
        actionText,
        affectedCategoryIds,
        relevantAmount,
        relevantPercentage,
      ];
}

enum CategoryInsightType {
  dominance,
  balance,
  imbalance,
  newCategory,
  categoryGrowth,
  categoryDecline,
  seasonalPattern,
  unusualActivity,
  costEfficiency,
  budgetAlert,
}

enum ComparisonType {
  pie,
  bar,
  line,
  stacked,
  radar,
}

class ComparisonFilter extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final List<String> selectedCategoryIds;
  final ComparisonType chartType;
  final String groupBy; // 'month', 'week', 'quarter'
  final bool includeSubcategories;
  final int maxCategories;

  const ComparisonFilter({
    required this.startDate,
    required this.endDate,
    required this.selectedCategoryIds,
    required this.chartType,
    required this.groupBy,
    required this.includeSubcategories,
    required this.maxCategories,
  });

  ComparisonFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? selectedCategoryIds,
    ComparisonType? chartType,
    String? groupBy,
    bool? includeSubcategories,
    int? maxCategories,
  }) {
    return ComparisonFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      chartType: chartType ?? this.chartType,
      groupBy: groupBy ?? this.groupBy,
      includeSubcategories: includeSubcategories ?? this.includeSubcategories,
      maxCategories: maxCategories ?? this.maxCategories,
    );
  }

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        selectedCategoryIds,
        chartType,
        groupBy,
        includeSubcategories,
        maxCategories,
      ];
}

class CategoryComparisonParams extends Equatable {
  final ComparisonFilter filter;
  final List<String>? specificCategoryIds;
  final bool calculateTrends;
  final bool includeInsights;

  const CategoryComparisonParams({
    required this.filter,
    this.specificCategoryIds,
    this.calculateTrends = true,
    this.includeInsights = true,
  });

  @override
  List<Object?> get props => [
        filter,
        specificCategoryIds,
        calculateTrends,
        includeInsights,
      ];
}