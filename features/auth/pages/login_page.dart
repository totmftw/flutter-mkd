// features/auth/pages/login_page.dart
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Login Page!'),
      ),
    );
  }
}
