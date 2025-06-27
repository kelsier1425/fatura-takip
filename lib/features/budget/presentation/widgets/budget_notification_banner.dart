import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/budget_notification_entity.dart';

class BudgetNotificationBanner extends StatelessWidget {
  final List<BudgetNotificationEntity> notifications;
  final Function(String) onDismiss;

  const BudgetNotificationBanner({
    Key? key,
    required this.notifications,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) return const SizedBox.shrink();

    // En kritik bildirimi göster
    final topNotification = notifications.first;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getNotificationColor(topNotification).withOpacity(0.1),
                _getNotificationColor(topNotification).withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(topNotification).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNotificationIcon(topNotification),
                      color: _getNotificationColor(topNotification),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topNotification.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getNotificationColor(topNotification),
                          ),
                        ),
                        if (notifications.length > 1)
                          Text(
                            '+${notifications.length - 1} diğer bildirim',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => onDismiss(topNotification.id),
                    iconSize: 20,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                topNotification.message,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (topNotification.isActionRequired) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onDismiss(topNotification.id),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _getNotificationColor(topNotification)),
                        ),
                        child: Text(
                          'Daha Sonra',
                          style: TextStyle(color: _getNotificationColor(topNotification)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle action based on notification type
                          _handleNotificationAction(context, topNotification);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getNotificationColor(topNotification),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Görüntüle'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().slideY(
      begin: -1,
      duration: 500.ms,
      curve: Curves.elasticOut,
    );
  }

  Color _getNotificationColor(BudgetNotificationEntity notification) {
    switch (notification.type) {
      case BudgetNotificationType.exceeded:
        return AppColors.error;
      case BudgetNotificationType.warning:
        return AppColors.warning;
      case BudgetNotificationType.achievement:
        return AppColors.success;
      case BudgetNotificationType.reminder:
        return AppColors.info;
      case BudgetNotificationType.reset:
        return AppColors.accent;
    }
  }

  IconData _getNotificationIcon(BudgetNotificationEntity notification) {
    switch (notification.type) {
      case BudgetNotificationType.exceeded:
        return Icons.error_outline;
      case BudgetNotificationType.warning:
        return Icons.warning_outlined;
      case BudgetNotificationType.achievement:
        return Icons.celebration_outlined;
      case BudgetNotificationType.reminder:
        return Icons.alarm_outlined;
      case BudgetNotificationType.reset:
        return Icons.refresh_outlined;
    }
  }

  void _handleNotificationAction(BuildContext context, BudgetNotificationEntity notification) {
    switch (notification.type) {
      case BudgetNotificationType.exceeded:
      case BudgetNotificationType.warning:
        // Navigate to budget detail or spending analysis
        break;
      case BudgetNotificationType.achievement:
        // Show achievement dialog or navigate to achievements
        _showAchievementDialog(context, notification);
        break;
      case BudgetNotificationType.reminder:
        // Navigate to budget settings or create new budget
        break;
      case BudgetNotificationType.reset:
        // Navigate to budget overview
        break;
    }
  }

  void _showAchievementDialog(BuildContext context, BudgetNotificationEntity notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.celebration,
              color: AppColors.success,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Tebrikler!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.savings,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasarruf Ettiğiniz Miktar',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '₺${notification.data?['savedAmount']?.toStringAsFixed(2) ?? '0.00'}',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to achievements or savings goals
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hedeflerimi Gör'),
          ),
        ],
      ),
    );
  }
}