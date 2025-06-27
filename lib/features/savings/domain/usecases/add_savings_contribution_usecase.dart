import '../entities/savings_goal_entity.dart';
import '../repositories/savings_goal_repository.dart';

class AddSavingsContributionUseCase {
  final SavingsGoalRepository repository;

  AddSavingsContributionUseCase(this.repository);

  Future<SavingsGoalEntity> execute(AddContributionParams params) async {
    // Validate input
    _validateContributionParams(params);

    // Get current goal
    final goal = await repository.getSavingsGoalById(params.goalId);
    if (goal == null) {
      throw ArgumentError('Savings goal not found');
    }

    // Create contribution
    final contribution = _createContribution(params);

    // Add contribution to goal
    final updatedContributions = List<SavingsContribution>.from(goal.contributions)
      ..add(contribution);

    // Calculate new current amount
    final newCurrentAmount = goal.currentAmount + params.amount;

    // Update goal status if needed
    SavingsGoalStatus newStatus = goal.status;
    if (newCurrentAmount >= goal.targetAmount && goal.status == SavingsGoalStatus.active) {
      newStatus = SavingsGoalStatus.completed;
    }

    // Update goal
    final updatedGoal = goal.copyWith(
      currentAmount: newCurrentAmount,
      contributions: updatedContributions,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    // Save updated goal
    final savedGoal = await repository.updateSavingsGoal(updatedGoal);

    // Check and update milestones
    await _checkMilestones(savedGoal);

    // Send notifications if applicable
    await _sendNotifications(savedGoal, contribution);

    return savedGoal;
  }

  void _validateContributionParams(AddContributionParams params) {
    if (params.amount <= 0) {
      throw ArgumentError('Contribution amount must be greater than 0');
    }

    if (params.goalId.trim().isEmpty) {
      throw ArgumentError('Goal ID cannot be empty');
    }
  }

  SavingsContribution _createContribution(AddContributionParams params) {
    final contributionId = DateTime.now().millisecondsSinceEpoch.toString();

    return SavingsContribution(
      id: contributionId,
      goalId: params.goalId,
      amount: params.amount,
      date: params.date ?? DateTime.now(),
      type: params.type,
      note: params.note,
      sourceId: params.sourceId,
    );
  }

  Future<void> _checkMilestones(SavingsGoalEntity goal) async {
    final currentPercentage = goal.progressPercentage;
    final milestonePercentage = goal.settings.milestonePercentage;

    // Check if we've crossed a milestone threshold
    final milestones = [25.0, 50.0, 75.0, 100.0];
    
    for (final milestone in milestones) {
      if (currentPercentage >= milestone) {
        // Check if this milestone was already achieved
        final existingMilestones = await repository.getMilestones(goal.id);
        final alreadyAchieved = existingMilestones.any(
          (m) => m.percentage == milestone && m.isAchieved,
        );

        if (!alreadyAchieved) {
          await repository.achieveMilestone(goal.id, milestone);
        }
      }
    }
  }

  Future<void> _sendNotifications(
    SavingsGoalEntity goal,
    SavingsContribution contribution,
  ) async {
    if (!goal.settings.enableNotifications) return;

    // Send contribution confirmation
    await repository.sendNotification(
      goal.userId,
      'Tasarruf Eklendi! 🎉',
      '${goal.title} hedefine ₺${contribution.amount.toStringAsFixed(0)} eklendi. '
      'Toplam: ₺${goal.currentAmount.toStringAsFixed(0)}',
    );

    // Send milestone notification if applicable
    if (goal.settings.enableMilestoneAlerts) {
      final currentPercentage = goal.progressPercentage;
      final milestones = [25.0, 50.0, 75.0, 100.0];
      
      for (final milestone in milestones) {
        if (currentPercentage >= milestone) {
          String message;
          String emoji;
          
          switch (milestone) {
            case 25.0:
              message = 'Harika! Hedefinin %25\'ini tamamladın! 🚀';
              emoji = '🎯';
              break;
            case 50.0:
              message = 'Yarı yol! Hedefinin %50\'sine ulaştın! 🔥';
              emoji = '🏆';
              break;
            case 75.0:
              message = 'Çok yakın! Hedefinin %75\'i tamam! ⭐';
              emoji = '💪';
              break;
            case 100.0:
              message = 'Tebrikler! ${goal.title} hedefini tamamladın! 🎊';
              emoji = '🎉';
              break;
            default:
              continue;
          }

          await repository.sendNotification(
            goal.userId,
            'Milestone Başarısı! $emoji',
            message,
          );
        }
      }
    }
  }
}

class AddContributionParams {
  final String goalId;
  final double amount;
  final DateTime? date;
  final SavingsContributionType type;
  final String? note;
  final String? sourceId;

  AddContributionParams({
    required this.goalId,
    required this.amount,
    this.date,
    this.type = SavingsContributionType.manual,
    this.note,
    this.sourceId,
  });
}