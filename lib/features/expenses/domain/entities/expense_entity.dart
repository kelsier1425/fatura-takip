import 'package:equatable/equatable.dart';

enum ExpenseType {
  bill,
  subscription,
  oneTime,
  recurring,
}

enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

class ExpenseEntity extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final String? subcategoryId;
  final String title;
  final String? description;
  final double amount;
  final DateTime date;
  final ExpenseType type;
  final RecurrenceType recurrenceType;
  final int? recurrenceInterval; // e.g., every 2 months
  final DateTime? recurrenceEndDate;
  final bool isRecurring;
  final bool isPaid;
  final String? receiptUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const ExpenseEntity({
    required this.id,
    required this.userId,
    required this.categoryId,
    this.subcategoryId,
    required this.title,
    this.description,
    required this.amount,
    required this.date,
    required this.type,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceInterval,
    this.recurrenceEndDate,
    this.isRecurring = false,
    this.isPaid = false,
    this.receiptUrl,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });
  
  ExpenseEntity copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? subcategoryId,
    String? title,
    String? description,
    double? amount,
    DateTime? date,
    ExpenseType? type,
    RecurrenceType? recurrenceType,
    int? recurrenceInterval,
    DateTime? recurrenceEndDate,
    bool? isRecurring,
    bool? isPaid,
    String? receiptUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      isRecurring: isRecurring ?? this.isRecurring,
      isPaid: isPaid ?? this.isPaid,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      notes: notes ?? this.notes,
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
    title,
    description,
    amount,
    date,
    type,
    recurrenceType,
    recurrenceInterval,
    recurrenceEndDate,
    isRecurring,
    isPaid,
    receiptUrl,
    notes,
    createdAt,
    updatedAt,
  ];
}