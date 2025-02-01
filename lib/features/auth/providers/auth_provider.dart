import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_config/supabase_config.dart';

final supabaseAuthProvider = Provider<SupabaseConfig>((ref) {
  final supabaseUrl = 'https://your-supabase-url.supabase.co';
  final supabaseKey = 'your-supabase-anon-key';
  return SupabaseConfig(
    url: supabaseUrl,
    key: supabaseKey,
  );
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final auth = ref.watch(supabaseAuthProvider).auth;
  return auth.onAuthStateChange.map((event) {
    if (event is AuthEvent) {
      switch (event.type) {
        case 'SIGNED_IN':
          return AuthState(user: event.user);
        case 'SIGNED_OUT':
          return const AuthState(user: null);
        default:
          return const AuthState(user: null);
      }
    }
    return const AuthState(user: null);
  });
});

final currentUserProvider = Provider<User?>((ref) {
  final auth = ref.watch(supabaseAuthProvider).auth;
  return auth.currentUser;
});

class AuthState {
  final User? user;

  const AuthState({this.user});

  AuthState copyWith({User? user}) => AuthState(user: user ?? this.user);
}
