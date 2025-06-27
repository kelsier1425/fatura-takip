import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_preferences.dart';

part 'user_preferences_model.g.dart';

@JsonSerializable()
class UserPreferencesModel extends UserPreferences {
  const UserPreferencesModel({
    String currency = 'TRY',
    bool notificationsEnabled = true,
    bool reminderNotifications = true,
    int reminderDaysBefore = 3,
    bool darkMode = false,
    String language = 'tr',
    bool hasChild = false,
    bool hasPet = false,
  }) : super(
    currency: currency,
    notificationsEnabled: notificationsEnabled,
    reminderNotifications: reminderNotifications,
    reminderDaysBefore: reminderDaysBefore,
    darkMode: darkMode,
    language: language,
    hasChild: hasChild,
    hasPet: hasPet,
  );
  
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserPreferencesModelToJson(this);
  
  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    return UserPreferencesModel(
      currency: entity.currency,
      notificationsEnabled: entity.notificationsEnabled,
      reminderNotifications: entity.reminderNotifications,
      reminderDaysBefore: entity.reminderDaysBefore,
      darkMode: entity.darkMode,
      language: entity.language,
      hasChild: entity.hasChild,
      hasPet: entity.hasPet,
    );
  }
}