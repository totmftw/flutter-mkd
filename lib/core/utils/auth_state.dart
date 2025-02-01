import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  late final Stream<AuthState> _authStateChanges;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _authStateChanges = Supabase.instance.client.auth.onAuthStateChange;
    _initialize();
  }

  Future<void> _initialize() async {
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return StreamBuilder<AuthState>(
      stream: _authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('An error occurred'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return widget.child;
      },
    );
  }
}
