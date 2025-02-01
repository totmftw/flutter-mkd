import 'package:supabase_flutter/supabase_flutter.dart';


class SupabaseConfig {
  static final supabase = Supabase.instance.client;
}

class SupabaseConfig {
  // Private constructor to prevent instantiation
  SupabaseConfig._();
  
  // Static constants for configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'your-supabase-url',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-supabase-anon-key',
  );

  // Initialize Supabase client
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false, // Set to true for development
    );
  }

  // Getter for Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
}
