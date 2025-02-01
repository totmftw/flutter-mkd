import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../../../core/config/supabase_config.dart';


class AuthProvider {
  // Define your AuthProvider class here

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final currentUser = SupabaseConfig.currentUser;
    if (currentUser != null) {
      try {
        final userData = await SupabaseConfig.getUserData(currentUser.id);
        state = AsyncValue.data(UserModel.fromJson(userData));
      } catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        final userData = await SupabaseConfig.getUserData(response.user!.id);
        state = AsyncValue.data(UserModel.fromJson(userData));
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      state = const AsyncValue.loading();
      final response = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      
      if (response.user != null) {
        await SupabaseConfig.client.from(SupabaseConfig.usersTable).insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'created_at': DateTime.now().toIso8601String(),
        });
        
        final userData = await SupabaseConfig.getUserData(response.user!.id);
        state = AsyncValue.data(UserModel.fromJson(userData));
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
}
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier();
});


final authProvider1 = Provider((ref) => AuthProvider());

