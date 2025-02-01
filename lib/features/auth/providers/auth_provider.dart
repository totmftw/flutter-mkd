import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mkd/core/config/supabase_config.dart';

final authProvider = Provider((ref) => AuthProvider());

class AuthProvider {
  // Define your AuthProvider class here
}

final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return Supabase.instance.client.auth;
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final auth = ref.watch(supabaseAuthProvider);
  return auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final auth = ref.watch(supabaseAuthProvider);
  return auth.currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});