import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';
import '../../features/auth/models/user_model.dart';

class AuthState extends StateNotifier<AsyncValue<UserModel?>> {
  AuthState() : super(const AsyncValue.loading()) {
    _initialize();
  }

  final _supabase = SupabaseConfig.supabase;

  Future<void> _initialize() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final userData = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .single();
        state = AsyncValue.data(UserModel.fromJson(userData));
      } catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        final userData = await _supabase
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();
        state = AsyncValue.data(UserModel.fromJson(userData));
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
