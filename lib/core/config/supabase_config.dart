import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

class SupabaseConfig {
  // Singleton instance
  static final SupabaseConfig _instance = SupabaseConfig._internal();
  final Logger _logger = Logger('SupabaseConfig');

  // Supabase client
  late SupabaseClient _client;
  bool _isInitialized = false;

  // Factory constructor to return the singleton instance
  factory SupabaseConfig() {
    return _instance;
  }

  // Private constructor
  SupabaseConfig._internal();

  bool get isInitialized => _isInitialized;

  // Initialize Supabase with URL and Anon Key
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    if (_isInitialized) {
      _logger.info('Supabase already initialized');
      return;
    }

    try {
      _logger.info('Initializing Supabase...');
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );
      
      _client = Supabase.instance.client;
      _isInitialized = true;
      
      _logger.info('Supabase initialized successfully');

      // Test the connection
      final connectionResult = await _testConnection();
      if (!connectionResult) {
        throw StateError('Database connection test failed');
      }
    } catch (e, stackTrace) {
      _logger.severe('Failed to initialize Supabase', e, stackTrace);
      _isInitialized = false;
      rethrow;
    }
  }

  Future<bool> _testConnection() async {
    try {
      // Simple query to test the connection
      final result = await _client.from('users').select().limit(1);
      _logger.info('Database connection test successful: $result');
      return true;
    } catch (e) {
      _logger.warning('Database connection test failed: $e');
      return false;
    }
  }

  // Getter for Supabase client
  SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError('Supabase not initialized. Call initialize() first.');
    }
    return _client;
  }

  // Cleanup method
  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        await Supabase.instance.client.dispose();
        _isInitialized = false;
        _logger.info('Supabase disposed successfully');
      } catch (e) {
        _logger.warning('Error disposing Supabase: $e');
      }
    }
  }
}
