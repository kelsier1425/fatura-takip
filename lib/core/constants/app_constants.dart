class AppConstants {
  static const String appName = 'Fatura Takip';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'https://api.faturatakip.com';
  static const String authEndpoint = '/auth';
  static const String userEndpoint = '/user';
  static const String expenseEndpoint = '/expense';
  static const String categoryEndpoint = '/category';
  static const String subscriptionEndpoint = '/subscription';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_preference';
  static const String currencyKey = 'currency_preference';
  static const String notificationKey = 'notification_settings';
  
  // Animation Durations - Optimized for performance
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 250);
  static const Duration longAnimation = Duration(milliseconds: 400);
  
  // Revenue Cat
  static const String revenueCatApiKey = 'your_revenue_cat_key';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String monthYearFormat = 'MMMM yyyy';
  static const String timeFormat = 'HH:mm';
}