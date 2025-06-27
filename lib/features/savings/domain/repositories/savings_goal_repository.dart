import '../entities/savings_goal_entity.dart';

abstract class SavingsGoalRepository {
  // Basic CRUD operations
  Future<SavingsGoalEntity> createSavingsGoal(SavingsGoalEntity goal);
  Future<SavingsGoalEntity> updateSavingsGoal(SavingsGoalEntity goal);
  Future<void> deleteSavingsGoal(String goalId);
  Future<SavingsGoalEntity?> getSavingsGoalById(String goalId);
  Future<List<SavingsGoalEntity>> getSavingsGoalsByUserId(String userId);
  
  // Goal status management
  Future<void> pauseSavingsGoal(String goalId);
  Future<void> resumeSavingsGoal(String goalId);
  Future<void> completeSavingsGoal(String goalId);
  Future<void> cancelSavingsGoal(String goalId);
  
  // Contributions
  Future<void> addContribution(String goalId, SavingsContribution contribution);
  Future<List<SavingsContribution>> getContributions(String goalId);
  Future<void> removeContribution(String contributionId);
  
  // Milestones
  Future<void> generateMilestones(String goalId);
  Future<List<SavingsMilestone>> getMilestones(String goalId);
  Future<void> achieveMilestone(String goalId, double percentage);
  
  // Templates
  Future<List<SavingsGoalTemplate>> getGoalTemplates();
  Future<SavingsGoalEntity> createGoalFromTemplate(
    String userId,
    String templateId,
    double targetAmount,
    DateTime targetDate,
  );
  
  // Analytics
  Future<SavingsAnalytics> getGoalAnalytics(String goalId);
  Future<List<SavingsGoalEntity>> getGoalsByCategory(
    String userId,
    SavingsGoalCategory category,
  );
  Future<List<SavingsGoalEntity>> getGoalsByStatus(
    String userId,
    SavingsGoalStatus status,
  );
  
  // Auto-save functionality
  Future<void> enableAutoSave(String goalId, double amount, SavingsPlanFrequency frequency);
  Future<void> disableAutoSave(String goalId);
  Future<void> processAutoSave();
  
  // Notifications
  Future<void> sendNotification(String userId, String title, String message);
  Future<void> scheduleReminder(String goalId, DateTime reminderDate);
  Future<void> cancelReminder(String goalId);
  
  // Search and filtering
  Future<List<SavingsGoalEntity>> searchGoals(String userId, String query);
  Future<List<SavingsGoalEntity>> getGoalsWithFilters({
    required String userId,
    SavingsGoalStatus? status,
    SavingsGoalCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  });
  
  // Statistics
  Future<Map<String, dynamic>> getUserSavingsStats(String userId);
  Future<double> getTotalSavingsAmount(String userId);
  Future<int> getCompletedGoalsCount(String userId);
  Future<List<SavingsGoalEntity>> getRecentGoals(String userId, int limit);
}