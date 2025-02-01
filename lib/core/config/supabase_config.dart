import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseConfig {
  static final SupabaseClient client = Supabase.instance.client;
  
  // Private constructor to prevent instantiation
  const SupabaseConfig._();

  // Database table names as constants
  static const String usersTable = 'users';
  static const String postsTable = 'posts';
  static const String commentsTable = 'comments';
  static const String likesTable = 'likes';
  static const String followersTable = 'followers';

  // Initialize Supabase with environment variables
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      debug: false,
    );
  }

  // Auth helper methods
  static User? get currentUser => client.auth.currentUser;
  
  static Stream<AuthState> get authStateChanges => 
      client.auth.onAuthStateChange;

  // Database helper methods
  static Future<Map<String, dynamic>> getUserData(String userId) async {
    return await client
        .from(usersTable)
        .select()
        .eq('id', userId)
        .single();
  }
}

final authStateProvider = StreamProvider.autoDispose((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange.map((event) => event.session);
});