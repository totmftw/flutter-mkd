import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

import '../../../core/config/supabase_config.dart';

enum AuthStatus { 
  initial, 
  authenticating, 
  authenticated, 
  unauthenticated, 
  error 
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Logger _logger = Logger('AuthNotifier');
  final SupabaseClient _client;

  AuthNotifier(this._client) : super(AuthState()) {
    // Listen to auth state changes
    _client.auth.onAuthStateChange.listen((event) {
      switch (event.event) {
        case AuthChangeEvent.signedIn:
          _logger.info('User signed in: ${event.session?.user.email}');
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: event.session?.user,
          );
          break;
        case AuthChangeEvent.signedOut:
          _logger.info('User signed out');
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
          );
          break;
        default:
          break;
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.authenticating);
      
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        );
      } else {
        throw Exception('Authentication failed');
      }
    } on AuthException catch (e) {
      _logger.warning('Sign-in error: ${e.message}');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      _logger.warning('Unexpected sign-in error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      );
    } catch (e) {
      _logger.warning('Sign-out error: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      _logger.info('Password reset email sent');
    } catch (e) {
      _logger.warning('Password reset error: $e');
      rethrow;
    }
  }

  bool get isAuthenticated => state.status == AuthStatus.authenticated;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabaseClient = SupabaseConfig().client;
  return AuthNotifier(supabaseClient);
});