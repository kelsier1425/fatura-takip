import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeState {
  final AppThemeMode themeMode;
  final bool isSystemDark;
  
  const ThemeState({
    required this.themeMode,
    required this.isSystemDark,
  });
  
  ThemeMode get materialThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
  
  bool get isDarkMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return isSystemDark;
    }
  }
  
  String get themeDisplayName {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'Açık Tema';
      case AppThemeMode.dark:
        return 'Koyu Tema';
      case AppThemeMode.system:
        return 'Sistem Ayarı';
    }
  }
  
  IconData get themeIcon {
    switch (themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }
  
  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isSystemDark,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isSystemDark: isSystemDark ?? this.isSystemDark,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.themeMode == themeMode &&
        other.isSystemDark == isSystemDark;
  }
  
  @override
  int get hashCode => themeMode.hashCode ^ isSystemDark.hashCode;
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'app_theme_mode';
  
  ThemeNotifier() : super(const ThemeState(
    themeMode: AppThemeMode.system,
    isSystemDark: false,
  )) {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey);
      
      AppThemeMode themeMode = AppThemeMode.system;
      if (themeModeString != null) {
        themeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => AppThemeMode.system,
        );
      }
      
      // Sistem temasını kontrol et
      final context = WidgetsBinding.instance.platformDispatcher;
      final isSystemDark = context.platformBrightness == Brightness.dark;
      
      state = ThemeState(
        themeMode: themeMode,
        isSystemDark: isSystemDark,
      );
    } catch (e) {
      // Hata durumunda varsayılan tema
      state = const ThemeState(
        themeMode: AppThemeMode.system,
        isSystemDark: false,
      );
    }
  }
  
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeMode.toString());
      
      state = state.copyWith(themeMode: themeMode);
    } catch (e) {
      // Hata durumunda hiçbir şey yapma
      debugPrint('Theme kaydetme hatası: $e');
    }
  }
  
  void updateSystemBrightness(bool isSystemDark) {
    state = state.copyWith(isSystemDark: isSystemDark);
  }
}

// Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});