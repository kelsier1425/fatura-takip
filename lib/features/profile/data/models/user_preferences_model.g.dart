// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferencesModel _$UserPreferencesModelFromJson(
        Map<String, dynamic> json) =>
    UserPreferencesModel(
      currency: json['currency'] as String? ?? 'TRY',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      reminderNotifications: json['reminderNotifications'] as bool? ?? true,
      reminderDaysBefore: (json['reminderDaysBefore'] as num?)?.toInt() ?? 3,
      darkMode: json['darkMode'] as bool? ?? false,
      language: json['language'] as String? ?? 'tr',
      hasChild: json['hasChild'] as bool? ?? false,
      hasPet: json['hasPet'] as bool? ?? false,
    );

Map<String, dynamic> _$UserPreferencesModelToJson(
        UserPreferencesModel instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'notificationsEnabled': instance.notificationsEnabled,
      'reminderNotifications': instance.reminderNotifications,
      'reminderDaysBefore': instance.reminderDaysBefore,
      'darkMode': instance.darkMode,
      'language': instance.language,
      'hasChild': instance.hasChild,
      'hasPet': instance.hasPet,
    };
