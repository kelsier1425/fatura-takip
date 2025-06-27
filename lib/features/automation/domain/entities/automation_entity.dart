import 'package:equatable/equatable.dart';

enum AutomationType {
  recurring,
  reminder,
  smartSuggestion,
}

enum NotificationTiming {
  sameDay,
  oneDayBefore,
  threeDaysBefore,
  oneWeekBefore,
}

class AutomationEntity extends Equatable {
  final String id;
  final String userId;
  final String expenseId;
  final AutomationType type;
  final bool isActive;
  final NotificationTiming notificationTiming;
  final DateTime? nextExecutionDate;
  final DateTime? lastExecutionDate;
  final int executionCount;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const AutomationEntity({
    required this.id,
    required this.userId,
    required this.expenseId,
    required this.type,
    this.isActive = true,
    this.notificationTiming = NotificationTiming.threeDaysBefore,
    this.nextExecutionDate,
    this.lastExecutionDate,
    this.executionCount = 0,
    this.settings,
    required this.createdAt,
    this.updatedAt,
  });
  
  AutomationEntity copyWith({
    String? id,
    String? userId,
    String? expenseId,
    AutomationType? type,
    bool? isActive,
    NotificationTiming? notificationTiming,
    DateTime? nextExecutionDate,
    DateTime? lastExecutionDate,
    int? executionCount,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AutomationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      expenseId: expenseId ?? this.expenseId,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      notificationTiming: notificationTiming ?? this.notificationTiming,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
      lastExecutionDate: lastExecutionDate ?? this.lastExecutionDate,
      executionCount: executionCount ?? this.executionCount,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    userId,
    expenseId,
    type,
    isActive,
    notificationTiming,
    nextExecutionDate,
    lastExecutionDate,
    executionCount,
    settings,
    createdAt,
    updatedAt,
  ];
}