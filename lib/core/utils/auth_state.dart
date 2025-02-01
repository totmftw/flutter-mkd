import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  bool _isAuthenticated = false;
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;

  AuthState() {
    _initialize();
  }

  void _initialize() {
    _currentUser = _supabase.auth.currentUser;
    _isAuthenticated = _currentUser != null;

    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          _currentUser = session?.user;
          _isAuthenticated = true;
          break;
        case AuthChangeEvent.signedOut:
          _currentUser = null;
          _isAuthenticated = false;
          break;
        default:
          break;
      }
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}
