import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../providers/savings_goal_provider.dart';
import '../widgets/contribution_bottom_sheet.dart';

// Temporary analytics class until proper implementation
class GoalAnalytics {
  final double averageContribution;
  final double highestContribution;
  final double totalContributions;
  final int contributionCount;
  final Map<String, dynamic> monthlyData;

  const GoalAnalytics({
    required this.averageContribution,
    required this.highestContribution,
    required this.totalContributions,
    required this.contributionCount,
    required this.monthlyData,
  });
}

class SavingsGoalDetailPage extends ConsumerStatefulWidget {
  final String goalId;

  const SavingsGoalDetailPage({
    Key? key,
    required this.goalId,
  }) : super(key: key);

  @override
  ConsumerState<SavingsGoalDetailPage> createState() => _SavingsGoalDetailPageState();
}

class _SavingsGoalDetailPageState extends ConsumerState<SavingsGoalDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load analytics for this goal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savingsGoalProvider.notifier).loadGoalAnalytics(widget.goalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = ref.watch(goalByIdProvider(widget.goalId));
    final analytics = _getMockAnalytics(goal);
    
    if (goal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Hedef bulunamadı')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Hero Animation
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/savings'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCategoryColor(goal.category),
                      _getCategoryColor(goal.category).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          goal.emoji ?? '🎯',
                          style: const TextStyle(fontSize: 48),
                        ).animate().scale(duration: 300.ms),
                        const SizedBox(height: 8),
                        Text(
                          goal.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (goal.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            goal.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, goal),
                itemBuilder: (context) => [
                  if (goal.status == SavingsGoalStatus.active)
                    const PopupMenuItem(value: 'pause', child: Text('Duraklat'))
                  else if (goal.status == SavingsGoalStatus.paused)
                    const PopupMenuItem(value: 'resume', child: Text('Devam Et')),
                  const PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                  const PopupMenuItem(value: 'delete', child: Text('Sil')),
                ],
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Card
                  _buildProgressCard(goal, theme),
                  const SizedBox(height: 16),
                  
                  // Quick Stats
                  _buildQuickStats(goal, analytics, theme),
                  const SizedBox(height: 24),
                  
                  // Progress Chart
                  _buildProgressChart(goal, analytics, theme),
                  const SizedBox(height: 24),
                  
                  // Milestones
                  _buildMilestones(goal, theme),
                  const SizedBox(height: 24),
                  
                  // Recent Contributions
                  _buildRecentContributions(goal, theme),
                  const SizedBox(height: 80), // FAB space
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: goal.status == SavingsGoalStatus.active
          ? FloatingActionButton.extended(
              onPressed: () => _showContributionSheet(context, goal),
              icon: const Icon(Icons.add),
              label: const Text('Katkı Ekle'),
              backgroundColor: _getCategoryColor(goal.category),
            ).animate().scale(delay: 300.ms)
          : null,
    );
  }

  Widget _buildProgressCard(SavingsGoalEntity goal, ThemeData theme) {
    final progress = goal.progressPercentage;
    final remaining = goal.targetAmount - goal.currentAmount;
    final daysLeft = goal.daysRemaining;

    return Card(
      elevation: 8,
      shadowColor: _getCategoryColor(goal.category).withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.cardColor,
              theme.cardColor.withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Amount Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mevcut',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '₺${goal.currentAmount.toStringAsFixed(0)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(goal.category),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress / 100,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          _getCategoryColor(goal.category),
                        ),
                      ),
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Hedef',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '₺${goal.targetAmount.toStringAsFixed(0)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  _getCategoryColor(goal.category),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: Icons.account_balance_wallet,
                  label: 'Kalan',
                  value: '₺${remaining.toStringAsFixed(0)}',
                  color: AppColors.warning,
                ),
                if (daysLeft != null && daysLeft > 0)
                  _buildInfoItem(
                    icon: Icons.calendar_today,
                    label: 'Gün Kaldı',
                    value: '$daysLeft',
                    color: AppColors.info,
                  ),
                if (goal.monthlyRequiredSaving != null)
                  _buildInfoItem(
                    icon: Icons.trending_up,
                    label: 'Aylık',
                    value: '₺${goal.monthlyRequiredSaving!.toStringAsFixed(0)}',
                    color: AppColors.success,
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    SavingsGoalEntity goal,
    GoalAnalytics? analytics,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Toplam Katkı',
            value: '${goal.contributions.length}',
            subtitle: 'işlem',
            icon: Icons.add_circle_outline,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Ortalama',
            value: analytics != null
                ? '₺${analytics.averageContribution.toStringAsFixed(0)}'
                : '₺0',
            subtitle: 'katkı',
            icon: Icons.analytics,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'En Yüksek',
            value: analytics != null
                ? '₺${analytics.highestContribution.toStringAsFixed(0)}'
                : '₺0',
            subtitle: 'katkı',
            icon: Icons.trending_up,
            color: AppColors.success,
          ),
        ),
      ],
    ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.1);
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(
    SavingsGoalEntity goal,
    GoalAnalytics? analytics,
    ThemeData theme,
  ) {
    if (goal.contributions.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.show_chart,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Henüz katkı eklenmemiş',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Prepare chart data
    final contributions = goal.contributions.take(30).toList().reversed.toList();
    double cumulativeAmount = 0;
    final spots = contributions.asMap().entries.map((entry) {
      cumulativeAmount += entry.value.amount;
      return FlSpot(entry.key.toDouble(), cumulativeAmount);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İlerleme Grafiği',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: goal.targetAmount / 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.getInputBorderColor(context).withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: goal.targetAmount / 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₺${(value / 1000).toStringAsFixed(0)}K',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                        reservedSize: 50,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: spots.isEmpty ? 1 : spots.last.x,
                  minY: 0,
                  maxY: goal.targetAmount * 1.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: _getCategoryColor(goal.category),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: _getCategoryColor(goal.category),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getCategoryColor(goal.category).withOpacity(0.1),
                      ),
                    ),
                    // Target line
                    LineChartBarData(
                      spots: [
                        FlSpot(0, goal.targetAmount),
                        FlSpot(spots.isEmpty ? 1 : spots.last.x, goal.targetAmount),
                      ],
                      isCurved: false,
                      color: AppColors.error.withOpacity(0.5),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dashArray: [5, 5],
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildMilestones(SavingsGoalEntity goal, ThemeData theme) {
    // Mock milestones for now
    final milestones = [
      {'percentage': 25, 'message': 'İlk çeyreği tamamladınız!'},
      {'percentage': 50, 'message': 'Yarı yoldasınız!'},
      {'percentage': 75, 'message': 'Hedefe çok yaklaştınız!'},
      {'percentage': 100, 'message': 'Hedefi başarıyla tamamladınız!'},
    ];
    if (milestones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kilometre Taşları',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...milestones.map((milestone) {
          final percentage = milestone['percentage'] as int;
          final amount = goal.targetAmount * percentage / 100;
          final isReached = goal.currentAmount >= amount;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isReached ? AppColors.success : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReached ? Icons.check : Icons.flag,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text('$percentage% - ₺${amount.toStringAsFixed(0)}'),
              subtitle: Text(
                milestone['message'] as String,
                style: AppTextStyles.bodySmall,
              ),
              trailing: isReached
                  ? Text(
                      'Tamamlandı',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
          );
        }).toList(),
      ],
    ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.1);
  }

  Widget _buildRecentContributions(SavingsGoalEntity goal, ThemeData theme) {
    if (goal.contributions.isEmpty) return const SizedBox.shrink();

    final recentContributions = goal.contributions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Katkılar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show all contributions
              },
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentContributions.map((contribution) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(goal.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  contribution.type == SavingsContributionType.automatic ? Icons.sync : Icons.add,
                  color: _getCategoryColor(goal.category),
                  size: 20,
                ),
              ),
              title: Text(
                '₺${contribution.amount.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                _formatDate(contribution.date),
                style: AppTextStyles.bodySmall,
              ),
              trailing: contribution.note != null
                  ? Icon(
                      Icons.note,
                      size: 16,
                      color: AppColors.textSecondary,
                    )
                  : null,
              onTap: contribution.note != null
                  ? () => _showNoteDialog(contribution.note!)
                  : null,
            ),
          );
        }).toList(),
      ],
    ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.1);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} hafta önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showContributionSheet(BuildContext context, SavingsGoalEntity goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContributionBottomSheet(
        goal: goal,
        onContribute: (amount, note) {
          ref.read(savingsGoalProvider.notifier).addContribution(
            goalId: goal.id,
            amount: amount,
            note: note,
          );
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('₺${amount.toStringAsFixed(0)} katkı eklendi'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showNoteDialog(String note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not'),
        content: Text(note),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, SavingsGoalEntity goal) {
    switch (action) {
      case 'pause':
        ref.read(savingsGoalProvider.notifier).pauseGoal(goal.id);
        break;
      case 'resume':
        ref.read(savingsGoalProvider.notifier).resumeGoal(goal.id);
        break;
      case 'edit':
        // TODO: Navigate to edit page
        break;
      case 'delete':
        _confirmDelete(goal);
        break;
    }
  }

  void _confirmDelete(SavingsGoalEntity goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hedefi Sil'),
        content: Text(
          '${goal.title} hedefini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(savingsGoalProvider.notifier).deleteGoal(goal.id);
              context.go('/savings');
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  GoalAnalytics? _getMockAnalytics(SavingsGoalEntity? goal) {
    if (goal == null || goal.contributions.isEmpty) return null;
    
    final contributions = goal.contributions.map((c) => c.amount).toList();
    final total = contributions.fold(0.0, (sum, amount) => sum + amount);
    final average = total / contributions.length;
    final highest = contributions.reduce((a, b) => a > b ? a : b);
    
    return GoalAnalytics(
      averageContribution: average,
      highestContribution: highest,
      totalContributions: total,
      contributionCount: contributions.length,
      monthlyData: {},
    );
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
        return AppColors.primary;
    }
  }
}