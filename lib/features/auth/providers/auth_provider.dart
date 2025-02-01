import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'package:gotrue/gotrue.dart' as gotrue;

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

  Future<AuthState> signInWithEmail({
    required String email, 
    required String password,
  }) async {
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
        return state;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Authentication failed',
        );
        return state;
      }
    } on AuthException catch (e) {
      _logger.severe('Authentication error: ${e.message}');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return state;
    } catch (e) {
      _logger.severe('Unexpected authentication error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return state;
    }
  }

  Future<AuthState> signInWithGoogle() async {
    try {
      state = state.copyWith(status: AuthStatus.authenticating);

      // Initiate OAuth sign-in
      await _client.auth.signInWithOAuth(
        gotrue.Provider.google,
        redirectTo: 'com.example.app://login-callback', // Replace with your app's URL scheme
      );

      // Retrieve the current session
      final session = await _client.auth.refreshSession();
      
      if (session.session != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: session.session?.user,
        );
        return state;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Google Sign-In failed',
        );
        return state;
      }
    } on AuthException catch (e) {
      _logger.severe('Google Sign-In error: ${e.message}');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return state;
    } catch (e) {
      _logger.severe('Unexpected Google Sign-In error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred during Google Sign-In',
      );
      return state;
    }
  }

  Future<AuthState> signInWithApple() async {
    try {
      state = state.copyWith(status: AuthStatus.authenticating);

      // Initiate OAuth sign-in
      await _client.auth.signInWithOAuth(
        gotrue.Provider.apple,
        redirectTo: 'com.example.app://login-callback', // Replace with your app's URL scheme
      );

      // Retrieve the current session
      final session = await _client.auth.refreshSession();
      
      if (session.session != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: session.session?.user,
        );
        return state;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Apple Sign-In failed',
        );
        return state;
      }
    } on AuthException catch (e) {
      _logger.severe('Apple Sign-In error: ${e.message}');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return state;
    } catch (e) {
      _logger.severe('Unexpected Apple Sign-In error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred during Apple Sign-In',
      );
      return state;
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
      _logger.severe('Sign out error: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      _logger.info('Password reset email sent');
    } catch (e) {
      _logger.severe('Password reset error: $e');
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabaseClient = SupabaseConfig().client;
  return AuthNotifier(supabaseClient);
});