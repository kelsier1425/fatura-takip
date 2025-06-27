import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final String currency;
  final bool notificationsEnabled;
  final bool reminderNotifications;
  final int reminderDaysBefore;
  final bool darkMode;
  final String language;
  final bool hasChild;
  final bool hasPet;
  
  const UserPreferences({
    this.currency = 'TRY',
    this.notificationsEnabled = true,
    this.reminderNotifications = true,
    this.reminderDaysBefore = 3,
    this.darkMode = false,
    this.language = 'tr',
    this.hasChild = false,
    this.hasPet = false,
  });
  
  UserPreferences copyWith({
    String? currency,
    bool? notificationsEnabled,
    bool? reminderNotifications,
    int? reminderDaysBefore,
    bool? darkMode,
    String? language,
    bool? hasChild,
    bool? hasPet,
  }) {
    return UserPreferences(
      currency: currency ?? this.currency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderNotifications: reminderNotifications ?? this.reminderNotifications,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      hasChild: hasChild ?? this.hasChild,
      hasPet: hasPet ?? this.hasPet,
    );
  }
  
  @override
  List<Object?> get props => [
    currency,
    notificationsEnabled,
    reminderNotifications,
    reminderDaysBefore,
    darkMode,
    language,
    hasChild,
    hasPet,
  ];
}