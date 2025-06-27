import '../entities/budget_entity.dart';
import '../entities/budget_notification_entity.dart';

abstract class BudgetRepository {
  // Budget CRUD operations
  Future<List<BudgetEntity>> getBudgets({String? userId});
  Future<BudgetEntity?> getBudgetById(String id);
  Future<List<BudgetEntity>> getBudgetsByCategory(String categoryId);
  Future<BudgetEntity> createBudget(BudgetEntity budget);
  Future<BudgetEntity> updateBudget(BudgetEntity budget);
  Future<void> deleteBudget(String id);
  
  // Budget calculations
  Future<void> updateBudgetSpent(String budgetId, double amount);
  Future<Map<String, double>> calculateCategorySpending(String userId, DateTime startDate, DateTime endDate);
  Future<double> calculateTotalBudget(String userId);
  Future<double> calculateTotalSpent(String userId);
  
  // Budget monitoring
  Future<List<BudgetEntity>> getExceededBudgets(String userId);
  Future<List<BudgetEntity>> getWarningBudgets(String userId);
  Future<void> resetBudgets(String userId, BudgetPeriod period);
  
  // Notifications
  Future<List<BudgetNotificationEntity>> getNotifications(String userId);
  Future<BudgetNotificationEntity> createNotification(BudgetNotificationEntity notification);
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
  
  // Analytics
  Future<Map<String, dynamic>> getBudgetAnalytics(String userId, DateTime startDate, DateTime endDate);
  Future<List<Map<String, dynamic>>> getBudgetHistory(String userId, int months);
}