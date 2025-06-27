import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/repositories/savings_goal_repository.dart';
import '../../data/repositories/savings_goal_repository_impl.dart';
import '../../domain/usecases/create_savings_goal_usecase.dart';
import '../../domain/usecases/add_savings_contribution_usecase.dart';
import '../../domain/usecases/calculate_savings_analytics_usecase.dart';

// Repository provider
final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  return SavingsGoalRepositoryImpl();
});

// Use cases providers
final createSavingsGoalUseCaseProvider = Provider<CreateSavingsGoalUseCase>((ref) {
  final repository = ref.watch(savingsGoalRepositoryProvider);
  return CreateSavingsGoalUseCase(repository);
});

final addSavingsContributionUseCaseProvider = Provider<AddSavingsContributionUseCase>((ref) {
  final repository = ref.watch(savingsGoalRepositoryProvider);
  return AddSavingsContributionUseCase(repository);
});

final calculateSavingsAnalyticsUseCaseProvider = Provider<CalculateSavingsAnalyticsUseCase>((ref) {
  final repository = ref.watch(savingsGoalRepositoryProvider);
  return CalculateSavingsAnalyticsUseCase(repository);
});

// State classes
class SavingsGoalState {
  final List<SavingsGoalEntity> goals;
  final bool isLoading;
  final String? error;
  final Map<String, SavingsAnalytics> analytics;

  const SavingsGoalState({
    this.goals = const [],
    this.isLoading = false,
    this.error,
    this.analytics = const {},
  });

  SavingsGoalState copyWith({
    List<SavingsGoalEntity>? goals,
    bool? isLoading,
    String? error,
    Map<String, SavingsAnalytics>? analytics,
  }) {
    return SavingsGoalState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      analytics: analytics ?? this.analytics,
    );
  }
}

// Main savings goals provider
class SavingsGoalNotifier extends StateNotifier<SavingsGoalState> {
  final SavingsGoalRepository _repository;
  final CreateSavingsGoalUseCase _createGoalUseCase;
  final AddSavingsContributionUseCase _addContributionUseCase;
  final CalculateSavingsAnalyticsUseCase _analyticsUseCase;

  SavingsGoalNotifier({
    required SavingsGoalRepository repository,
    required CreateSavingsGoalUseCase createGoalUseCase,
    required AddSavingsContributionUseCase addContributionUseCase,
    required CalculateSavingsAnalyticsUseCase analyticsUseCase,
  })  : _repository = repository,
        _createGoalUseCase = createGoalUseCase,
        _addContributionUseCase = addContributionUseCase,
        _analyticsUseCase = analyticsUseCase,
        super(const SavingsGoalState());

  // Load all goals for a user
  Future<void> loadGoals(String userId) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final goals = await _repository.getSavingsGoalsByUserId(userId);
      state = state.copyWith(
        goals: goals,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Create a new savings goal
  Future<void> createGoal(CreateSavingsGoalParams params) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final newGoal = await _createGoalUseCase.execute(params);
      final updatedGoals = [...state.goals, newGoal];
      
      state = state.copyWith(
        goals: updatedGoals,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Add contribution to a goal
  Future<void> addContribution({
    required String goalId,
    required double amount,
    String? note,
  }) async {
    try {
      final params = AddContributionParams(
        goalId: goalId,
        amount: amount,
        note: note,
      );
      
      final updatedGoal = await _addContributionUseCase.execute(params);
      
      final updatedGoals = state.goals.map((goal) {
        return goal.id == updatedGoal.id ? updatedGoal : goal;
      }).toList();
      
      state = state.copyWith(goals: updatedGoals);
      
      // Update analytics for this goal
      await _loadGoalAnalytics(params.goalId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Update goal status
  Future<void> updateGoalStatus(String goalId, SavingsGoalStatus status) async {
    try {
      switch (status) {
        case SavingsGoalStatus.paused:
          await _repository.pauseSavingsGoal(goalId);
          break;
        case SavingsGoalStatus.active:
          await _repository.resumeSavingsGoal(goalId);
          break;
        case SavingsGoalStatus.completed:
          await _repository.completeSavingsGoal(goalId);
          break;
        case SavingsGoalStatus.cancelled:
          await _repository.cancelSavingsGoal(goalId);
          break;
        default:
          break;
      }
      
      // Reload goals to reflect changes
      final goal = state.goals.firstWhere((g) => g.id == goalId);
      await loadGoals(goal.userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    try {
      await _repository.deleteSavingsGoal(goalId);
      
      final updatedGoals = state.goals.where((goal) => goal.id != goalId).toList();
      final updatedAnalytics = Map<String, SavingsAnalytics>.from(state.analytics);
      updatedAnalytics.remove(goalId);
      
      state = state.copyWith(
        goals: updatedGoals,
        analytics: updatedAnalytics,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Load goal analytics
  Future<void> _loadGoalAnalytics(String goalId) async {
    try {
      final analytics = await _analyticsUseCase.execute(goalId);
      final updatedAnalytics = Map<String, SavingsAnalytics>.from(state.analytics);
      updatedAnalytics[goalId] = analytics;
      
      state = state.copyWith(analytics: updatedAnalytics);
    } catch (e) {
      // Analytics loading failure shouldn't break the main flow
      print('Failed to load analytics for goal $goalId: $e');
    }
  }

  // Load analytics for all goals
  Future<void> loadAllAnalytics() async {
    for (final goal in state.goals) {
      await _loadGoalAnalytics(goal.id);
    }
  }

  // Enable auto-save for a goal
  Future<void> enableAutoSave(String goalId, double amount, SavingsPlanFrequency frequency) async {
    try {
      await _repository.enableAutoSave(goalId, amount, frequency);
      
      // Update the goal in state
      final updatedGoals = state.goals.map((goal) {
        if (goal.id == goalId) {
          final updatedPlan = SavingsPlan(
            type: goal.plan.type,
            fixedAmount: amount,
            percentageAmount: goal.plan.percentageAmount,
            frequency: frequency,
            specificDays: goal.plan.specificDays,
            autoSave: true,
            linkedBudgetId: goal.plan.linkedBudgetId,
          );
          return goal.copyWith(plan: updatedPlan);
        }
        return goal;
      }).toList();
      
      state = state.copyWith(goals: updatedGoals);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Disable auto-save for a goal
  Future<void> disableAutoSave(String goalId) async {
    try {
      await _repository.disableAutoSave(goalId);
      
      // Update the goal in state
      final updatedGoals = state.goals.map((goal) {
        if (goal.id == goalId) {
          final updatedPlan = SavingsPlan(
            type: goal.plan.type,
            fixedAmount: goal.plan.fixedAmount,
            percentageAmount: goal.plan.percentageAmount,
            frequency: goal.plan.frequency,
            specificDays: goal.plan.specificDays,
            autoSave: false,
            linkedBudgetId: goal.plan.linkedBudgetId,
          );
          return goal.copyWith(plan: updatedPlan);
        }
        return goal;
      }).toList();
      
      state = state.copyWith(goals: updatedGoals);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Create goal from template
  Future<void> createGoalFromTemplate(
    String userId,
    String templateId,
    double targetAmount,
    DateTime targetDate,
  ) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final newGoal = await _repository.createGoalFromTemplate(
        userId,
        templateId,
        targetAmount,
        targetDate,
      );
      
      final updatedGoals = [...state.goals, newGoal];
      
      state = state.copyWith(
        goals: updatedGoals,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Get goals by status
  List<SavingsGoalEntity> getGoalsByStatus(SavingsGoalStatus status) {
    return state.goals.where((goal) => goal.status == status).toList();
  }

  // Get goals by category
  List<SavingsGoalEntity> getGoalsByCategory(SavingsGoalCategory category) {
    return state.goals.where((goal) => goal.category == category).toList();
  }

  // Get analytics for a specific goal
  SavingsAnalytics? getGoalAnalytics(String goalId) {
    return state.analytics[goalId];
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Pause goal
  Future<void> pauseGoal(String goalId) async {
    await updateGoalStatus(goalId, SavingsGoalStatus.paused);
  }

  // Resume goal
  Future<void> resumeGoal(String goalId) async {
    await updateGoalStatus(goalId, SavingsGoalStatus.active);
  }

  // Load goal analytics
  Future<void> loadGoalAnalytics(String goalId) async {
    await _loadGoalAnalytics(goalId);
  }
}

// Provider for SavingsGoalNotifier
final savingsGoalProvider = StateNotifierProvider<SavingsGoalNotifier, SavingsGoalState>((ref) {
  final repository = ref.watch(savingsGoalRepositoryProvider);
  final createGoalUseCase = ref.watch(createSavingsGoalUseCaseProvider);
  final addContributionUseCase = ref.watch(addSavingsContributionUseCaseProvider);
  final analyticsUseCase = ref.watch(calculateSavingsAnalyticsUseCaseProvider);
  
  return SavingsGoalNotifier(
    repository: repository,
    createGoalUseCase: createGoalUseCase,
    addContributionUseCase: addContributionUseCase,
    analyticsUseCase: analyticsUseCase,
  );
});

// Helper providers for specific data
final activeGoalsProvider = Provider<List<SavingsGoalEntity>>((ref) {
  final savingsState = ref.watch(savingsGoalProvider);
  return savingsState.goals.where((goal) => goal.status == SavingsGoalStatus.active).toList();
});

final completedGoalsProvider = Provider<List<SavingsGoalEntity>>((ref) {
  final savingsState = ref.watch(savingsGoalProvider);
  return savingsState.goals.where((goal) => goal.status == SavingsGoalStatus.completed).toList();
});

final totalSavingsAmountProvider = Provider<double>((ref) {
  final savingsState = ref.watch(savingsGoalProvider);
  return savingsState.goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
});

final savingsGoalTemplatesProvider = FutureProvider<List<SavingsGoalTemplate>>((ref) {
  final repository = ref.watch(savingsGoalRepositoryProvider);
  return repository.getGoalTemplates();
});

// Provider for user savings statistics
final userSavingsStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) {
  final repository = ref.watch(savingsGoalRepositoryProvider);
  return repository.getUserSavingsStats(userId);
});

// Provider for getting a specific goal by ID
final goalByIdProvider = Provider.family<SavingsGoalEntity?, String>((ref, goalId) {
  final savingsState = ref.watch(savingsGoalProvider);
  try {
    return savingsState.goals.firstWhere((goal) => goal.id == goalId);
  } catch (e) {
    return null;
  }
});