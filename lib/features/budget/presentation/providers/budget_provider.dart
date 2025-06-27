import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/budget_notification_entity.dart';
import '../../domain/usecases/create_budget_usecase.dart';
import '../../domain/usecases/monitor_budget_usecase.dart';
import '../../data/repositories/budget_repository_impl.dart';

enum BudgetProviderStatus {
  initial,
  loading,
  loaded,
  error,
}

class BudgetState {
  final BudgetProviderStatus status;
  final List<BudgetEntity> budgets;
  final List<BudgetNotificationEntity> notifications;
  final String? errorMessage;
  final double totalBudget;
  final double totalSpent;
  final Map<String, dynamic>? analytics;

  BudgetState({
    this.status = BudgetProviderStatus.initial,
    this.budgets = const [],
    this.notifications = const [],
    this.errorMessage,
    this.totalBudget = 0.0,
    this.totalSpent = 0.0,
    this.analytics,
  });

  BudgetState copyWith({
    BudgetProviderStatus? status,
    List<BudgetEntity>? budgets,
    List<BudgetNotificationEntity>? notifications,
    String? errorMessage,
    double? totalBudget,
    double? totalSpent,
    Map<String, dynamic>? analytics,
  }) {
    return BudgetState(
      status: status ?? this.status,
      budgets: budgets ?? this.budgets,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage ?? this.errorMessage,
      totalBudget: totalBudget ?? this.totalBudget,
      totalSpent: totalSpent ?? this.totalSpent,
      analytics: analytics ?? this.analytics,
    );
  }

  // Bütçe türlerine göre grupla
  List<BudgetEntity> get generalBudgets => 
      budgets.where((budget) => budget.type == BudgetType.general).toList();
  
  List<BudgetEntity> get categoryBudgets => 
      budgets.where((budget) => budget.type == BudgetType.category).toList();
  
  List<BudgetEntity> get subcategoryBudgets => 
      budgets.where((budget) => budget.type == BudgetType.subcategory).toList();

  // Durum bazlı filtreleme
  List<BudgetEntity> get activeBudgets => 
      budgets.where((budget) => budget.status == BudgetStatus.active).toList();
  
  List<BudgetEntity> get exceededBudgets => 
      budgets.where((budget) => budget.isExceeded).toList();
  
  List<BudgetEntity> get warningBudgets => 
      budgets.where((budget) => budget.isWarningReached && !budget.isExceeded).toList();

  // Genel istatistikler
  double get totalRemaining => totalBudget - totalSpent;
  double get overallUsagePercentage => totalBudget > 0 ? totalSpent / totalBudget : 0.0;
  bool get hasExceededBudgets => exceededBudgets.isNotEmpty;
  bool get hasWarningBudgets => warningBudgets.isNotEmpty;

  // Bildirim istatistikleri
  List<BudgetNotificationEntity> get unreadNotifications =>
      notifications.where((notification) => !notification.isRead).toList();
  
  List<BudgetNotificationEntity> get criticalNotifications =>
      notifications.where((notification) => 
        notification.priority == NotificationPriority.critical && !notification.isRead
      ).toList();
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  final BudgetRepositoryImpl _repository;
  late final CreateBudgetUseCase _createBudgetUseCase;
  late final MonitorBudgetUseCase _monitorBudgetUseCase;

  BudgetNotifier() : 
    _repository = BudgetRepositoryImpl(),
    super(BudgetState()) {
    _createBudgetUseCase = CreateBudgetUseCase(_repository);
    _monitorBudgetUseCase = MonitorBudgetUseCase(_repository);
    loadBudgets();
  }

  Future<void> loadBudgets({String? userId}) async {
    state = state.copyWith(status: BudgetProviderStatus.loading);

    try {
      final budgets = await _repository.getBudgets(userId: userId ?? 'user_123');
      final notifications = await _repository.getNotifications(userId ?? 'user_123');
      final totalBudget = await _repository.calculateTotalBudget(userId ?? 'user_123');
      final totalSpent = await _repository.calculateTotalSpent(userId ?? 'user_123');
      
      final analytics = await _repository.getBudgetAnalytics(
        userId ?? 'user_123',
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      );

      state = state.copyWith(
        status: BudgetProviderStatus.loaded,
        budgets: budgets,
        notifications: notifications,
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        analytics: analytics,
        errorMessage: null,
      );

      // Bütçe monitörlemeyi çalıştır
      await monitorBudgets(userId ?? 'user_123');
      
    } catch (e) {
      state = state.copyWith(
        status: BudgetProviderStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> createBudget(CreateBudgetParams params) async {
    try {
      state = state.copyWith(status: BudgetProviderStatus.loading);
      
      final budget = await _createBudgetUseCase.call(params);
      
      final updatedBudgets = [...state.budgets, budget];
      
      state = state.copyWith(
        status: BudgetProviderStatus.loaded,
        budgets: updatedBudgets,
        errorMessage: null,
      );
      
      // Totalleri yeniden hesapla
      await _recalculateTotals(params.userId);
      
    } catch (e) {
      state = state.copyWith(
        status: BudgetProviderStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateBudget(BudgetEntity budget) async {
    try {
      state = state.copyWith(status: BudgetProviderStatus.loading);
      
      final updatedBudget = await _repository.updateBudget(budget);
      
      final updatedBudgets = state.budgets.map((b) => 
        b.id == budget.id ? updatedBudget : b
      ).toList();
      
      state = state.copyWith(
        status: BudgetProviderStatus.loaded,
        budgets: updatedBudgets,
        errorMessage: null,
      );
      
      await _recalculateTotals(budget.userId);
      
    } catch (e) {
      state = state.copyWith(
        status: BudgetProviderStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      state = state.copyWith(status: BudgetProviderStatus.loading);
      
      await _repository.deleteBudget(budgetId);
      
      final updatedBudgets = state.budgets.where((b) => b.id != budgetId).toList();
      final updatedNotifications = state.notifications.where((n) => n.budgetId != budgetId).toList();
      
      state = state.copyWith(
        status: BudgetProviderStatus.loaded,
        budgets: updatedBudgets,
        notifications: updatedNotifications,
        errorMessage: null,
      );
      
      // İlk bütçeden userId'yi al
      if (updatedBudgets.isNotEmpty) {
        await _recalculateTotals(updatedBudgets.first.userId);
      }
      
    } catch (e) {
      state = state.copyWith(
        status: BudgetProviderStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateBudgetSpent(String budgetId, double amount) async {
    try {
      await _repository.updateBudgetSpent(budgetId, amount);
      
      // Bütçeleri yeniden yükle
      final budget = state.budgets.firstWhere((b) => b.id == budgetId);
      await loadBudgets(userId: budget.userId);
      
    } catch (e) {
      state = state.copyWith(
        status: BudgetProviderStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> monitorBudgets(String userId) async {
    try {
      final newNotifications = await _monitorBudgetUseCase.call(userId);
      
      if (newNotifications.isNotEmpty) {
        final allNotifications = [...state.notifications, ...newNotifications];
        
        state = state.copyWith(
          notifications: allNotifications,
        );
        
        // Bütçe durumları değişmiş olabilir, yeniden yükle
        await loadBudgets(userId: userId);
      }
    } catch (e) {
      // Monitörleme hatası sessizce geçilir
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _repository.markNotificationAsRead(notificationId);
      
      final updatedNotifications = state.notifications.map((notification) =>
        notification.id == notificationId 
            ? notification.copyWith(isRead: true, readAt: DateTime.now())
            : notification
      ).toList();
      
      state = state.copyWith(notifications: updatedNotifications);
      
    } catch (e) {
      // Hata sessizce geçilir
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();
      
      state = state.copyWith(notifications: updatedNotifications);
      
    } catch (e) {
      // Hata sessizce geçilir
    }
  }

  Future<void> resetBudgets(String userId, BudgetPeriod period) async {
    try {
      state = state.copyWith(status: BudgetProviderStatus.loading);
      
      await _repository.resetBudgets(userId, period);
      await loadBudgets(userId: userId);
      
    } catch (e) {
      state = state.copyWith(
        status: BudgetProviderStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _recalculateTotals(String userId) async {
    try {
      final totalBudget = await _repository.calculateTotalBudget(userId);
      final totalSpent = await _repository.calculateTotalSpent(userId);
      
      state = state.copyWith(
        totalBudget: totalBudget,
        totalSpent: totalSpent,
      );
    } catch (e) {
      // Hesaplama hatası sessizce geçilir
    }
  }

  // Kategori bazlı bütçe bulma
  BudgetEntity? getBudgetByCategory(String categoryId) {
    try {
      return state.budgets.firstWhere(
        (budget) => budget.categoryId == categoryId && budget.status == BudgetStatus.active
      );
    } catch (e) {
      return null;
    }
  }

  // Bütçe kullanım oranına göre renk
  Color getBudgetColor(BudgetEntity budget) {
    if (budget.isExceeded) {
      return Colors.red;
    } else if (budget.isWarningReached) {
      return Colors.orange;
    } else if (budget.usagePercentage > 0.5) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }
}

// Providers
final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  return BudgetNotifier();
});

// Filtered providers
final activeBudgetsProvider = Provider<List<BudgetEntity>>((ref) {
  final budgetState = ref.watch(budgetProvider);
  return budgetState.activeBudgets;
});

final exceededBudgetsProvider = Provider<List<BudgetEntity>>((ref) {
  final budgetState = ref.watch(budgetProvider);
  return budgetState.exceededBudgets;
});

final warningBudgetsProvider = Provider<List<BudgetEntity>>((ref) {
  final budgetState = ref.watch(budgetProvider);
  return budgetState.warningBudgets;
});

final unreadNotificationsProvider = Provider<List<BudgetNotificationEntity>>((ref) {
  final budgetState = ref.watch(budgetProvider);
  return budgetState.unreadNotifications;
});

final criticalNotificationsProvider = Provider<List<BudgetNotificationEntity>>((ref) {
  final budgetState = ref.watch(budgetProvider);
  return budgetState.criticalNotifications;
});