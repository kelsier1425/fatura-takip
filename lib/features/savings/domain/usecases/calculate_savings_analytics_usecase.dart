import 'dart:math' as math;
import '../entities/savings_goal_entity.dart';
import '../repositories/savings_goal_repository.dart';

class CalculateSavingsAnalyticsUseCase {
  final SavingsGoalRepository repository;

  CalculateSavingsAnalyticsUseCase(this.repository);

  Future<SavingsAnalytics> execute(String goalId) async {
    final goal = await repository.getSavingsGoalById(goalId);
    if (goal == null) {
      throw ArgumentError('Savings goal not found');
    }

    // Calculate basic analytics
    final totalSaved = goal.currentAmount;
    final totalContributions = goal.contributions.length;
    
    // Calculate average monthly contribution
    final averageMonthlyContribution = _calculateAverageMonthlyContribution(goal);
    
    // Calculate current saving rate
    final currentSavingRate = _calculateCurrentSavingRate(goal);
    
    // Estimate completion date
    final estimatedCompletionDate = _estimateCompletionDate(goal);
    
    // Get milestones
    final milestones = await repository.getMilestones(goalId);
    
    // Calculate performance
    final performance = _calculatePerformance(goal);

    return SavingsAnalytics(
      goalId: goalId,
      totalSaved: totalSaved,
      averageMonthlyContribution: averageMonthlyContribution,
      totalContributions: totalContributions,
      estimatedCompletionDate: estimatedCompletionDate,
      currentSavingRate: currentSavingRate,
      milestones: milestones,
      performance: performance,
    );
  }

  double _calculateAverageMonthlyContribution(SavingsGoalEntity goal) {
    if (goal.contributions.isEmpty) return 0.0;

    // Group contributions by month
    final monthlyTotals = <String, double>{};
    
    for (final contribution in goal.contributions) {
      final monthKey = '${contribution.date.year}-${contribution.date.month}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + contribution.amount;
    }

    if (monthlyTotals.isEmpty) return 0.0;

    final totalContributed = monthlyTotals.values.fold(0.0, (sum, amount) => sum + amount);
    return totalContributed / monthlyTotals.length;
  }

  double _calculateCurrentSavingRate(SavingsGoalEntity goal) {
    if (goal.contributions.isEmpty) return 0.0;

    // Calculate savings rate for the last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final recentContributions = goal.contributions.where(
      (contribution) => contribution.date.isAfter(thirtyDaysAgo),
    );

    final recentTotal = recentContributions.fold(
      0.0,
      (sum, contribution) => sum + contribution.amount,
    );

    return recentTotal;
  }

  DateTime? _estimateCompletionDate(SavingsGoalEntity goal) {
    if (goal.isCompleted) return goal.contributions.last.date;
    
    final remainingAmount = goal.remainingAmount;
    if (remainingAmount <= 0) return DateTime.now();

    // Use current saving rate to estimate
    final monthlySavingRate = _calculateCurrentSavingRate(goal);
    if (monthlySavingRate <= 0) {
      // Fallback to plan-based estimation
      return _estimateFromPlan(goal);
    }

    final monthsNeeded = remainingAmount / monthlySavingRate;
    return DateTime.now().add(Duration(days: (monthsNeeded * 30).round()));
  }

  DateTime? _estimateFromPlan(SavingsGoalEntity goal) {
    final plan = goal.plan;
    if (plan.fixedAmount == null || plan.fixedAmount! <= 0) {
      return null;
    }

    final remainingAmount = goal.remainingAmount;
    double monthlyAmount;

    switch (plan.frequency) {
      case SavingsPlanFrequency.daily:
        monthlyAmount = plan.fixedAmount! * 30;
        break;
      case SavingsPlanFrequency.weekly:
        monthlyAmount = plan.fixedAmount! * 4;
        break;
      case SavingsPlanFrequency.biweekly:
        monthlyAmount = plan.fixedAmount! * 2;
        break;
      case SavingsPlanFrequency.monthly:
        monthlyAmount = plan.fixedAmount!;
        break;
      case SavingsPlanFrequency.quarterly:
        monthlyAmount = plan.fixedAmount! / 3;
        break;
    }

    final monthsNeeded = remainingAmount / monthlyAmount;
    return DateTime.now().add(Duration(days: (monthsNeeded * 30).round()));
  }

  SavingsPerformance _calculatePerformance(SavingsGoalEntity goal) {
    if (goal.isCompleted) return SavingsPerformance.excellent;
    if (goal.isOverdue) return SavingsPerformance.critical;

    // Calculate expected vs actual progress
    final expectedProgress = _calculateExpectedProgress(goal);
    final actualProgress = goal.progressPercentage;
    final difference = actualProgress - expectedProgress;

    if (difference >= 10) {
      return SavingsPerformance.excellent;
    } else if (difference >= 0) {
      return SavingsPerformance.good;
    } else if (difference >= -10) {
      return SavingsPerformance.fair;
    } else if (difference >= -25) {
      return SavingsPerformance.poor;
    } else {
      return SavingsPerformance.critical;
    }
  }

  double _calculateExpectedProgress(SavingsGoalEntity goal) {
    final now = DateTime.now();
    final totalDuration = goal.targetDate.difference(goal.createdAt).inDays;
    final elapsedDuration = now.difference(goal.createdAt).inDays;

    if (totalDuration <= 0) return 100.0;
    
    final expectedProgress = (elapsedDuration / totalDuration) * 100;
    return math.min(expectedProgress, 100.0);
  }

  // Generate savings recommendations
  Future<List<SavingsRecommendation>> generateRecommendations(String goalId) async {
    final goal = await repository.getSavingsGoalById(goalId);
    if (goal == null) return [];

    final recommendations = <SavingsRecommendation>[];
    final analytics = await execute(goalId);

    // Recommendation based on performance
    switch (analytics.performance) {
      case SavingsPerformance.poor:
      case SavingsPerformance.critical:
        recommendations.add(SavingsRecommendation(
          type: SavingsRecommendationType.increaseContributions,
          title: 'Katkıları Artır',
          description: 'Hedefine ulaşmak için aylık katkılarını artırman gerekiyor.',
          suggestedAmount: goal.monthlyRequiredSaving * 1.2,
          priority: RecommendationPriority.high,
        ));
        break;
      case SavingsPerformance.fair:
        recommendations.add(SavingsRecommendation(
          type: SavingsRecommendationType.adjustPlan,
          title: 'Planı Güncelle',
          description: 'Mevcut planını gözden geçirip küçük ayarlamalar yapabilirsin.',
          priority: RecommendationPriority.medium,
        ));
        break;
      case SavingsPerformance.excellent:
        recommendations.add(SavingsRecommendation(
          type: SavingsRecommendationType.newGoal,
          title: 'Yeni Hedef Belirle',
          description: 'Harika gidiyorsun! Yeni bir tasarruf hedefi belirleyebilirsin.',
          priority: RecommendationPriority.low,
        ));
        break;
      default:
        break;
    }

    // Auto-save recommendation
    if (!goal.plan.autoSave && analytics.averageMonthlyContribution > 0) {
      recommendations.add(SavingsRecommendation(
        type: SavingsRecommendationType.enableAutoSave,
        title: 'Otomatik Tasarruf',
        description: 'Düzenli katkıların için otomatik tasarruf özelliğini etkinleştir.',
        priority: RecommendationPriority.medium,
      ));
    }

    return recommendations;
  }
}

class SavingsRecommendation {
  final SavingsRecommendationType type;
  final String title;
  final String description;
  final double? suggestedAmount;
  final RecommendationPriority priority;
  final String? actionText;

  SavingsRecommendation({
    required this.type,
    required this.title,
    required this.description,
    this.suggestedAmount,
    required this.priority,
    this.actionText,
  });
}

enum SavingsRecommendationType {
  increaseContributions,
  adjustPlan,
  enableAutoSave,
  newGoal,
  optimizeFrequency,
  budgetIntegration,
}

enum RecommendationPriority {
  low,
  medium,
  high,
  critical,
}