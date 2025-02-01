import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Singleton instance
  static final SupabaseConfig _instance = SupabaseConfig._internal();

  // Supabase client
  late SupabaseClient _client;

  // Factory constructor to return the singleton instance
  factory SupabaseConfig() {
    return _instance;
  }

  // Private constructor
  SupabaseConfig._internal();

  // Initialize Supabase with URL and Anon Key
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode, // Enable debug mode in debug builds
      );
      _client = Supabase.instance.client;
    } catch (e) {
      // Log initialization error
      debugPrint('Supabase initialization error: $e');
      rethrow;
    }
  }

  // Getter for Supabase client
  SupabaseClient get client => _client;
}
