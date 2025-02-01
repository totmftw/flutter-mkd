import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthNotifier extends StateNotifier<AuthStatus> {
  final SupabaseClient _client;

  AuthNotifier(this._client) : super(AuthStatus.initial) {
    _client.auth.onAuthStateChange.listen((event) {
      switch (event.event) {
        case AuthChangeEvent.signedIn:
          state = AuthStatus.authenticated;
          break;
        case AuthChangeEvent.signedOut:
          state = AuthStatus.unauthenticated;
          break;
        default:
          break;
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = AuthStatus.authenticated;
    } catch (e) {
      state = AuthStatus.unauthenticated;
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    state = AuthStatus.unauthenticated;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((ref) {
  final supabaseClient = SupabaseConfig().client;
  return AuthNotifier(supabaseClient);
});