import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/budget_notification_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../categories/data/datasources/default_categories.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  // Mock data storage
  final List<BudgetEntity> _budgets = [];
  final List<BudgetNotificationEntity> _notifications = [];
  
  BudgetRepositoryImpl() {
    _initializeMockData();
  }
  
  void _initializeMockData() {
    final now = DateTime.now();
    final categories = DefaultCategories.getDefaultCategories();
    
    // Genel bütçe
    _budgets.add(BudgetEntity(
      id: 'budget_general_001',
      userId: 'user_123',
      name: 'Aylık Genel Bütçe',
      description: 'Toplam aylık harcama bütçesi',
      amount: 8000.0,
      spent: 3500.0,
      type: BudgetType.general,
      period: BudgetPeriod.monthly,
      status: BudgetStatus.active,
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
      createdAt: now,
    ));
    
    // Kategori bazlı bütçeler
    for (int i = 0; i < categories.length && i < 5; i++) {
      final category = categories[i];
      final amounts = [1000.0, 1500.0, 800.0, 600.0, 400.0];
      final spent = [450.0, 1200.0, 900.0, 300.0, 150.0];
      
      _budgets.add(BudgetEntity(
        id: 'budget_${category.id}',
        userId: 'user_123',
        categoryId: category.id,
        name: '${category.name} Bütçesi',
        description: '${category.name} kategorisi aylık bütçesi',
        amount: amounts[i],
        spent: spent[i],
        type: BudgetType.category,
        period: BudgetPeriod.monthly,
        status: spent[i] > amounts[i] 
            ? BudgetStatus.exceeded 
            : spent[i] > amounts[i] * 0.8 
                ? BudgetStatus.warning 
                : BudgetStatus.active,
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        createdAt: now,
      ));
    }
  }
  
  @override
  Future<List<BudgetEntity>> getBudgets({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (userId == null) return _budgets;
    return _budgets.where((budget) => budget.userId == userId).toList();
  }
  
  @override
  Future<BudgetEntity?> getBudgetById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<List<BudgetEntity>> getBudgetsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _budgets
        .where((budget) => budget.categoryId == categoryId)
        .toList();
  }
  
  @override
  Future<BudgetEntity> createBudget(BudgetEntity budget) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    _budgets.add(budget);
    return budget;
  }
  
  @override
  Future<BudgetEntity> updateBudget(BudgetEntity budget) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget.copyWith(updatedAt: DateTime.now());
      return _budgets[index];
    }
    
    throw Exception('Budget not found');
  }
  
  @override
  Future<void> deleteBudget(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    _budgets.removeWhere((budget) => budget.id == id);
    _notifications.removeWhere((notification) => notification.budgetId == id);
  }
  
  @override
  Future<void> updateBudgetSpent(String budgetId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _budgets.indexWhere((budget) => budget.id == budgetId);
    if (index != -1) {
      final budget = _budgets[index];
      final newSpent = budget.spent + amount;
      
      BudgetStatus newStatus = budget.status;
      if (newSpent > budget.amount) {
        newStatus = BudgetStatus.exceeded;
      } else if (newSpent > budget.amount * (budget.warningThreshold ?? 0.8)) {
        newStatus = BudgetStatus.warning;
      }
      
      _budgets[index] = budget.copyWith(
        spent: newSpent,
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    }
  }
  
  @override
  Future<Map<String, double>> calculateCategorySpending(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final userBudgets = _budgets.where((budget) => 
      budget.userId == userId &&
      budget.categoryId != null &&
      budget.startDate.isBefore(endDate) &&
      budget.endDate.isAfter(startDate)
    ).toList();
    
    final categorySpending = <String, double>{};
    
    for (final budget in userBudgets) {
      categorySpending[budget.categoryId!] = budget.spent;
    }
    
    return categorySpending;
  }
  
  @override
  Future<double> calculateTotalBudget(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final userBudgets = _budgets.where((budget) => 
      budget.userId == userId && 
      budget.status == BudgetStatus.active
    ).toList();
    
    return userBudgets.fold<double>(0.0, (sum, budget) => sum + budget.amount);
  }
  
  @override
  Future<double> calculateTotalSpent(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final userBudgets = _budgets.where((budget) => 
      budget.userId == userId && 
      budget.status == BudgetStatus.active
    ).toList();
    
    return userBudgets.fold<double>(0.0, (sum, budget) => sum + budget.spent);
  }
  
  @override
  Future<List<BudgetEntity>> getExceededBudgets(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _budgets
        .where((budget) => 
          budget.userId == userId && 
          budget.status == BudgetStatus.exceeded
        )
        .toList();
  }
  
  @override
  Future<List<BudgetEntity>> getWarningBudgets(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _budgets
        .where((budget) => 
          budget.userId == userId && 
          budget.status == BudgetStatus.warning
        )
        .toList();
  }
  
  @override
  Future<void> resetBudgets(String userId, BudgetPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final now = DateTime.now();
    
    for (int i = 0; i < _budgets.length; i++) {
      final budget = _budgets[i];
      
      if (budget.userId == userId && 
          budget.period == period && 
          budget.autoReset &&
          budget.endDate.isBefore(now)) {
        
        DateTime newStartDate;
        DateTime newEndDate;
        
        switch (period) {
          case BudgetPeriod.weekly:
            newStartDate = budget.endDate.add(const Duration(days: 1));
            newEndDate = newStartDate.add(const Duration(days: 7));
            break;
          case BudgetPeriod.monthly:
            newStartDate = DateTime(budget.endDate.year, budget.endDate.month + 1, 1);
            newEndDate = DateTime(newStartDate.year, newStartDate.month + 1, 0);
            break;
          case BudgetPeriod.quarterly:
            newStartDate = budget.endDate.add(const Duration(days: 1));
            newEndDate = newStartDate.add(const Duration(days: 90));
            break;
          case BudgetPeriod.yearly:
            newStartDate = DateTime(budget.endDate.year + 1, 1, 1);
            newEndDate = DateTime(newStartDate.year, 12, 31);
            break;
        }
        
        _budgets[i] = budget.copyWith(
          spent: 0.0,
          status: BudgetStatus.active,
          startDate: newStartDate,
          endDate: newEndDate,
          updatedAt: now,
        );
      }
    }
  }
  
  // Notification methods
  @override
  Future<List<BudgetNotificationEntity>> getNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _notifications
        .where((notification) => 
          notification.userId == userId && 
          !notification.isExpired
        )
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  @override
  Future<BudgetNotificationEntity> createNotification(BudgetNotificationEntity notification) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    _notifications.add(notification);
    return notification;
  }
  
  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
    }
  }
  
  @override
  Future<void> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    _notifications.removeWhere((notification) => notification.id == notificationId);
  }
  
  // Analytics methods
  @override
  Future<Map<String, dynamic>> getBudgetAnalytics(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final userBudgets = _budgets.where((budget) => 
      budget.userId == userId &&
      budget.startDate.isBefore(endDate) &&
      budget.endDate.isAfter(startDate)
    ).toList();
    
    final totalBudget = userBudgets.fold<double>(0.0, (sum, budget) => sum + budget.amount);
    final totalSpent = userBudgets.fold<double>(0.0, (sum, budget) => sum + budget.spent);
    final averageUsage = userBudgets.isNotEmpty 
        ? userBudgets.fold<double>(0.0, (sum, budget) => sum + budget.usagePercentage) / userBudgets.length
        : 0.0;
    
    final exceededCount = userBudgets.where((budget) => budget.isExceeded).length;
    final warningCount = userBudgets.where((budget) => budget.isWarningReached).length;
    
    return {
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
      'totalRemaining': totalBudget - totalSpent,
      'averageUsage': averageUsage,
      'budgetCount': userBudgets.length,
      'exceededCount': exceededCount,
      'warningCount': warningCount,
      'successRate': userBudgets.isNotEmpty 
          ? (userBudgets.length - exceededCount) / userBudgets.length
          : 0.0,
    };
  }
  
  @override
  Future<List<Map<String, dynamic>>> getBudgetHistory(String userId, int months) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock budget history data
    final history = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    for (int i = 0; i < months; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      
      history.add({
        'month': month,
        'totalBudget': 8000.0 - (i * 200),
        'totalSpent': 6500.0 - (i * 300),
        'budgetCount': 5,
        'exceededCount': i % 3 == 0 ? 1 : 0,
        'successRate': i % 3 == 0 ? 0.8 : 0.9,
      });
    }
    
    return history;
  }
}