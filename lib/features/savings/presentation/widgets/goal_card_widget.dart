import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/usecases/add_savings_contribution_usecase.dart';
import '../providers/savings_goal_provider.dart';

class GoalCardWidget extends ConsumerWidget {
  final SavingsGoalEntity goal;
  final SavingsAnalytics? analytics;

  const GoalCardWidget({
    super.key,
    required this.goal,
    this.analytics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showGoalDetails(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(goal.status).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 12),
              
              // Progress bar
              _buildProgressBar(context),
              const SizedBox(height: 12),
              
              // Amount info
              _buildAmountInfo(context),
              const SizedBox(height: 12),
              
              // Status and actions
              _buildStatusAndActions(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Emoji/Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCategoryColor(goal.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              goal.emoji ?? _getCategoryEmoji(goal.category),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Title and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              if (goal.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  goal.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
        
        // Menu
        Consumer(
          builder: (context, ref, child) => PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(context, value, ref),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_contribution',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 8),
                    Text('Katkı Ekle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Düzenle'),
                  ],
                ),
              ),
              if (goal.status == SavingsGoalStatus.active)
                const PopupMenuItem(
                  value: 'pause',
                  child: Row(
                    children: [
                      Icon(Icons.pause_circle_outline),
                      SizedBox(width: 8),
                      Text('Duraklat'),
                    ],
                  ),
                ),
              if (goal.status == SavingsGoalStatus.paused)
                const PopupMenuItem(
                  value: 'resume',
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_outline),
                      SizedBox(width: 8),
                      Text('Devam Et'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'İlerleme',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${goal.progressPercentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getProgressColor(goal.progressPercentage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: goal.progressPercentage / 100,
            backgroundColor: Theme.of(context).dividerColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(goal.progressPercentage),
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInfo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mevcut',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              Text(
                '₺${goal.currentAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hedef',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              Text(
                '₺${goal.targetAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kalan',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              Text(
                '₺${goal.remainingAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAndActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Time remaining
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                _getTimeRemainingText(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        
        // Quick action button
        if (goal.status == SavingsGoalStatus.active)
          Consumer(
            builder: (context, ref, child) => ElevatedButton.icon(
              onPressed: () => _showAddContributionDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ekle'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(goal.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(goal.status),
        style: TextStyle(
          color: _getStatusColor(goal.status),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getTimeRemainingText() {
    if (goal.isCompleted) return 'Tamamlandı';
    if (goal.isOverdue) return 'Süresi geçti';
    
    final days = goal.daysRemaining;
    if (days <= 0) return 'Bugün bitiyor';
    if (days == 1) return '1 gün kaldı';
    if (days < 30) return '$days gün kaldı';
    
    final months = (days / 30).round();
    if (months == 1) return '1 ay kaldı';
    return '$months ay kaldı';
  }

  String _getStatusText(SavingsGoalStatus status) {
    switch (status) {
      case SavingsGoalStatus.active:
        return 'Aktif';
      case SavingsGoalStatus.paused:
        return 'Duraklatıldı';
      case SavingsGoalStatus.completed:
        return 'Tamamlandı';
      case SavingsGoalStatus.cancelled:
        return 'İptal Edildi';
      case SavingsGoalStatus.overdue:
        return 'Süresi Geçti';
    }
  }

  Color _getStatusColor(SavingsGoalStatus status) {
    switch (status) {
      case SavingsGoalStatus.active:
        return Colors.green;
      case SavingsGoalStatus.paused:
        return Colors.orange;
      case SavingsGoalStatus.completed:
        return Colors.blue;
      case SavingsGoalStatus.cancelled:
        return Colors.red;
      case SavingsGoalStatus.overdue:
        return Colors.red;
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    if (percentage >= 25) return Colors.blue;
    return Colors.red;
  }

  Color _getCategoryColor(SavingsGoalCategory category) {
    switch (category) {
      case SavingsGoalCategory.emergency:
        return Colors.red;
      case SavingsGoalCategory.vacation:
        return Colors.orange;
      case SavingsGoalCategory.house:
        return Colors.blue;
      case SavingsGoalCategory.car:
        return Colors.green;
      case SavingsGoalCategory.education:
        return Colors.purple;
      case SavingsGoalCategory.wedding:
        return Colors.pink;
      case SavingsGoalCategory.retirement:
        return Colors.brown;
      case SavingsGoalCategory.health:
        return Colors.teal;
      case SavingsGoalCategory.technology:
        return Colors.indigo;
      case SavingsGoalCategory.gift:
        return Colors.amber;
      case SavingsGoalCategory.debt:
        return Colors.grey;
      case SavingsGoalCategory.investment:
        return Colors.deepPurple;
      case SavingsGoalCategory.other:
        return Colors.blueGrey;
    }
  }

  String _getCategoryEmoji(SavingsGoalCategory category) {
    switch (category) {
      case SavingsGoalCategory.emergency:
        return '🚨';
      case SavingsGoalCategory.vacation:
        return '🏖️';
      case SavingsGoalCategory.house:
        return '🏠';
      case SavingsGoalCategory.car:
        return '🚗';
      case SavingsGoalCategory.education:
        return '🎓';
      case SavingsGoalCategory.wedding:
        return '💒';
      case SavingsGoalCategory.retirement:
        return '👴';
      case SavingsGoalCategory.health:
        return '🏥';
      case SavingsGoalCategory.technology:
        return '💻';
      case SavingsGoalCategory.gift:
        return '🎁';
      case SavingsGoalCategory.debt:
        return '💳';
      case SavingsGoalCategory.investment:
        return '📈';
      case SavingsGoalCategory.other:
        return '💰';
    }
  }

  void _showGoalDetails(BuildContext context, WidgetRef ref) {
    context.go('/savings/goals/${goal.id}');
  }

  void _handleMenuAction(BuildContext context, String action, [WidgetRef? ref]) {
    switch (action) {
      case 'add_contribution':
        if (ref != null) {
          _showAddContributionDialog(context, ref);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Katkı ekleme özelliği yakında eklenecek')),
          );
        }
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Düzenleme özelliği yakında eklenecek')),
        );
        break;
      case 'pause':
        _showConfirmDialog(
          context,
          'Hedefi Duraklat',
          '${goal.title} hedefini duraklatmak istediğinizden emin misiniz?',
          () {
            // TODO: Implement pause goal
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hedef duraklatıldı')),
            );
          },
        );
        break;
      case 'resume':
        _showConfirmDialog(
          context,
          'Hedefi Devam Ettir',
          '${goal.title} hedefini devam ettirmek istediğinizden emin misiniz?',
          () {
            // TODO: Implement resume goal
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hedef devam ettirildi')),
            );
          },
        );
        break;
      case 'delete':
        _showConfirmDialog(
          context,
          'Hedefi Sil',
          '${goal.title} hedefini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          () {
            // TODO: Implement delete goal
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hedef silindi')),
            );
          },
        );
        break;
    }
  }

  void _showAddContributionDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Katkı Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Miktar (₺)',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Not (isteğe bağlı)',
                prefixIcon: Icon(Icons.note),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                try {
                  await ref.read(savingsGoalProvider.notifier).addContribution(
                    goalId: goal.id,
                    amount: amount,
                    note: noteController.text.isNotEmpty ? noteController.text : null,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Katkı başarıyla eklendi!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'Onayla',
              style: TextStyle(
                color: title.contains('Sil') ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}