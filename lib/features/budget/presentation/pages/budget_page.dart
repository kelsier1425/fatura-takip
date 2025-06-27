import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/budget_list_item.dart';
import '../widgets/budget_notification_banner.dart';
import '../widgets/create_budget_dialog.dart';
import '../providers/budget_provider.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/budget_notification_entity.dart';
import '../../domain/usecases/create_budget_usecase.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Bütçeleri yükle
    Future.microtask(() {
      ref.read(budgetProvider.notifier).loadBudgets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetProvider);
    final theme = Theme.of(context);

    return LoadingOverlay(
      isLoading: budgetState.status == BudgetProviderStatus.loading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Bütçe Yönetimi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Genel Bakış', icon: Icon(Icons.dashboard_outlined)),
              Tab(text: 'Kategoriler', icon: Icon(Icons.category_outlined)),
              Tab(text: 'Bildirimler', icon: Icon(Icons.notifications_outlined)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showCreateBudgetDialog(),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'analytics':
                    context.push('/budget/analytics');
                    break;
                  case 'settings':
                    context.push('/budget/settings');
                    break;
                  case 'reset':
                    _showResetDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'analytics',
                  child: Row(
                    children: [
                      Icon(Icons.analytics_outlined),
                      SizedBox(width: 8),
                      Text('Analiz'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined),
                      SizedBox(width: 8),
                      Text('Ayarlar'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Bütçeleri Sıfırla'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Kritik bildirimler banner'ı
            if (budgetState.criticalNotifications.isNotEmpty)
              BudgetNotificationBanner(
                notifications: budgetState.criticalNotifications,
                onDismiss: (notificationId) {
                  ref.read(budgetProvider.notifier).markNotificationAsRead(notificationId);
                },
              ),
            
            // Tab view
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(budgetState, theme),
                  _buildCategoriesTab(budgetState, theme),
                  _buildNotificationsTab(budgetState, theme),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateBudgetDialog,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BudgetState budgetState, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () => ref.read(budgetProvider.notifier).loadBudgets(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel bütçe özeti
            BudgetOverviewCard(
              totalBudget: budgetState.totalBudget,
              totalSpent: budgetState.totalSpent,
              budgetCount: budgetState.budgets.length,
              exceededCount: budgetState.exceededBudgets.length,
              warningCount: budgetState.warningBudgets.length,
              analytics: budgetState.analytics,
            ),
            
            const SizedBox(height: 24),
            
            // Durum bazlı bütçe listesi
            if (budgetState.exceededBudgets.isNotEmpty) ...[
              _buildSectionHeader(
                'Aşılan Bütçeler',
                budgetState.exceededBudgets.length,
                Colors.red,
                theme,
              ),
              const SizedBox(height: 12),
              ...budgetState.exceededBudgets.asMap().entries.map((entry) {
                final index = entry.key;
                final budget = entry.value;
                return BudgetListItem(
                  budget: budget,
                  onTap: () => _showBudgetDetail(budget),
                  onEdit: () => _showEditBudgetDialog(budget),
                  onDelete: () => _deleteBudget(budget),
                ).animate().slideX(
                  begin: 1,
                  duration: 200.ms,
                  delay: Duration(milliseconds: index * 30),
                );
              }).toList(),
              const SizedBox(height: 24),
            ],
            
            if (budgetState.warningBudgets.isNotEmpty) ...[
              _buildSectionHeader(
                'Uyarı Durumundaki Bütçeler',
                budgetState.warningBudgets.length,
                Colors.orange,
                theme,
              ),
              const SizedBox(height: 12),
              ...budgetState.warningBudgets.asMap().entries.map((entry) {
                final index = entry.key;
                final budget = entry.value;
                return BudgetListItem(
                  budget: budget,
                  onTap: () => _showBudgetDetail(budget),
                  onEdit: () => _showEditBudgetDialog(budget),
                  onDelete: () => _deleteBudget(budget),
                ).animate().slideX(
                  begin: 1,
                  duration: 200.ms,
                  delay: Duration(milliseconds: index * 30),
                );
              }).toList(),
              const SizedBox(height: 24),
            ],
            
            if (budgetState.activeBudgets.isNotEmpty) ...[
              _buildSectionHeader(
                'Aktif Bütçeler',
                budgetState.activeBudgets.length,
                Colors.green,
                theme,
              ),
              const SizedBox(height: 12),
              ...budgetState.activeBudgets.asMap().entries.map((entry) {
                final index = entry.key;
                final budget = entry.value;
                return BudgetListItem(
                  budget: budget,
                  onTap: () => _showBudgetDetail(budget),
                  onEdit: () => _showEditBudgetDialog(budget),
                  onDelete: () => _deleteBudget(budget),
                ).animate().slideX(
                  begin: 1,
                  duration: 200.ms,
                  delay: Duration(milliseconds: index * 30),
                );
              }).toList(),
            ],
            
            if (budgetState.budgets.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz bütçe oluşturmadınız',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Harcamalarınızı kontrol altında tutmak için\nbütçe oluşturun',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showCreateBudgetDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('İlk Bütçenizi Oluşturun'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(BudgetState budgetState, ThemeData theme) {
    final categoryBudgets = budgetState.categoryBudgets;
    
    return RefreshIndicator(
      onRefresh: () => ref.read(budgetProvider.notifier).loadBudgets(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categoryBudgets.length,
        itemBuilder: (context, index) {
          final budget = categoryBudgets[index];
          
          return BudgetListItem(
            budget: budget,
            showCategory: true,
            onTap: () => _showBudgetDetail(budget),
            onEdit: () => _showEditBudgetDialog(budget),
            onDelete: () => _deleteBudget(budget),
          ).animate().fadeIn(
            duration: 200.ms,
            delay: Duration(milliseconds: index * 50),
          );
        },
      ),
    );
  }

  Widget _buildNotificationsTab(BudgetState budgetState, ThemeData theme) {
    final notifications = budgetState.notifications;
    
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Bildirim bulunmuyor',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bütçe uyarıları burada görünecektir',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getNotificationColor(notification).withOpacity(0.1),
              child: Icon(
                _getNotificationIcon(notification),
                color: _getNotificationColor(notification),
              ),
            ),
            title: Text(
              notification.title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message),
                const SizedBox(height: 4),
                Text(
                  _formatNotificationDate(notification.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: notification.isRead 
                ? null 
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
            onTap: () {
              if (!notification.isRead) {
                ref.read(budgetProvider.notifier).markNotificationAsRead(notification.id);
              }
            },
          ),
        ).animate().slideX(
          begin: 1,
          duration: 200.ms,
          delay: Duration(milliseconds: index * 30),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Color _getNotificationColor(BudgetNotificationEntity notification) {
    switch (notification.type) {
      case BudgetNotificationType.exceeded:
        return Colors.red;
      case BudgetNotificationType.warning:
        return Colors.orange;
      case BudgetNotificationType.achievement:
        return Colors.green;
      case BudgetNotificationType.reminder:
        return Colors.blue;
      case BudgetNotificationType.reset:
        return Colors.purple;
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

  String _formatNotificationDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  void _showCreateBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateBudgetDialog(
        onBudgetCreated: (params) {
          ref.read(budgetProvider.notifier).createBudget(params);
        },
      ),
    );
  }

  void _showEditBudgetDialog(BudgetEntity budget) {
    showDialog(
      context: context,
      builder: (context) => CreateBudgetDialog(
        budget: budget,
        onBudgetCreated: (params) {
          // Convert params to budget and update
          final updatedBudget = budget.copyWith(
            name: params.name,
            description: params.description,
            amount: params.amount,
            warningThreshold: params.warningThreshold,
            enableNotifications: params.enableNotifications,
          );
          ref.read(budgetProvider.notifier).updateBudget(updatedBudget);
        },
      ),
    );
  }

  void _showBudgetDetail(BudgetEntity budget) {
    context.push('/budget/detail/${budget.id}');
  }

  void _deleteBudget(BudgetEntity budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bütçeyi Sil'),
        content: Text('${budget.name} bütçesini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(budgetProvider.notifier).deleteBudget(budget.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bütçeleri Sıfırla'),
        content: const Text(
          'Tüm bütçeleri sıfırlamak istediğinizden emin misiniz? '
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(budgetProvider.notifier).resetBudgets('user_123', BudgetPeriod.monthly);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }
}