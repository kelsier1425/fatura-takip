import 'dart:math' as math;
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/repositories/savings_goal_repository.dart';

class SavingsGoalRepositoryImpl implements SavingsGoalRepository {
  // Mock data storage
  final List<SavingsGoalEntity> _goals = [];
  final List<SavingsMilestone> _milestones = [];

  @override
  Future<SavingsGoalEntity> createSavingsGoal(SavingsGoalEntity goal) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _goals.add(goal);
    return goal;
  }

  @override
  Future<SavingsGoalEntity> updateSavingsGoal(SavingsGoalEntity goal) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      return goal;
    }
    throw ArgumentError('Goal not found');
  }

  @override
  Future<void> deleteSavingsGoal(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _goals.removeWhere((goal) => goal.id == goalId);
    _milestones.removeWhere((milestone) => milestone.amount.toString() == goalId);
  }

  @override
  Future<SavingsGoalEntity?> getSavingsGoalById(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _goals.firstWhere((goal) => goal.id == goalId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<SavingsGoalEntity>> getSavingsGoalsByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_goals.isEmpty) {
      // Generate mock data for demo
      _generateMockData(userId);
    }
    return _goals.where((goal) => goal.userId == userId).toList();
  }

  @override
  Future<void> pauseSavingsGoal(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final goal = await getSavingsGoalById(goalId);
    if (goal != null) {
      await updateSavingsGoal(goal.copyWith(
        status: SavingsGoalStatus.paused,
        updatedAt: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> resumeSavingsGoal(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final goal = await getSavingsGoalById(goalId);
    if (goal != null) {
      await updateSavingsGoal(goal.copyWith(
        status: SavingsGoalStatus.active,
        updatedAt: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> completeSavingsGoal(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final goal = await getSavingsGoalById(goalId);
    if (goal != null) {
      await updateSavingsGoal(goal.copyWith(
        status: SavingsGoalStatus.completed,
        updatedAt: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> cancelSavingsGoal(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final goal = await getSavingsGoalById(goalId);
    if (goal != null) {
      await updateSavingsGoal(goal.copyWith(
        status: SavingsGoalStatus.cancelled,
        updatedAt: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> addContribution(String goalId, SavingsContribution contribution) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final goal = await getSavingsGoalById(goalId);
    if (goal != null) {
      final updatedContributions = List<SavingsContribution>.from(goal.contributions)
        ..add(contribution);
      await updateSavingsGoal(goal.copyWith(
        contributions: updatedContributions,
        currentAmount: goal.currentAmount + contribution.amount,
        updatedAt: DateTime.now(),
      ));
    }
  }

  @override
  Future<List<SavingsContribution>> getContributions(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final goal = await getSavingsGoalById(goalId);
    return goal?.contributions ?? [];
  }

  @override
  Future<void> removeContribution(String contributionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (final goal in _goals) {
      final contributionIndex = goal.contributions.indexWhere((c) => c.id == contributionId);
      if (contributionIndex != -1) {
        final contribution = goal.contributions[contributionIndex];
        final updatedContributions = List<SavingsContribution>.from(goal.contributions)
          ..removeAt(contributionIndex);
        await updateSavingsGoal(goal.copyWith(
          contributions: updatedContributions,
          currentAmount: goal.currentAmount - contribution.amount,
          updatedAt: DateTime.now(),
        ));
        break;
      }
    }
  }

  @override
  Future<void> generateMilestones(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final goal = await getSavingsGoalById(goalId);
    if (goal != null) {
      final milestonePercentages = [25.0, 50.0, 75.0, 100.0];
      for (final percentage in milestonePercentages) {
        final milestoneAmount = (goal.targetAmount * percentage) / 100;
        _milestones.add(SavingsMilestone(
          percentage: percentage,
          amount: milestoneAmount,
          isAchieved: goal.currentAmount >= milestoneAmount,
          achievedDate: goal.currentAmount >= milestoneAmount ? DateTime.now() : null,
          celebrationMessage: _getMilestoneMessage(percentage),
        ));
      }
    }
  }

  @override
  Future<List<SavingsMilestone>> getMilestones(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // For mock implementation, return milestone data
    return _milestones;
  }

  @override
  Future<void> achieveMilestone(String goalId, double percentage) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final milestoneIndex = _milestones.indexWhere((m) => m.percentage == percentage);
    if (milestoneIndex != -1) {
      final milestone = _milestones[milestoneIndex];
      _milestones[milestoneIndex] = SavingsMilestone(
        percentage: milestone.percentage,
        amount: milestone.amount,
        isAchieved: true,
        achievedDate: DateTime.now(),
        celebrationMessage: milestone.celebrationMessage,
      );
    }
  }

  @override
  Future<List<SavingsGoalTemplate>> getGoalTemplates() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      const SavingsGoalTemplate(
        id: 'emergency_fund',
        title: 'Acil Durum Fonu',
        description: '6 aylık harcamanızı karşılayacak acil durum fonu',
        category: SavingsGoalCategory.emergency,
        emoji: '🚨',
        suggestedAmount: 50000,
        suggestedDuration: 12,
        suggestedPlan: SavingsPlan(
          type: SavingsPlanType.fixed,
          fixedAmount: 4200,
          frequency: SavingsPlanFrequency.monthly,
          autoSave: true,
        ),
        tips: [
          'Önce 1000 TL acil durum fonu hedefleyin',
          'Otomatik transfer ayarlayın',
          'Farklı hesapta saklayın'
        ],
        isPremium: false,
      ),
      const SavingsGoalTemplate(
        id: 'vacation',
        title: 'Tatil',
        description: 'Hayalinizdeki tatil için tasarruf yapın',
        category: SavingsGoalCategory.vacation,
        emoji: '🏖️',
        suggestedAmount: 15000,
        suggestedDuration: 6,
        suggestedPlan: SavingsPlan(
          type: SavingsPlanType.fixed,
          fixedAmount: 2500,
          frequency: SavingsPlanFrequency.monthly,
          autoSave: false,
        ),
        tips: [
          'Tatil tarihini belirleyin',
          'Detaylı bütçe planlayın',
          'Erken reservasyon indirimlerini araştırın'
        ],
        isPremium: false,
      ),
      const SavingsGoalTemplate(
        id: 'house_down_payment',
        title: 'Ev Peşinatı',
        description: 'Ev satın almak için peşinat biriktirin',
        category: SavingsGoalCategory.house,
        emoji: '🏠',
        suggestedAmount: 200000,
        suggestedDuration: 36,
        suggestedPlan: SavingsPlan(
          type: SavingsPlanType.fixed,
          fixedAmount: 5600,
          frequency: SavingsPlanFrequency.monthly,
          autoSave: true,
        ),
        tips: [
          'Konut kredisi koşullarını araştırın',
          'Devlet desteklerini inceleyin',
          'Farklı yatırım seçeneklerini değerlendirin'
        ],
        isPremium: true,
      ),
    ];
  }

  @override
  Future<SavingsGoalEntity> createGoalFromTemplate(
    String userId,
    String templateId,
    double targetAmount,
    DateTime targetDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final templates = await getGoalTemplates();
    final template = templates.firstWhere((t) => t.id == templateId);
    
    final goal = SavingsGoalEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: template.title,
      description: template.description,
      targetAmount: targetAmount,
      currentAmount: 0,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      status: SavingsGoalStatus.active,
      category: template.category,
      emoji: template.emoji,
      plan: template.suggestedPlan,
      contributions: [],
      settings: const SavingsSettings(
        enableNotifications: true,
        enableMilestoneAlerts: true,
        enableProgressSharing: false,
        reminderFrequency: 7,
        milestonePercentage: 25.0,
        privacyLevel: SavingsPrivacyLevel.private,
      ),
    );
    
    return await createSavingsGoal(goal);
  }

  @override
  Future<SavingsAnalytics> getGoalAnalytics(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final goal = await getSavingsGoalById(goalId);
    if (goal == null) throw ArgumentError('Goal not found');
    
    return SavingsAnalytics(
      goalId: goalId,
      totalSaved: goal.currentAmount,
      averageMonthlyContribution: _calculateAverageMonthlyContribution(goal),
      totalContributions: goal.contributions.length,
      estimatedCompletionDate: _estimateCompletionDate(goal),
      currentSavingRate: _calculateCurrentSavingRate(goal),
      milestones: await getMilestones(goalId),
      performance: _calculatePerformance(goal),
    );
  }

  @override
  Future<List<SavingsGoalEntity>> getGoalsByCategory(
    String userId,
    SavingsGoalCategory category,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final userGoals = await getSavingsGoalsByUserId(userId);
    return userGoals.where((goal) => goal.category == category).toList();
  }

  @override
  Future<List<SavingsGoalEntity>> getGoalsByStatus(
    String userId,
    SavingsGoalStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final userGoals = await getSavingsGoalsByUserId(userId);
    return userGoals.where((goal) => goal.status == status).toList();
  }

  @override
  Future<void> enableAutoSave(String goalId, double amount, SavingsPlanFrequency frequency) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final goal = await getSavingsGoalById(goalId);
    if (goal != null) {
      final updatedPlan = goal.plan.copyWith(
        autoSave: true,
        fixedAmount: amount,
        frequency: frequency,
      );
      await updateSavingsGoal(goal.copyWith(plan: updatedPlan));
    }
  }

  @override
  Future<void> disableAutoSave(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final goal = await getSavingsGoalById(goalId);
    if (goal != null) {
      final updatedPlan = goal.plan.copyWith(autoSave: false);
      await updateSavingsGoal(goal.copyWith(plan: updatedPlan));
    }
  }

  @override
  Future<void> processAutoSave() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock implementation - in real app, this would process scheduled auto-saves
    for (final goal in _goals) {
      if (goal.plan.autoSave && goal.plan.fixedAmount != null) {
        final contribution = SavingsContribution(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          goalId: goal.id,
          amount: goal.plan.fixedAmount!,
          date: DateTime.now(),
          type: SavingsContributionType.automatic,
        );
        await addContribution(goal.id, contribution);
      }
    }
  }

  @override
  Future<void> sendNotification(String userId, String title, String message) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock implementation - in real app, this would send push notifications
    print('Notification to $userId: $title - $message');
  }

  @override
  Future<void> scheduleReminder(String goalId, DateTime reminderDate) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock implementation - in real app, this would schedule local notifications
  }

  @override
  Future<void> cancelReminder(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock implementation - in real app, this would cancel scheduled notifications
  }

  @override
  Future<List<SavingsGoalEntity>> searchGoals(String userId, String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final userGoals = await getSavingsGoalsByUserId(userId);
    return userGoals.where((goal) => 
      goal.title.toLowerCase().contains(query.toLowerCase()) ||
      (goal.description != null && goal.description!.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  @override
  Future<List<SavingsGoalEntity>> getGoalsWithFilters({
    required String userId,
    SavingsGoalStatus? status,
    SavingsGoalCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var goals = await getSavingsGoalsByUserId(userId);
    
    if (status != null) {
      goals = goals.where((goal) => goal.status == status).toList();
    }
    
    if (category != null) {
      goals = goals.where((goal) => goal.category == category).toList();
    }
    
    if (startDate != null) {
      goals = goals.where((goal) => goal.createdAt.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      goals = goals.where((goal) => goal.createdAt.isBefore(endDate)).toList();
    }
    
    if (minAmount != null) {
      goals = goals.where((goal) => goal.targetAmount >= minAmount).toList();
    }
    
    if (maxAmount != null) {
      goals = goals.where((goal) => goal.targetAmount <= maxAmount).toList();
    }
    
    return goals;
  }

  @override
  Future<Map<String, dynamic>> getUserSavingsStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final userGoals = await getSavingsGoalsByUserId(userId);
    
    final totalGoals = userGoals.length;
    final activeGoals = userGoals.where((g) => g.status == SavingsGoalStatus.active).length;
    final completedGoals = userGoals.where((g) => g.status == SavingsGoalStatus.completed).length;
    final totalTargetAmount = userGoals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
    final totalSavedAmount = userGoals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
    final overallProgress = totalTargetAmount > 0 ? (totalSavedAmount / totalTargetAmount) * 100 : 0.0;
    
    return {
      'totalGoals': totalGoals,
      'activeGoals': activeGoals,
      'completedGoals': completedGoals,
      'totalTargetAmount': totalTargetAmount,
      'totalSavedAmount': totalSavedAmount,
      'overallProgress': overallProgress,
      'completionRate': totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0.0,
    };
  }

  @override
  Future<double> getTotalSavingsAmount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final userGoals = await getSavingsGoalsByUserId(userId);
    return userGoals.fold<double>(0.0, (sum, goal) => sum + goal.currentAmount);
  }

  @override
  Future<int> getCompletedGoalsCount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final userGoals = await getSavingsGoalsByUserId(userId);
    return userGoals.where((goal) => goal.status == SavingsGoalStatus.completed).length;
  }

  @override
  Future<List<SavingsGoalEntity>> getRecentGoals(String userId, int limit) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final userGoals = await getSavingsGoalsByUserId(userId);
    userGoals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return userGoals.take(limit).toList();
  }

  // Helper methods
  double _calculateAverageMonthlyContribution(SavingsGoalEntity goal) {
    if (goal.contributions.isEmpty) return 0.0;
    
    final monthlyTotals = <String, double>{};
    for (final contribution in goal.contributions) {
      final monthKey = '${contribution.date.year}-${contribution.date.month}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + contribution.amount;
    }
    
    if (monthlyTotals.isEmpty) return 0.0;
    final totalContributed = monthlyTotals.values.fold(0.0, (sum, amount) => sum + amount);
    return totalContributed / monthlyTotals.length;
  }

  DateTime? _estimateCompletionDate(SavingsGoalEntity goal) {
    if (goal.isCompleted) return goal.contributions.last.date;
    
    final remainingAmount = goal.remainingAmount;
    if (remainingAmount <= 0) return DateTime.now();
    
    final monthlyRate = _calculateAverageMonthlyContribution(goal);
    if (monthlyRate <= 0) return null;
    
    final monthsNeeded = remainingAmount / monthlyRate;
    return DateTime.now().add(Duration(days: (monthsNeeded * 30).round()));
  }

  double _calculateCurrentSavingRate(SavingsGoalEntity goal) {
    if (goal.contributions.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final recentContributions = goal.contributions.where(
      (contribution) => contribution.date.isAfter(thirtyDaysAgo),
    );
    
    return recentContributions.fold(0.0, (sum, contribution) => sum + contribution.amount);
  }

  SavingsPerformance _calculatePerformance(SavingsGoalEntity goal) {
    if (goal.isCompleted) return SavingsPerformance.excellent;
    if (goal.isOverdue) return SavingsPerformance.critical;
    
    final expectedProgress = _calculateExpectedProgress(goal);
    final actualProgress = goal.progressPercentage;
    final difference = actualProgress - expectedProgress;
    
    if (difference >= 10) return SavingsPerformance.excellent;
    if (difference >= 0) return SavingsPerformance.good;
    if (difference >= -10) return SavingsPerformance.fair;
    if (difference >= -25) return SavingsPerformance.poor;
    return SavingsPerformance.critical;
  }

  double _calculateExpectedProgress(SavingsGoalEntity goal) {
    final now = DateTime.now();
    final totalDuration = goal.targetDate.difference(goal.createdAt).inDays;
    final elapsedDuration = now.difference(goal.createdAt).inDays;
    
    if (totalDuration <= 0) return 100.0;
    
    final expectedProgress = (elapsedDuration / totalDuration) * 100;
    return math.min(expectedProgress, 100.0);
  }

  String _getMilestoneMessage(double percentage) {
    switch (percentage) {
      case 25.0:
        return 'Harika başlangıç! İlk çeyreği tamamladın! 🎯';
      case 50.0:
        return 'Yarı yolda! Hedefinin yarısına ulaştın! 🔥';
      case 75.0:
        return 'Çok yakınsın! Son çeyreğe girdin! ⭐';
      case 100.0:
        return 'Tebrikler! Hedefini başarıyla tamamladın! 🎉';
      default:
        return 'Milestone başarısı! 🎊';
    }
  }

  void _generateMockData(String userId) {
    final now = DateTime.now();
    
    // Acil durum fonu
    final emergencyFund = SavingsGoalEntity(
      id: 'emergency_${now.millisecondsSinceEpoch}',
      userId: userId,
      title: 'Acil Durum Fonu',
      description: '6 aylık harcama karşılığı acil durum fonu',
      targetAmount: 50000,
      currentAmount: 12500,
      targetDate: now.add(const Duration(days: 365)),
      createdAt: now.subtract(const Duration(days: 90)),
      status: SavingsGoalStatus.active,
      category: SavingsGoalCategory.emergency,
      emoji: '🚨',
      plan: const SavingsPlan(
        type: SavingsPlanType.fixed,
        fixedAmount: 3000,
        frequency: SavingsPlanFrequency.monthly,
        autoSave: true,
      ),
      contributions: [
        SavingsContribution(
          id: 'contrib_1',
          goalId: 'emergency_${now.millisecondsSinceEpoch}',
          amount: 5000,
          date: now.subtract(const Duration(days: 80)),
          type: SavingsContributionType.manual,
          note: 'İlk yatırım',
        ),
        SavingsContribution(
          id: 'contrib_2',
          goalId: 'emergency_${now.millisecondsSinceEpoch}',
          amount: 3000,
          date: now.subtract(const Duration(days: 50)),
          type: SavingsContributionType.automatic,
        ),
        SavingsContribution(
          id: 'contrib_3',
          goalId: 'emergency_${now.millisecondsSinceEpoch}',
          amount: 2500,
          date: now.subtract(const Duration(days: 25)),
          type: SavingsContributionType.bonus,
          note: 'İkramiye',
        ),
        SavingsContribution(
          id: 'contrib_4',
          goalId: 'emergency_${now.millisecondsSinceEpoch}',
          amount: 2000,
          date: now.subtract(const Duration(days: 5)),
          type: SavingsContributionType.manual,
        ),
      ],
      settings: const SavingsSettings(
        enableNotifications: true,
        enableMilestoneAlerts: true,
        enableProgressSharing: false,
        reminderFrequency: 7,
        milestonePercentage: 25.0,
        privacyLevel: SavingsPrivacyLevel.private,
      ),
    );

    // Tatil hedefi
    final vacationGoal = SavingsGoalEntity(
      id: 'vacation_${now.millisecondsSinceEpoch + 1}',
      userId: userId,
      title: 'Yaz Tatili 2024',
      description: 'İtalya gezisi için tasarruf',
      targetAmount: 25000,
      currentAmount: 18750,
      targetDate: now.add(const Duration(days: 120)),
      createdAt: now.subtract(const Duration(days: 180)),
      status: SavingsGoalStatus.active,
      category: SavingsGoalCategory.vacation,
      emoji: '🏖️',
      plan: const SavingsPlan(
        type: SavingsPlanType.fixed,
        fixedAmount: 2500,
        frequency: SavingsPlanFrequency.monthly,
        autoSave: false,
      ),
      contributions: [
        SavingsContribution(
          id: 'vacation_contrib_1',
          goalId: 'vacation_${now.millisecondsSinceEpoch + 1}',
          amount: 10000,
          date: now.subtract(const Duration(days: 160)),
          type: SavingsContributionType.manual,
          note: 'Başlangıç yatırımı',
        ),
        SavingsContribution(
          id: 'vacation_contrib_2',
          goalId: 'vacation_${now.millisecondsSinceEpoch + 1}',
          amount: 4000,
          date: now.subtract(const Duration(days: 120)),
          type: SavingsContributionType.manual,
        ),
        SavingsContribution(
          id: 'vacation_contrib_3',
          goalId: 'vacation_${now.millisecondsSinceEpoch + 1}',
          amount: 2750,
          date: now.subtract(const Duration(days: 60)),
          type: SavingsContributionType.manual,
        ),
        SavingsContribution(
          id: 'vacation_contrib_4',
          goalId: 'vacation_${now.millisecondsSinceEpoch + 1}',
          amount: 2000,
          date: now.subtract(const Duration(days: 20)),
          type: SavingsContributionType.manual,
        ),
      ],
      settings: const SavingsSettings(
        enableNotifications: true,
        enableMilestoneAlerts: true,
        enableProgressSharing: true,
        reminderFrequency: 14,
        milestonePercentage: 25.0,
        privacyLevel: SavingsPrivacyLevel.family,
      ),
    );

    // Araba hedefi
    final carGoal = SavingsGoalEntity(
      id: 'car_${now.millisecondsSinceEpoch + 2}',
      userId: userId,
      title: 'Yeni Araba',
      description: 'Hybrid araç için peşinat',
      targetAmount: 80000,
      currentAmount: 15000,
      targetDate: now.add(const Duration(days: 540)),
      createdAt: now.subtract(const Duration(days: 60)),
      status: SavingsGoalStatus.active,
      category: SavingsGoalCategory.car,
      emoji: '🚗',
      plan: const SavingsPlan(
        type: SavingsPlanType.fixed,
        fixedAmount: 4000,
        frequency: SavingsPlanFrequency.monthly,
        autoSave: true,
      ),
      contributions: [
        SavingsContribution(
          id: 'car_contrib_1',
          goalId: 'car_${now.millisecondsSinceEpoch + 2}',
          amount: 10000,
          date: now.subtract(const Duration(days: 50)),
          type: SavingsContributionType.manual,
          note: 'Mevcut araba satışı',
        ),
        SavingsContribution(
          id: 'car_contrib_2',
          goalId: 'car_${now.millisecondsSinceEpoch + 2}',
          amount: 5000,
          date: now.subtract(const Duration(days: 10)),
          type: SavingsContributionType.manual,
        ),
      ],
      settings: const SavingsSettings(
        enableNotifications: true,
        enableMilestoneAlerts: true,
        enableProgressSharing: false,
        reminderFrequency: 7,
        milestonePercentage: 20.0,
        privacyLevel: SavingsPrivacyLevel.private,
      ),
    );

    _goals.addAll([emergencyFund, vacationGoal, carGoal]);
  }
}

// Extension to add copyWith method to SavingsPlan
extension SavingsPlanCopyWith on SavingsPlan {
  SavingsPlan copyWith({
    SavingsPlanType? type,
    double? fixedAmount,
    double? percentageAmount,
    SavingsPlanFrequency? frequency,
    List<int>? specificDays,
    bool? autoSave,
    String? linkedBudgetId,
  }) {
    return SavingsPlan(
      type: type ?? this.type,
      fixedAmount: fixedAmount ?? this.fixedAmount,
      percentageAmount: percentageAmount ?? this.percentageAmount,
      frequency: frequency ?? this.frequency,
      specificDays: specificDays ?? this.specificDays,
      autoSave: autoSave ?? this.autoSave,
      linkedBudgetId: linkedBudgetId ?? this.linkedBudgetId,
    );
  }
}