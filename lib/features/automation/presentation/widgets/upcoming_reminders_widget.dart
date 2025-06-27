import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../../core/constants/app_colors.dart';

class UpcomingRemindersWidget extends StatelessWidget {
  const UpcomingRemindersWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Demo data - TODO: Replace with actual reminder data
    final upcomingReminders = _generateDemoReminders();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.warning, AppColors.warning.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Yaklaşan Ödemeler',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem(
                    context: context,
                    label: 'Bu Hafta',
                    count: upcomingReminders.where((r) => r.daysUntil <= 7).length,
                    color: Colors.white,
                  ),
                  _buildSummaryItem(
                    context: context,
                    label: 'Bu Ay',
                    count: upcomingReminders.length,
                    color: Colors.white,
                  ),
                  _buildSummaryItem(
                    context: context,
                    label: 'Toplam Tutar',
                    count: upcomingReminders.fold(0.0, (sum, r) => sum + r.expense.amount).toInt(),
                    color: Colors.white,
                    prefix: '₺',
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Tümü', true),
              const SizedBox(width: 8),
              _buildFilterChip('Bu Hafta', false),
              const SizedBox(width: 8),
              _buildFilterChip('Acil', false),
              const SizedBox(width: 8),
              _buildFilterChip('Faturalar', false),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Reminders List
        if (upcomingReminders.isEmpty)
          _buildEmptyState(theme)
        else
          ...upcomingReminders.map((reminder) {
            return _buildReminderCard(context, reminder);
          }).toList(),
      ],
    );
  }
  
  Widget _buildSummaryItem({
    required BuildContext context,
    required String label,
    required int count,
    required Color color,
    String? prefix,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          '${prefix ?? ''}$count',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      selected: isSelected,
      onSelected: (_) {},
      label: Text(label),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
    );
  }
  
  Widget _buildReminderCard(BuildContext context, ReminderItem reminder) {
    final theme = Theme.of(context);
    final isUrgent = reminder.daysUntil <= 3;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Urgency Indicator
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: isUrgent ? AppColors.error : AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reminder.expense.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isUrgent 
                              ? AppColors.error.withOpacity(0.1) 
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          reminder.daysUntil == 0 
                              ? 'Bugün' 
                              : '${reminder.daysUntil} gün',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isUrgent ? AppColors.error : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy', 'tr').format(reminder.expense.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      ),
                      Text(
                        '₺${reminder.expense.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: Mark as paid
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  color: AppColors.success,
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Snooze reminder
                  },
                  icon: const Icon(Icons.snooze),
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Yaklaşan hatırlatıcı yok',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tüm ödemeleriniz güncel görünüyor',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  List<ReminderItem> _generateDemoReminders() {
    final now = DateTime.now();
    return [
      ReminderItem(
        expense: ExpenseEntity(
          id: 'reminder_1',
          userId: 'guest',
          categoryId: 'home',
          title: 'Elektrik Faturası',
          amount: 180.50,
          date: now.add(const Duration(days: 2)),
          type: ExpenseType.bill,
          createdAt: now,
        ),
        daysUntil: 2,
      ),
      ReminderItem(
        expense: ExpenseEntity(
          id: 'reminder_2',
          userId: 'guest',
          categoryId: 'subscription',
          title: 'Netflix Abonelik',
          amount: 29.99,
          date: now.add(const Duration(days: 5)),
          type: ExpenseType.subscription,
          createdAt: now,
        ),
        daysUntil: 5,
      ),
      ReminderItem(
        expense: ExpenseEntity(
          id: 'reminder_3',
          userId: 'guest',
          categoryId: 'home',
          title: 'İnternet Faturası',
          amount: 75.00,
          date: now.add(const Duration(days: 7)),
          type: ExpenseType.bill,
          createdAt: now,
        ),
        daysUntil: 7,
      ),
    ];
  }
}

class ReminderItem {
  final ExpenseEntity expense;
  final int daysUntil;
  
  ReminderItem({
    required this.expense,
    required this.daysUntil,
  });
}