import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../budget/domain/entities/budget_entity.dart';

enum ExpenseStatus {
  initial,
  loading,
  loaded,
  error,
}

class ExpenseState {
  final ExpenseStatus status;
  final List<ExpenseEntity> expenses;
  final String? errorMessage;
  final DateTime selectedMonth;
  final String? selectedCategoryId;
  final String? paymentStatusFilter; // 'all', 'paid', 'unpaid'

  ExpenseState({
    this.status = ExpenseStatus.initial,
    this.expenses = const [],
    this.errorMessage,
    DateTime? selectedMonth,
    this.selectedCategoryId,
    this.paymentStatusFilter = 'all',
  }) : selectedMonth = selectedMonth ?? DateTime(2024, 11);

  ExpenseState copyWith({
    ExpenseStatus? status,
    List<ExpenseEntity>? expenses,
    String? errorMessage,
    DateTime? selectedMonth,
    String? selectedCategoryId,
    String? paymentStatusFilter,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      paymentStatusFilter: paymentStatusFilter ?? this.paymentStatusFilter,
    );
  }

  List<ExpenseEntity> get filteredExpenses {
    var filtered = expenses.where((expense) {
      final expenseMonth = DateTime(expense.date.year, expense.date.month);
      final filterMonth = DateTime(selectedMonth.year, selectedMonth.month);
      
      bool monthMatch = expenseMonth == filterMonth;
      
      bool categoryMatch = selectedCategoryId == null || 
          expense.categoryId == selectedCategoryId;
      
      bool paymentMatch = paymentStatusFilter == 'all' ||
          (paymentStatusFilter == 'paid' && expense.isPaid) ||
          (paymentStatusFilter == 'unpaid' && !expense.isPaid);
      
      return monthMatch && categoryMatch && paymentMatch;
    }).toList();

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  double get totalAmount {
    return filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get paidAmount {
    return filteredExpenses
        .where((expense) => expense.isPaid)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get unpaidAmount {
    return filteredExpenses
        .where((expense) => !expense.isPaid)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final Ref _ref;
  
  ExpenseNotifier(this._ref) : super(ExpenseState()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = state.copyWith(status: ExpenseStatus.loading);

    try {
      // Mock loading delay
      await Future.delayed(const Duration(seconds: 1));

      // Generate mock expense data
      final mockExpenses = _generateMockExpenses();

      state = state.copyWith(
        status: ExpenseStatus.loaded,
        expenses: mockExpenses,
      );
    } catch (e) {
      state = state.copyWith(
        status: ExpenseStatus.error,
        errorMessage: 'Giderler yüklenirken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> addExpense(ExpenseEntity expense) async {
    try {
      // Mock API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedExpenses = [...state.expenses, expense];
      
      state = state.copyWith(
        expenses: updatedExpenses,
        status: ExpenseStatus.loaded,
      );
      
      // Bütçeyi güncelle
      await _updateBudgetForExpense(expense);
      
    } catch (e) {
      state = state.copyWith(
        status: ExpenseStatus.error,
        errorMessage: 'Gider eklenirken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> updateExpense(ExpenseEntity updatedExpense) async {
    try {
      // Mock API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedExpenses = state.expenses.map((expense) {
        return expense.id == updatedExpense.id ? updatedExpense : expense;
      }).toList();

      state = state.copyWith(
        expenses: updatedExpenses,
        status: ExpenseStatus.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        status: ExpenseStatus.error,
        errorMessage: 'Gider güncellenirken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      // Mock API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedExpenses = state.expenses
          .where((expense) => expense.id != expenseId)
          .toList();

      state = state.copyWith(
        expenses: updatedExpenses,
        status: ExpenseStatus.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        status: ExpenseStatus.error,
        errorMessage: 'Gider silinirken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> togglePaymentStatus(String expenseId) async {
    try {
      final expense = state.expenses.firstWhere((e) => e.id == expenseId);
      final updatedExpense = expense.copyWith(isPaid: !expense.isPaid);
      await updateExpense(updatedExpense);
    } catch (e) {
      state = state.copyWith(
        status: ExpenseStatus.error,
        errorMessage: 'Ödeme durumu güncellenirken bir hata oluştu',
      );
    }
  }

  void setSelectedMonth(DateTime month) {
    state = state.copyWith(selectedMonth: month);
  }

  void setCategoryFilter(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  void setPaymentStatusFilter(String filter) {
    state = state.copyWith(paymentStatusFilter: filter);
  }

  void clearFilters() {
    state = state.copyWith(
      selectedCategoryId: null,
      paymentStatusFilter: 'all',
    );
  }

  void clearError() {
    state = state.copyWith(
      status: ExpenseStatus.loaded,
      errorMessage: null,
    );
  }

  List<ExpenseEntity> _generateMockExpenses() {
    final now = DateTime.now();
    final List<ExpenseEntity> expenses = [];

    // Generate expenses for the last 3 months
    for (int monthOffset = 0; monthOffset < 3; monthOffset++) {
      final month = DateTime(now.year, now.month - monthOffset);
      
      // Generate 15-25 expenses per month
      final expenseCount = 15 + (monthOffset * 5);
      
      for (int i = 0; i < expenseCount; i++) {
        final day = (i % 28) + 1;
        final expenseDate = DateTime(month.year, month.month, day);
        
        final expenseTypes = [
          ExpenseType.bill,
          ExpenseType.subscription,
          ExpenseType.oneTime,
          ExpenseType.recurring,
        ];

        final categoryIds = [
          'home_001',
          'food_001',
          'vehicle_001',
          'health_001',
          'personal_001',
          'subscription_001',
        ];

        final descriptions = [
          'Elektrik faturası',
          'Market alışverişi',
          'Benzin',
          'Eczane',
          'Kafe',
          'Netflix',
          'Kira',
          'Telefon faturası',
          'İnternet',
          'Doktor',
          'Restoran',
          'Taksi',
        ];

        final amounts = [50, 100, 150, 200, 250, 350, 500, 750, 1000, 1500, 2500];

        expenses.add(ExpenseEntity(
          id: 'expense_${month.month}_$i',
          userId: 'user_123',
          categoryId: categoryIds[i % categoryIds.length],
          title: descriptions[i % descriptions.length],
          description: i % 5 == 0 ? 'Ek açıklama var' : null,
          amount: amounts[i % amounts.length].toDouble(),
          date: expenseDate,
          type: expenseTypes[i % expenseTypes.length],
          isPaid: (i % 3) != 0, // Most expenses are paid
          receiptUrl: null,
          notes: i % 5 == 0 ? 'Ek not var' : null,
          isRecurring: false,
          recurrenceType: RecurrenceType.none,
          createdAt: expenseDate,
          updatedAt: expenseDate,
        ));
      }
    }

    return expenses;
  }
  
  // Harcama yapıldığında ilgili bütçeyi güncelle
  Future<void> _updateBudgetForExpense(ExpenseEntity expense) async {
    try {
      // Kategori bazlı bütçe var mı kontrol et
      final budgetNotifier = _ref.read(budgetProvider.notifier);
      final budgetState = _ref.read(budgetProvider);
      
      // İlgili kategori bütçesini bul
      final categoryBudget = budgetState.budgets
          .where((budget) => 
            budget.categoryId == expense.categoryId && 
            budget.status == BudgetStatus.active &&
            expense.date.isAfter(budget.startDate) &&
            expense.date.isBefore(budget.endDate)
          )
          .firstOrNull;
      
      if (categoryBudget != null) {
        await budgetNotifier.updateBudgetSpent(categoryBudget.id, expense.amount);
      }
      
      // Genel bütçeyi de güncelle
      final generalBudget = budgetState.budgets
          .where((budget) => 
            budget.type == BudgetType.general && 
            budget.status == BudgetStatus.active &&
            expense.date.isAfter(budget.startDate) &&
            expense.date.isBefore(budget.endDate)
          )
          .firstOrNull;
      
      if (generalBudget != null) {
        await budgetNotifier.updateBudgetSpent(generalBudget.id, expense.amount);
      }
      
    } catch (e) {
      // Bütçe güncelleme hatası sessizce geçilir
      print('Budget update error: $e');
    }
  }
}

// Provider instances
final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  return ExpenseNotifier(ref);
});

// Computed providers
final filteredExpensesProvider = Provider<List<ExpenseEntity>>((ref) {
  final expenseState = ref.watch(expenseProvider);
  return expenseState.filteredExpenses;
});

final expenseSummaryProvider = Provider<Map<String, double>>((ref) {
  final expenseState = ref.watch(expenseProvider);
  return {
    'total': expenseState.totalAmount,
    'paid': expenseState.paidAmount,
    'unpaid': expenseState.unpaidAmount,
  };
});

final monthlyExpenseProvider = Provider.family<List<ExpenseEntity>, DateTime>((ref, month) {
  final expenseState = ref.watch(expenseProvider);
  return expenseState.expenses.where((expense) {
    final expenseMonth = DateTime(expense.date.year, expense.date.month);
    final filterMonth = DateTime(month.year, month.month);
    return expenseMonth == filterMonth;
  }).toList();
});