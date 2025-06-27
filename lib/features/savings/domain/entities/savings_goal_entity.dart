import 'package:equatable/equatable.dart';

class SavingsGoalEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SavingsGoalStatus status;
  final SavingsGoalCategory category;
  final String? emoji;
  final String? imageUrl;
  final SavingsPlan plan;
  final List<SavingsContribution> contributions;
  final SavingsSettings settings;

  const SavingsGoalEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.category,
    this.emoji,
    this.imageUrl,
    required this.plan,
    required this.contributions,
    required this.settings,
  });

  // Calculated properties
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final progress = (currentAmount / targetAmount) * 100;
    return progress > 100 ? 100.0 : progress;
  }

  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining > 0 ? remaining : 0.0;
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (targetDate.isBefore(now)) return 0;
    return targetDate.difference(now).inDays;
  }

  double get dailyRequiredSaving {
    if (daysRemaining <= 0) return 0.0;
    return remainingAmount / daysRemaining;
  }

  double get monthlyRequiredSaving {
    if (daysRemaining <= 0) return 0.0;
    final monthsRemaining = daysRemaining / 30.0;
    return monthsRemaining > 0 ? remainingAmount / monthsRemaining : remainingAmount;
  }

  bool get isCompleted => currentAmount >= targetAmount;

  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;

  bool get isOnTrack {
    if (isCompleted) return true;
    if (daysRemaining <= 0) return false;
    
    final expectedProgress = _calculateExpectedProgress();
    return progressPercentage >= expectedProgress - 5; // 5% tolerance
  }

  double _calculateExpectedProgress() {
    final now = DateTime.now();
    final totalDays = targetDate.difference(createdAt).inDays;
    final elapsedDays = now.difference(createdAt).inDays;
    
    if (totalDays <= 0) return 100.0;
    return (elapsedDays / totalDays) * 100;
  }

  SavingsGoalEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    SavingsGoalStatus? status,
    SavingsGoalCategory? category,
    String? emoji,
    String? imageUrl,
    SavingsPlan? plan,
    List<SavingsContribution>? contributions,
    SavingsSettings? settings,
  }) {
    return SavingsGoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl,
      plan: plan ?? this.plan,
      contributions: contributions ?? this.contributions,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        targetAmount,
        currentAmount,
        targetDate,
        createdAt,
        updatedAt,
        status,
        category,
        emoji,
        imageUrl,
        plan,
        contributions,
        settings,
      ];
}

enum SavingsGoalStatus {
  active,
  paused,
  completed,
  cancelled,
  overdue,
}

enum SavingsGoalCategory {
  emergency,      // Acil durum fonu
  vacation,       // Tatil
  house,          // Ev/Emlak
  car,            // Araba
  education,      // Eğitim
  wedding,        // Düğün
  retirement,     // Emeklilik
  health,         // Sağlık
  technology,     // Teknoloji
  gift,           // Hediye
  debt,           // Borç ödeme
  investment,     // Yatırım
  other,          // Diğer
}

class SavingsPlan extends Equatable {
  final SavingsPlanType type;
  final double? fixedAmount;        // Sabit miktar (aylık/haftalık)
  final double? percentageAmount;   // Gelirin yüzdesi
  final SavingsPlanFrequency frequency;
  final List<int>? specificDays;   // Belirli günler (haftanın günleri)
  final bool autoSave;             // Otomatik tasarruf
  final String? linkedBudgetId;    // Bağlı bütçe ID'si

  const SavingsPlan({
    required this.type,
    this.fixedAmount,
    this.percentageAmount,
    required this.frequency,
    this.specificDays,
    required this.autoSave,
    this.linkedBudgetId,
  });

  @override
  List<Object?> get props => [
        type,
        fixedAmount,
        percentageAmount,
        frequency,
        specificDays,
        autoSave,
        linkedBudgetId,
      ];
}

enum SavingsPlanType {
  fixed,          // Sabit miktar
  percentage,     // Gelir yüzdesi
  flexible,       // Esnek (manuel)
  automatic,      // Otomatik (AI önerisi)
}

enum SavingsPlanFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
}

class SavingsContribution extends Equatable {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final SavingsContributionType type;
  final String? note;
  final String? sourceId; // Hangi hesaptan/bütçeden

  const SavingsContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    required this.type,
    this.note,
    this.sourceId,
  });

  @override
  List<Object?> get props => [
        id,
        goalId,
        amount,
        date,
        type,
        note,
        sourceId,
      ];
}

enum SavingsContributionType {
  manual,         // Manuel ekleme
  automatic,      // Otomatik tasarruf
  bonus,          // İkramiye/bonus
  refund,         // İade
  interest,       // Faiz
  transfer,       // Transfer
}

class SavingsSettings extends Equatable {
  final bool enableNotifications;
  final bool enableMilestoneAlerts;
  final bool enableProgressSharing;
  final int reminderFrequency; // Gün cinsinden
  final double milestonePercentage; // Her % kaçta milestone alert
  final SavingsPrivacyLevel privacyLevel;

  const SavingsSettings({
    required this.enableNotifications,
    required this.enableMilestoneAlerts,
    required this.enableProgressSharing,
    required this.reminderFrequency,
    required this.milestonePercentage,
    required this.privacyLevel,
  });

  @override
  List<Object?> get props => [
        enableNotifications,
        enableMilestoneAlerts,
        enableProgressSharing,
        reminderFrequency,
        milestonePercentage,
        privacyLevel,
      ];
}

enum SavingsPrivacyLevel {
  private,        // Sadece ben görebilirim
  family,         // Aile üyeleri görebilir
  public,         // Herkes görebilir
}

class SavingsGoalTemplate extends Equatable {
  final String id;
  final String title;
  final String description;
  final SavingsGoalCategory category;
  final String emoji;
  final double? suggestedAmount;
  final int? suggestedDuration; // Ay cinsinden
  final SavingsPlan suggestedPlan;
  final List<String> tips;
  final bool isPremium;

  const SavingsGoalTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.emoji,
    this.suggestedAmount,
    this.suggestedDuration,
    required this.suggestedPlan,
    required this.tips,
    required this.isPremium,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        emoji,
        suggestedAmount,
        suggestedDuration,
        suggestedPlan,
        tips,
        isPremium,
      ];
}

class SavingsAnalytics extends Equatable {
  final String goalId;
  final double totalSaved;
  final double averageMonthlyContribution;
  final int totalContributions;
  final DateTime? estimatedCompletionDate;
  final double currentSavingRate; // Aylık
  final List<SavingsMilestone> milestones;
  final SavingsPerformance performance;

  const SavingsAnalytics({
    required this.goalId,
    required this.totalSaved,
    required this.averageMonthlyContribution,
    required this.totalContributions,
    this.estimatedCompletionDate,
    required this.currentSavingRate,
    required this.milestones,
    required this.performance,
  });

  @override
  List<Object?> get props => [
        goalId,
        totalSaved,
        averageMonthlyContribution,
        totalContributions,
        estimatedCompletionDate,
        currentSavingRate,
        milestones,
        performance,
      ];
}

class SavingsMilestone extends Equatable {
  final double percentage;
  final DateTime? achievedDate;
  final double amount;
  final bool isAchieved;
  final String? celebrationMessage;

  const SavingsMilestone({
    required this.percentage,
    this.achievedDate,
    required this.amount,
    required this.isAchieved,
    this.celebrationMessage,
  });

  @override
  List<Object?> get props => [
        percentage,
        achievedDate,
        amount,
        isAchieved,
        celebrationMessage,
      ];
}

enum SavingsPerformance {
  excellent,      // Hedefin önünde
  good,          // Hedefte
  fair,          // Biraz geride
  poor,          // Çok geride
  critical,      // Kritik durum
}