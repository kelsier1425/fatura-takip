import 'package:equatable/equatable.dart';
import '../entities/trend_analytics_entity.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';

class CalculateTrendAnalyticsUseCase {
  
  Future<TrendAnalyticsEntity> execute(CalculateTrendParams params) async {
    // Expense'leri tarihe göre filtrele
    final filteredExpenses = _filterExpensesByDateRange(
      params.expenses,
      params.filter.startDate,
      params.filter.endDate,
    );

    // Periode göre grupla
    final groupedData = _groupExpensesByPeriod(
      filteredExpenses,
      params.filter.periodType,
    );

    // Trend data points oluştur
    final dataPoints = _createDataPoints(groupedData, params.filter.periodType);

    // Trend summary hesapla
    final summary = _calculateTrendSummary(dataPoints);

    // Insights oluştur
    final insights = _generateInsights(dataPoints, summary, params.categories);

    return TrendAnalyticsEntity(
      period: params.filter.periodType,
      dataPoints: dataPoints,
      summary: summary,
      insights: insights,
      startDate: params.filter.startDate,
      endDate: params.filter.endDate,
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

  Map<DateTime, List<ExpenseEntity>> _groupExpensesByPeriod(
    List<ExpenseEntity> expenses,
    String periodType,
  ) {
    final Map<DateTime, List<ExpenseEntity>> grouped = {};

    for (final expense in expenses) {
      DateTime periodKey;
      
      switch (periodType) {
        case 'monthly':
          periodKey = DateTime(expense.date.year, expense.date.month, 1);
          break;
        case 'weekly':
          final weekday = expense.date.weekday;
          final daysToSubtract = weekday == 7 ? 0 : weekday; // Monday = 1, Sunday = 7
          periodKey = expense.date.subtract(Duration(days: daysToSubtract));
          break;
        case 'yearly':
          periodKey = DateTime(expense.date.year, 1, 1);
          break;
        default:
          periodKey = DateTime(expense.date.year, expense.date.month, expense.date.day);
      }

      if (!grouped.containsKey(periodKey)) {
        grouped[periodKey] = [];
      }
      grouped[periodKey]!.add(expense);
    }

    return grouped;
  }

  List<TrendDataPoint> _createDataPoints(
    Map<DateTime, List<ExpenseEntity>> groupedData,
    String periodType,
  ) {
    final dataPoints = <TrendDataPoint>[];
    final sortedKeys = groupedData.keys.toList()..sort();

    for (final date in sortedKeys) {
      final expenses = groupedData[date]!;
      final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      
      // Kategori breakdown hesapla
      final categoryBreakdown = <String, double>{};
      for (final expense in expenses) {
        categoryBreakdown[expense.categoryId] = 
            (categoryBreakdown[expense.categoryId] ?? 0) + expense.amount;
      }

      dataPoints.add(TrendDataPoint(
        date: date,
        amount: totalAmount,
        transactionCount: expenses.length,
        label: _formatPeriodLabel(date, periodType),
        categoryBreakdown: categoryBreakdown,
      ));
    }

    return dataPoints;
  }

  String _formatPeriodLabel(DateTime date, String periodType) {
    switch (periodType) {
      case 'monthly':
        const months = [
          'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
          'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
        ];
        return months[date.month - 1];
      case 'weekly':
        return '${date.day}/${date.month}';
      case 'yearly':
        return date.year.toString();
      default:
        return '${date.day}/${date.month}';
    }
  }

  TrendSummary _calculateTrendSummary(List<TrendDataPoint> dataPoints) {
    if (dataPoints.isEmpty) {
      return const TrendSummary(
        totalAmount: 0,
        averageAmount: 0,
        highestAmount: 0,
        lowestAmount: 0,
        direction: TrendDirection.stable,
        percentageChange: 0,
        totalTransactions: 0,
        projectedNextPeriod: 0,
      );
    }

    final amounts = dataPoints.map((point) => point.amount).toList();
    final totalAmount = amounts.fold(0.0, (sum, amount) => sum + amount);
    final averageAmount = totalAmount / amounts.length;
    final highestAmount = amounts.reduce((a, b) => a > b ? a : b);
    final lowestAmount = amounts.reduce((a, b) => a < b ? a : b);
    final totalTransactions = dataPoints.fold(0, (sum, point) => sum + point.transactionCount);

    // Trend direction ve percentage change hesapla
    final trendInfo = _calculateTrendDirection(amounts);
    
    // Next period projection (basit linear regression)
    final projectedNextPeriod = _calculateProjection(amounts);

    return TrendSummary(
      totalAmount: totalAmount,
      averageAmount: averageAmount,
      highestAmount: highestAmount,
      lowestAmount: lowestAmount,
      direction: trendInfo['direction'],
      percentageChange: trendInfo['percentage'],
      totalTransactions: totalTransactions,
      projectedNextPeriod: projectedNextPeriod,
    );
  }

  Map<String, dynamic> _calculateTrendDirection(List<double> amounts) {
    if (amounts.length < 2) {
      return {'direction': TrendDirection.stable, 'percentage': 0.0};
    }

    final firstHalf = amounts.take(amounts.length ~/ 2).toList();
    final secondHalf = amounts.skip(amounts.length ~/ 2).toList();
    
    final firstAvg = firstHalf.fold(0.0, (sum, amount) => sum + amount) / firstHalf.length;
    final secondAvg = secondHalf.fold(0.0, (sum, amount) => sum + amount) / secondHalf.length;
    
    final difference = secondAvg - firstAvg;
    final percentage = firstAvg != 0 ? (difference / firstAvg) * 100 : 0.0;
    
    TrendDirection direction;
    if (percentage.abs() < 5) {
      direction = TrendDirection.stable;
    } else if (percentage > 0) {
      direction = TrendDirection.increasing;
    } else {
      direction = TrendDirection.decreasing;
    }

    return {'direction': direction, 'percentage': percentage};
  }

  double _calculateProjection(List<double> amounts) {
    if (amounts.length < 2) return amounts.isNotEmpty ? amounts.first : 0;

    // Basit linear regression
    final n = amounts.length;
    final sumX = List.generate(n, (i) => i).fold(0, (sum, i) => sum + i);
    final sumY = amounts.fold(0.0, (sum, amount) => sum + amount);
    final sumXY = amounts.asMap().entries.fold(0.0, (sum, entry) => sum + (entry.key * entry.value));
    final sumX2 = List.generate(n, (i) => i).fold(0, (sum, i) => sum + (i * i));

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    return slope * n + intercept; // Projection for next period
  }

  List<TrendInsight> _generateInsights(
    List<TrendDataPoint> dataPoints,
    TrendSummary summary,
    List<CategoryEntity> categories,
  ) {
    final insights = <TrendInsight>[];

    // High spending insight
    if (summary.highestAmount > summary.averageAmount * 1.5) {
      insights.add(const TrendInsight(
        type: TrendInsightType.highSpending,
        title: 'Yüksek Harcama Tespit Edildi',
        description: 'Bu dönemde ortalamadan %50 daha fazla harcama yaptınız',
        actionText: 'Detayları İncele',
      ));
    }

    // Trend direction insight
    if (summary.direction == TrendDirection.increasing && summary.percentageChange > 20) {
      insights.add(TrendInsight(
        type: TrendInsightType.steadyGrowth,
        title: 'Harcama Artış Trendi',
        description: 'Son dönemde harcamalarınız ${summary.changeText} arttı',
        actionText: 'Bütçe Oluştur',
      ));
    } else if (summary.direction == TrendDirection.decreasing && summary.percentageChange.abs() > 15) {
      insights.add(TrendInsight(
        type: TrendInsightType.savingsOpportunity,
        title: 'Tasarruf Başarısı',
        description: 'Harcamalarınızı ${summary.changeText} azalttınız!',
        actionText: 'Devam Et',
      ));
    }

    // Category dominance insight
    if (dataPoints.isNotEmpty) {
      final lastPeriod = dataPoints.last;
      final dominantCategory = _findDominantCategory(lastPeriod.categoryBreakdown);
      
      if (dominantCategory != null) {
        final categoryName = categories
            .firstWhere((cat) => cat.id == dominantCategory['categoryId'], 
                       orElse: () => categories.first)
            .name;
        
        insights.add(TrendInsight(
          type: TrendInsightType.categoryDominance,
          title: 'En Çok Harcama: $categoryName',
          description: 'Bu kategori toplam harcamanızın %${dominantCategory['percentage']!.toStringAsFixed(0)}\'ini oluşturuyor',
          categoryId: dominantCategory['categoryId'],
          relevantAmount: dominantCategory['amount'],
        ));
      }
    }

    return insights;
  }

  Map<String, dynamic>? _findDominantCategory(Map<String, double> categoryBreakdown) {
    if (categoryBreakdown.isEmpty) return null;

    final totalAmount = categoryBreakdown.values.fold(0.0, (sum, amount) => sum + amount);
    if (totalAmount == 0) return null;

    String dominantCategoryId = '';
    double maxAmount = 0;

    for (final entry in categoryBreakdown.entries) {
      if (entry.value > maxAmount) {
        maxAmount = entry.value;
        dominantCategoryId = entry.key;
      }
    }

    final percentage = (maxAmount / totalAmount) * 100;
    
    // Only return if it's significantly dominant (>30%)
    if (percentage > 30) {
      return {
        'categoryId': dominantCategoryId,
        'amount': maxAmount,
        'percentage': percentage,
      };
    }

    return null;
  }
}

class CalculateTrendParams extends Equatable {
  final List<ExpenseEntity> expenses;
  final List<CategoryEntity> categories;
  final PeriodFilter filter;

  const CalculateTrendParams({
    required this.expenses,
    required this.categories,
    required this.filter,
  });

  @override
  List<Object?> get props => [expenses, categories, filter];
}

