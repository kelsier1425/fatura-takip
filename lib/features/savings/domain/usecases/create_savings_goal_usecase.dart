import '../entities/savings_goal_entity.dart';
import '../repositories/savings_goal_repository.dart';

class CreateSavingsGoalUseCase {
  final SavingsGoalRepository repository;

  CreateSavingsGoalUseCase(this.repository);

  Future<SavingsGoalEntity> execute(CreateSavingsGoalParams params) async {
    // Validate input
    _validateGoalParams(params);

    // Create goal with calculated plan
    final goal = _createGoalFromParams(params);

    // Save to repository
    final createdGoal = await repository.createSavingsGoal(goal);

    // Generate initial milestones
    await repository.generateMilestones(createdGoal.id);

    return createdGoal;
  }

  void _validateGoalParams(CreateSavingsGoalParams params) {
    if (params.title.trim().isEmpty) {
      throw ArgumentError('Goal title cannot be empty');
    }

    if (params.targetAmount <= 0) {
      throw ArgumentError('Target amount must be greater than 0');
    }

    if (params.targetDate.isBefore(DateTime.now())) {
      throw ArgumentError('Target date must be in the future');
    }

    if (params.currentAmount < 0) {
      throw ArgumentError('Current amount cannot be negative');
    }

    if (params.currentAmount > params.targetAmount) {
      throw ArgumentError('Current amount cannot exceed target amount');
    }
  }

  SavingsGoalEntity _createGoalFromParams(CreateSavingsGoalParams params) {
    final now = DateTime.now();
    final goalId = DateTime.now().millisecondsSinceEpoch.toString();

    // Create savings plan based on user preferences
    final plan = _createSavingsPlan(params);

    // Default settings
    const settings = SavingsSettings(
      enableNotifications: true,
      enableMilestoneAlerts: true,
      enableProgressSharing: false,
      reminderFrequency: 7, // Weekly
      milestonePercentage: 25.0, // Every 25%
      privacyLevel: SavingsPrivacyLevel.private,
    );

    return SavingsGoalEntity(
      id: goalId,
      userId: params.userId,
      title: params.title,
      description: params.description,
      targetAmount: params.targetAmount,
      currentAmount: params.currentAmount,
      targetDate: params.targetDate,
      createdAt: now,
      status: SavingsGoalStatus.active,
      category: params.category,
      emoji: params.emoji,
      imageUrl: params.imageUrl,
      plan: plan,
      contributions: [],
      settings: settings,
    );
  }

  SavingsPlan _createSavingsPlan(CreateSavingsGoalParams params) {
    if (params.customPlan != null) {
      return params.customPlan!;
    }

    // Auto-calculate optimal plan
    final daysRemaining = params.targetDate.difference(DateTime.now()).inDays;
    final remainingAmount = params.targetAmount - params.currentAmount;

    if (daysRemaining <= 0 || remainingAmount <= 0) {
      return const SavingsPlan(
        type: SavingsPlanType.flexible,
        frequency: SavingsPlanFrequency.monthly,
        autoSave: false,
      );
    }

    // Calculate monthly savings needed
    final monthsRemaining = daysRemaining / 30.0;
    final monthlyRequired = remainingAmount / monthsRemaining;

    SavingsPlanFrequency frequency;
    double planAmount;

    if (monthlyRequired > 1000) {
      // High amount - suggest weekly savings
      frequency = SavingsPlanFrequency.weekly;
      planAmount = monthlyRequired / 4.0;
    } else if (monthlyRequired > 500) {
      // Medium amount - biweekly
      frequency = SavingsPlanFrequency.biweekly;
      planAmount = monthlyRequired / 2.0;
    } else {
      // Low amount - monthly
      frequency = SavingsPlanFrequency.monthly;
      planAmount = monthlyRequired;
    }

    return SavingsPlan(
      type: SavingsPlanType.fixed,
      fixedAmount: planAmount,
      frequency: frequency,
      autoSave: params.enableAutoSave,
    );
  }
}

class CreateSavingsGoalParams {
  final String userId;
  final String title;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final SavingsGoalCategory category;
  final String? emoji;
  final String? imageUrl;
  final SavingsPlan? customPlan;
  final bool enableAutoSave;

  CreateSavingsGoalParams({
    required this.userId,
    required this.title,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.category,
    this.emoji,
    this.imageUrl,
    this.customPlan,
    this.enableAutoSave = false,
  });
}