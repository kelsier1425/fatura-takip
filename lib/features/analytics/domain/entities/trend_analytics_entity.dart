import 'package:equatable/equatable.dart';

class TrendAnalyticsEntity extends Equatable {
  final String period; // 'monthly', 'weekly', 'yearly'
  final List<TrendDataPoint> dataPoints;
  final TrendSummary summary;
  final List<TrendInsight> insights;
  final DateTime startDate;
  final DateTime endDate;

  const TrendAnalyticsEntity({
    required this.period,
    required this.dataPoints,
    required this.summary,
    required this.insights,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        period,
        dataPoints,
        summary,
        insights,
        startDate,
        endDate,
      ];
}

class TrendDataPoint extends Equatable {
  final DateTime date;
  final double amount;
  final int transactionCount;
  final String label; // "Oca", "Şub", etc for monthly
  final Map<String, double> categoryBreakdown;

  const TrendDataPoint({
    required this.date,
    required this.amount,
    required this.transactionCount,
    required this.label,
    required this.categoryBreakdown,
  });

  @override
  List<Object?> get props => [
        date,
        amount,
        transactionCount,
        label,
        categoryBreakdown,
      ];
}

class TrendSummary extends Equatable {
  final double totalAmount;
  final double averageAmount;
  final double highestAmount;
  final double lowestAmount;
  final TrendDirection direction;
  final double percentageChange;
  final int totalTransactions;
  final double projectedNextPeriod;

  const TrendSummary({
    required this.totalAmount,
    required this.averageAmount,
    required this.highestAmount,
    required this.lowestAmount,
    required this.direction,
    required this.percentageChange,
    required this.totalTransactions,
    required this.projectedNextPeriod,
  });

  String get changeText {
    final abs = percentageChange.abs();
    switch (direction) {
      case TrendDirection.increasing:
        return '+${abs.toStringAsFixed(1)}%';
      case TrendDirection.decreasing:
        return '-${abs.toStringAsFixed(1)}%';
      case TrendDirection.stable:
        return '${abs.toStringAsFixed(1)}%';
    }
  }

  @override
  List<Object?> get props => [
        totalAmount,
        averageAmount,
        highestAmount,
        lowestAmount,
        direction,
        percentageChange,
        totalTransactions,
        projectedNextPeriod,
      ];
}

enum TrendDirection {
  increasing,
  decreasing,
  stable,
}

class TrendInsight extends Equatable {
  final TrendInsightType type;
  final String title;
  final String description;
  final String? actionText;
  final double? relevantAmount;
  final String? categoryId;

  const TrendInsight({
    required this.type,
    required this.title,
    required this.description,
    this.actionText,
    this.relevantAmount,
    this.categoryId,
  });

  @override
  List<Object?> get props => [
        type,
        title,
        description,
        actionText,
        relevantAmount,
        categoryId,
      ];
}

enum TrendInsightType {
  highSpending,
  lowSpending,
  unusualSpike,
  steadyGrowth,
  categoryDominance,
  savingsOpportunity,
  budgetWarning,
  seasonalPattern,
}

class TrendComparison extends Equatable {
  final String comparisonType; // 'vs_previous_period', 'vs_average', 'vs_budget'
  final double currentValue;
  final double comparedValue;
  final double difference;
  final double percentageDifference;
  final bool isImprovement;

  const TrendComparison({
    required this.comparisonType,
    required this.currentValue,
    required this.comparedValue,
    required this.difference,
    required this.percentageDifference,
    required this.isImprovement,
  });

  @override
  List<Object?> get props => [
        comparisonType,
        currentValue,
        comparedValue,
        difference,
        percentageDifference,
        isImprovement,
      ];
}

class PeriodFilter extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final String periodType; // 'monthly', 'weekly', 'yearly'
  final int periodCount; // How many periods to show

  const PeriodFilter({
    required this.startDate,
    required this.endDate,
    required this.periodType,
    required this.periodCount,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        periodType,
        periodCount,
      ];
}