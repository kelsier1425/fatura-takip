import 'package:equatable/equatable.dart';

enum BudgetNotificationType {
  warning,        // Uyarı eşiğine yaklaşıldı
  exceeded,       // Bütçe aşıldı
  achievement,    // Hedef tutturuldu / ödül
  reminder,       // Hatırlatma
  reset,          // Bütçe sıfırlandı
}

enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}

class BudgetNotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String budgetId;
  final BudgetNotificationType type;
  final NotificationPriority priority;
  final String title;
  final String message;
  final Map<String, dynamic>? data;  // Ek veriler
  final bool isRead;
  final bool isActionRequired;       // Kullanıcı aksiyonu gerekli mi?
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? expiresAt;
  
  const BudgetNotificationEntity({
    required this.id,
    required this.userId,
    required this.budgetId,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    this.data,
    this.isRead = false,
    this.isActionRequired = false,
    required this.createdAt,
    this.readAt,
    this.expiresAt,
  });
  
  // Bildirimin süresi dolmuş mu?
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  // Bildirim aktif mi?
  bool get isActive => !isExpired && !isRead;
  
  BudgetNotificationEntity copyWith({
    String? id,
    String? userId,
    String? budgetId,
    BudgetNotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    bool? isActionRequired,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? expiresAt,
  }) {
    return BudgetNotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      budgetId: budgetId ?? this.budgetId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      isActionRequired: isActionRequired ?? this.isActionRequired,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    userId,
    budgetId,
    type,
    priority,
    title,
    message,
    data,
    isRead,
    isActionRequired,
    createdAt,
    readAt,
    expiresAt,
  ];
}