import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class CreateBudgetUseCase {
  final BudgetRepository repository;
  
  CreateBudgetUseCase(this.repository);
  
  Future<BudgetEntity> call(CreateBudgetParams params) async {
    // Validations
    if (params.amount <= 0) {
      throw Exception('Bütçe miktarı 0\'dan büyük olmalıdır');
    }
    
    if (params.startDate.isAfter(params.endDate)) {
      throw Exception('Başlangıç tarihi bitiş tarihinden önce olmalıdır');
    }
    
    // Aynı kategori için aktif bütçe var mı kontrol et
    if (params.categoryId != null) {
      final existingBudgets = await repository.getBudgetsByCategory(params.categoryId!);
      final activeBudgets = existingBudgets.where((budget) => 
        budget.status == BudgetStatus.active &&
        budget.endDate.isAfter(DateTime.now())
      ).toList();
      
      if (activeBudgets.isNotEmpty) {
        throw Exception('Bu kategori için zaten aktif bir bütçe bulunmaktadır');
      }
    }
    
    final budget = BudgetEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: params.userId,
      categoryId: params.categoryId,
      subcategoryId: params.subcategoryId,
      name: params.name,
      description: params.description,
      amount: params.amount,
      type: params.type,
      period: params.period,
      status: BudgetStatus.active,
      startDate: params.startDate,
      endDate: params.endDate,
      enableNotifications: params.enableNotifications,
      warningThreshold: params.warningThreshold,
      autoReset: params.autoReset,
      createdAt: DateTime.now(),
    );
    
    return await repository.createBudget(budget);
  }
}

class CreateBudgetParams {
  final String userId;
  final String? categoryId;
  final String? subcategoryId;
  final String name;
  final String? description;
  final double amount;
  final BudgetType type;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final bool enableNotifications;
  final double? warningThreshold;
  final bool autoReset;
  
  CreateBudgetParams({
    required this.userId,
    this.categoryId,
    this.subcategoryId,
    required this.name,
    this.description,
    required this.amount,
    required this.type,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.enableNotifications = true,
    this.warningThreshold = 0.8,
    this.autoReset = true,
  });
}