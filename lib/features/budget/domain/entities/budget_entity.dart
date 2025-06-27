import 'package:equatable/equatable.dart';

enum BudgetType {
  general,      // Genel bütçe
  category,     // Kategori bazlı bütçe
  subcategory,  // Alt kategori bazlı bütçe
}

enum BudgetPeriod {
  weekly,
  monthly,
  quarterly,
  yearly,
}

enum BudgetStatus {
  active,
  inactive,
  exceeded,
  warning,
}

class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final String? categoryId;      // null ise genel bütçe
  final String? subcategoryId;   // alt kategori bütçesi için
  final String name;
  final String? description;
  final double amount;
  final double spent;
  final BudgetType type;
  final BudgetPeriod period;
  final BudgetStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final bool enableNotifications;
  final double? warningThreshold;  // Uyarı eşiği (örn: 0.8 = %80)
  final bool autoReset;            // Dönem sonunda otomatik sıfırlansın mı
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const BudgetEntity({
    required this.id,
    required this.userId,
    this.categoryId,
    this.subcategoryId,
    required this.name,
    this.description,
    required this.amount,
    this.spent = 0.0,
    required this.type,
    required this.period,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.enableNotifications = true,
    this.warningThreshold = 0.8,
    this.autoReset = true,
    required this.createdAt,
    this.updatedAt,
  });
  
  // Bütçe kullanım yüzdesi
  double get usagePercentage => amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;
  
  // Kalan miktar
  double get remaining => (amount - spent).clamp(0.0, double.infinity);
  
  // Bütçe aşılmış mı?
  bool get isExceeded => spent > amount;
  
  // Uyarı eşiğine ulaşılmış mı?
  bool get isWarningReached => warningThreshold != null && 
      usagePercentage >= warningThreshold!;
  
  // Kalan gün sayısı
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
  
  // Günlük harcama ortalaması
  double get dailyAverageSpent {
    final now = DateTime.now();
    final daysPassed = now.difference(startDate).inDays + 1;
    return daysPassed > 0 ? spent / daysPassed : 0.0;
  }
  
  // Tahmini bitiş tarihi (güncel harcama hızına göre)
  DateTime? get estimatedEndDate {
    if (dailyAverageSpent <= 0) return null;
    final remainingDays = remaining / dailyAverageSpent;
    return DateTime.now().add(Duration(days: remainingDays.ceil()));
  }
  
  BudgetEntity copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? subcategoryId,
    String? name,
    String? description,
    double? amount,
    double? spent,
    BudgetType? type,
    BudgetPeriod? period,
    BudgetStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    bool? enableNotifications,
    double? warningThreshold,
    bool? autoReset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      type: type ?? this.type,
      period: period ?? this.period,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      warningThreshold: warningThreshold ?? this.warningThreshold,
      autoReset: autoReset ?? this.autoReset,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    userId,
    categoryId,
    subcategoryId,
    name,
    description,
    amount,
    spent,
    type,
    period,
    status,
    startDate,
    endDate,
    enableNotifications,
    warningThreshold,
    autoReset,
    createdAt,
    updatedAt,
  ];
}