import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_mkd/core/config/supabase_config.dart';
import 'package:flutter_mkd/features/auth/pages/login_page.dart';

final supabaseAuthProvider = Provider((ref) => SupabaseConfig.client.auth);

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

final authStateProvider = StreamProvider.autoDispose((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange
      .map((event) => event.session);
});

class AuthState extends ConsumerStatefulWidget {
  final Widget child;

  const AuthState({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  AuthStateState createState() => AuthStateState();
}

class AuthStateState extends ConsumerState<AuthState> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (session) {
        if (session == null) {
          return const LoginPage();
        } else {
          return widget.child;
        }
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
