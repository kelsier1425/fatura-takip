import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://lrcpdvdljrowrmqjcvds.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxyY3BkdmRsanJvd3JtcWpjdmRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4NzU0NzYsImV4cCI6MjA2NjQ1MTQ3Nn0.dzQsc68tuT8IvgFoQ9T9a5kpbefYEAvgqwvkvFyP3Qk';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static GoTrueClient get auth => client.auth;
}