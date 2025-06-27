import '../entities/budget_entity.dart';
import '../entities/budget_notification_entity.dart';
import '../repositories/budget_repository.dart';

class MonitorBudgetUseCase {
  final BudgetRepository repository;
  
  MonitorBudgetUseCase(this.repository);
  
  Future<List<BudgetNotificationEntity>> call(String userId) async {
    final budgets = await repository.getBudgets(userId: userId);
    final notifications = <BudgetNotificationEntity>[];
    
    for (final budget in budgets) {
      if (budget.status != BudgetStatus.active) continue;
      
      // Bütçe aşıldı mı?
      if (budget.isExceeded && budget.status != BudgetStatus.exceeded) {
        notifications.add(await _createExceededNotification(budget));
        
        // Bütçe durumunu güncelle
        await repository.updateBudget(
          budget.copyWith(status: BudgetStatus.exceeded)
        );
      }
      // Uyarı eşiğine ulaşıldı mı?
      else if (budget.isWarningReached && budget.status != BudgetStatus.warning) {
        notifications.add(await _createWarningNotification(budget));
        
        // Bütçe durumunu güncelle
        await repository.updateBudget(
          budget.copyWith(status: BudgetStatus.warning)
        );
      }
      
      // Başarı bildirimi (dönem sonunda bütçe tutturuldu)
      if (_isPeriodEnding(budget) && !budget.isExceeded) {
        notifications.add(await _createAchievementNotification(budget));
      }
    }
    
    return notifications;
  }
  
  Future<BudgetNotificationEntity> _createExceededNotification(BudgetEntity budget) async {
    final overAmount = budget.spent - budget.amount;
    
    final notification = BudgetNotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: budget.userId,
      budgetId: budget.id,
      type: BudgetNotificationType.exceeded,
      priority: NotificationPriority.critical,
      title: 'Bütçe Aşıldı! ⚠️',
      message: '${budget.name} bütçeniz ₺${overAmount.toStringAsFixed(2)} aşıldı. '
               'Harcamalarınızı gözden geçirmenizi öneririz.',
      data: {
        'budgetId': budget.id,
        'budgetName': budget.name,
        'budgetAmount': budget.amount,
        'spentAmount': budget.spent,
        'overAmount': overAmount,
        'categoryId': budget.categoryId,
      },
      isActionRequired: true,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    
    return await repository.createNotification(notification);
  }
  
  Future<BudgetNotificationEntity> _createWarningNotification(BudgetEntity budget) async {
    final percentage = (budget.usagePercentage * 100).toInt();
    
    final notification = BudgetNotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: budget.userId,
      budgetId: budget.id,
      type: BudgetNotificationType.warning,
      priority: NotificationPriority.high,
      title: 'Bütçe Uyarısı 📊',
      message: '${budget.name} bütçenizin %$percentage\'ini kullandınız. '
               'Kalan miktar: ₺${budget.remaining.toStringAsFixed(2)}',
      data: {
        'budgetId': budget.id,
        'budgetName': budget.name,
        'budgetAmount': budget.amount,
        'spentAmount': budget.spent,
        'remainingAmount': budget.remaining,
        'usagePercentage': budget.usagePercentage,
        'categoryId': budget.categoryId,
      },
      isActionRequired: false,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 3)),
    );
    
    return await repository.createNotification(notification);
  }
  
  Future<BudgetNotificationEntity> _createAchievementNotification(BudgetEntity budget) async {
    final savedAmount = budget.remaining;
    
    final notification = BudgetNotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: budget.userId,
      budgetId: budget.id,
      type: BudgetNotificationType.achievement,
      priority: NotificationPriority.medium,
      title: 'Tebrikler! 🎉',
      message: '${budget.name} bütçenizi başarıyla tutturdunuz! '
               '₺${savedAmount.toStringAsFixed(2)} tasarruf ettiniz.',
      data: {
        'budgetId': budget.id,
        'budgetName': budget.name,
        'budgetAmount': budget.amount,
        'spentAmount': budget.spent,
        'savedAmount': savedAmount,
        'categoryId': budget.categoryId,
      },
      isActionRequired: false,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    
    return await repository.createNotification(notification);
  }
  
  bool _isPeriodEnding(BudgetEntity budget) {
    final now = DateTime.now();
    final daysRemaining = budget.endDate.difference(now).inDays;
    return daysRemaining <= 1 && daysRemaining >= 0;
  }
}