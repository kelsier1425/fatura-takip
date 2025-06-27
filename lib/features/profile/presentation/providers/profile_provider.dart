import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/user_preferences.dart';

// User Provider
final currentUserProvider = StateNotifierProvider<UserNotifier, UserEntity?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserEntity?> {
  UserNotifier() : super(null);
  
  void setUser(UserEntity user) {
    state = user;
  }
  
  void updateUser(UserEntity user) {
    state = user;
  }
  
  void clearUser() {
    state = null;
  }
}

// User Preferences Provider
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
});

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier() : super(const UserPreferences());
  
  void updateCurrency(String currency) {
    state = state.copyWith(currency: currency);
    _savePreferences();
  }
  
  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    _savePreferences();
  }
  
  void toggleReminderNotifications(bool enabled) {
    state = state.copyWith(reminderNotifications: enabled);
    _savePreferences();
  }
  
  void updateReminderDays(int days) {
    state = state.copyWith(reminderDaysBefore: days);
    _savePreferences();
  }
  
  void toggleDarkMode(bool enabled) {
    state = state.copyWith(darkMode: enabled);
    _savePreferences();
  }
  
  void updateLanguage(String language) {
    state = state.copyWith(language: language);
    _savePreferences();
  }
  
  void toggleHasChild(bool hasChild) {
    state = state.copyWith(hasChild: hasChild);
    _savePreferences();
  }
  
  void toggleHasPet(bool hasPet) {
    state = state.copyWith(hasPet: hasPet);
    _savePreferences();
  }
  
  void loadPreferences() {
    // TODO: Load from local storage
  }
  
  void _savePreferences() {
    // TODO: Save to local storage
  }
}

// Theme Mode Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final preferences = ref.watch(userPreferencesProvider);
  return preferences.darkMode ? ThemeMode.dark : ThemeMode.light;
});

enum ThemeMode {
  light,
  dark,
  system,
}