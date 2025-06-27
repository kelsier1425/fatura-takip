import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/savings_goal_provider.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../widgets/goal_card_widget.dart';
import '../widgets/savings_overview_widget.dart';
import '../widgets/create_goal_bottom_sheet.dart';

class SavingsGoalsPage extends ConsumerStatefulWidget {
  const SavingsGoalsPage({super.key});

  @override
  ConsumerState<SavingsGoalsPage> createState() => _SavingsGoalsPageState();
}

class _SavingsGoalsPageState extends ConsumerState<SavingsGoalsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load goals on page init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savingsGoalProvider.notifier).loadGoals('user_1');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savingsState = ref.watch(savingsGoalProvider);
    final activeGoals = ref.watch(activeGoalsProvider);
    final completedGoals = ref.watch(completedGoalsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasarruf Hedefleri'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Tüm Hedefler'),
              ),
              const PopupMenuItem(
                value: 'active',
                child: Text('Aktif Hedefler'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Tamamlanan'),
              ),
              const PopupMenuItem(
                value: 'paused',
                child: Text('Duraklatılan'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Özet'),
            Tab(text: 'Aktif'),
            Tab(text: 'Tamamlanan'),
            Tab(text: 'Tümü'),
          ],
        ),
      ),
      body: savingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : savingsState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Hata: ${savingsState.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(savingsGoalProvider.notifier)
                            .loadGoals('user_1'),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(context, savingsState),
                    _buildGoalsTab(context, activeGoals, 'Aktif hedef yok'),
                    _buildGoalsTab(context, completedGoals, 'Tamamlanan hedef yok'),
                    _buildGoalsTab(context, _getFilteredGoals(savingsState.goals), 'Hiç hedef yok'),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGoalSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Hedef'),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, SavingsGoalState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview stats
          const SavingsOverviewWidget(),
          const SizedBox(height: 24),
          
          // Recent goals
          _buildSectionHeader(context, 'Son Hedefler', () {
            _tabController.animateTo(3);
          }),
          const SizedBox(height: 12),
          
          if (state.goals.isEmpty)
            _buildEmptyState(context, 'İlk tasarruf hedefini oluştur')
          else
            Column(
              children: state.goals
                  .take(3)
                  .map((goal) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GoalCardWidget(
                          goal: goal,
                          analytics: state.analytics[goal.id],
                        ),
                      ))
                  .toList()
                  .animate(interval: 100.ms)
                  .slideX(begin: 1, duration: 300.ms)
                  .fadeIn(),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab(BuildContext context, List<SavingsGoalEntity> goals, String emptyMessage) {
    if (goals.isEmpty) {
      return _buildEmptyState(context, emptyMessage);
    }
    
    final savingsState = ref.watch(savingsGoalProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GoalCardWidget(
            goal: goal,
            analytics: savingsState.analytics[goal.id],
          ),
        ).animate(delay: Duration(milliseconds: index * 50))
         .slideX(begin: 1, duration: 300.ms)
         .fadeIn();
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback? onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Tümünü Gör'),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateGoalSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Hedef Oluştur'),
          ),
        ],
      ),
    );
  }

  List<SavingsGoalEntity> _getFilteredGoals(List<SavingsGoalEntity> goals) {
    if (_selectedFilter.startsWith('search:')) {
      final searchTerm = _selectedFilter.substring(7).toLowerCase();
      return goals.where((goal) => 
        goal.title.toLowerCase().contains(searchTerm) ||
        (goal.description?.toLowerCase().contains(searchTerm) ?? false)
      ).toList();
    }
    
    switch (_selectedFilter) {
      case 'active':
        return goals.where((goal) => goal.status == SavingsGoalStatus.active).toList();
      case 'completed':
        return goals.where((goal) => goal.status == SavingsGoalStatus.completed).toList();
      case 'paused':
        return goals.where((goal) => goal.status == SavingsGoalStatus.paused).toList();
      default:
        return goals;
    }
  }

  void _showCreateGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateGoalBottomSheet(),
    );
  }

  void _showSearchDialog(BuildContext context) {
    String searchTerm = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hedef Ara'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Hedef adı girin...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            searchTerm = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (searchTerm.isNotEmpty) {
                // Filter goals and update state
                setState(() {
                  _selectedFilter = 'search:$searchTerm';
                });
              }
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }
}