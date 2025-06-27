import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense_entity.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_filter_bar.dart';
import '../widgets/expense_summary_card.dart';
import '../providers/expense_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/error_widget.dart';

class ExpenseListPage extends ConsumerStatefulWidget {
  const ExpenseListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends ConsumerState<ExpenseListPage> {
  @override
  void initState() {
    super.initState();
    // Set initial month filter
    Future.microtask(() {
      ref.read(expenseProvider.notifier).setSelectedMonth(DateTime.now());
    });
  }
  
  void _changeMonth(int direction) {
    final expenseNotifier = ref.read(expenseProvider.notifier);
    final currentMonth = ref.read(expenseProvider).selectedMonth;
    final newMonth = DateTime(
      currentMonth.year,
      currentMonth.month + direction,
    );
    expenseNotifier.setSelectedMonth(newMonth);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseState = ref.watch(expenseProvider);
    final filteredExpenses = ref.watch(filteredExpensesProvider);
    final expenseSummary = ref.watch(expenseSummaryProvider);
    
    return LoadingOverlay(
      isLoading: expenseState.status == ExpenseStatus.loading,
      loadingText: 'Harcamalar yükleniyor...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Harcamalar'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: expenseState.selectedMonth,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDatePickerMode: DatePickerMode.year,
                );
                if (picked != null) {
                  ref.read(expenseProvider.notifier).setSelectedMonth(picked);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(expenseProvider.notifier).loadExpenses();
              },
            ),
          ],
        ),
        floatingActionButton: MediaQuery.of(context).size.width > 600
            ? FloatingActionButton.extended(
                onPressed: () => context.push('/expense/add'),
                icon: const Icon(Icons.add),
                label: const Text('Harcama Ekle'),
                backgroundColor: AppColors.primary,
              )
            : FloatingActionButton(
                onPressed: () => context.push('/expense/add'),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add),
              ),
        body: _buildBody(expenseState, filteredExpenses, expenseSummary, theme),
      ),
    );
  }

  Widget _buildBody(
    ExpenseState expenseState,
    List<ExpenseEntity> filteredExpenses,
    Map<String, double> expenseSummary,
    ThemeData theme,
  ) {
    if (expenseState.status == ExpenseStatus.error) {
      return AppErrorWidget(
        message: expenseState.errorMessage ?? 'Bir hata oluştu',
        onRetry: () => ref.read(expenseProvider.notifier).loadExpenses(),
      );
    }

    return Column(
      children: [
        // Month Navigation
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('MMMM yyyy', 'tr').format(expenseState.selectedMonth),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),

        // Summary Cards
        if (expenseSummary.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ExpenseSummaryCard(
              totalAmount: expenseSummary['total'] ?? 0,
              paidAmount: expenseSummary['paid'] ?? 0,
              unpaidAmount: expenseSummary['unpaid'] ?? 0,
              expenseCount: filteredExpenses.length,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Filter Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ExpenseFilterBar(
            selectedCategoryId: expenseState.selectedCategoryId,
            showOnlyUnpaid: expenseState.paymentStatusFilter == 'unpaid',
            onCategoryChanged: (categoryId) {
              ref.read(expenseProvider.notifier).setCategoryFilter(categoryId);
            },
            onUnpaidFilterChanged: (value) {
              ref.read(expenseProvider.notifier).setPaymentStatusFilter(
                value ? 'unpaid' : 'all'
              );
            },
          ),
        ),
        
        // Expense List
        Expanded(
          child: filteredExpenses.isEmpty
              ? const EmptyStateWidget(
                  title: 'Harcama Bulunamadı',
                  message: 'Bu ay için harcama bulunamadı',
                  icon: Icons.receipt_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ExpenseCard(
                        expense: expense,
                        onTap: () {
                          // TODO: Navigate to expense detail
                        },
                        onEdit: () {
                          // TODO: Navigate to edit expense
                        },
                        onDelete: () {
                          _showDeleteDialog(expense);
                        },
                        onTogglePaid: () {
                          ref.read(expenseProvider.notifier).togglePaymentStatus(expense.id);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showDeleteDialog(ExpenseEntity expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Harcamayı Sil'),
        content: Text('${expense.title} harcamasını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(expenseProvider.notifier).deleteExpense(expense.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}