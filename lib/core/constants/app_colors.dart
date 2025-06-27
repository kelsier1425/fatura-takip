import 'package:flutter/material.dart';

class AppColors {
  // Context-aware colors that adapt to theme
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? backgroundDark 
        : background;
  }
  
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? surfaceDark 
        : surface;
  }
  
  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? textPrimaryDark 
        : textPrimary;
  }
  
  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? textSecondaryDark 
        : textSecondary;
  }
  
  static Color getCardBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey.shade800 
        : Colors.grey.shade200;
  }
  
  static Color getInputBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey.shade700 
        : Colors.grey.shade300;
  }
  // Primary Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);
  
  // Accent Colors
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);
  
  // Neutral Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color backgroundDark = Color(0xFF111827);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Category Colors
  static const Color categoryPersonal = Color(0xFF8B5CF6);
  static const Color categoryChild = Color(0xFFEC4899);
  static const Color categoryPet = Color(0xFF84CC16);
  static const Color categorySubscription = Color(0xFF06B6D4);
  static const Color categoryHome = Color(0xFFF97316);
  static const Color categoryFood = Color(0xFFEAB308);
  static const Color categoryProfessional = Color(0xFF059669);
  static const Color categoryHealth = Color(0xFFDC2626);
  static const Color categoryTechnology = Color(0xFF7C3AED);
  static const Color categoryDigital = Color(0xFFEA580C);
  static const Color categoryGaming = Color(0xFF7C2D12);
  static const Color categoryVehicle = Color(0xFF0D47A1);
  
  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dark mode aware gradients
  static LinearGradient getPrimaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const LinearGradient(
            colors: [primary, primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : primaryGradient;
  }
  
  static LinearGradient getSuccessGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const LinearGradient(
            colors: [secondary, secondaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : successGradient;
  }
}