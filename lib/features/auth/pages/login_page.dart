import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../dashboard/pages/dashboard_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final Logger _logger = Logger('LoginPage');

  @override
  void initState() {
    super.initState();
    _logger.info('initState called');
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('build method called');
    return Scaffold(
      body: ResponsiveLayout(
        mobileBuilder: (context) => buildMobileLayout(context),
        tabletBuilder: (context) => buildDesktopLayout(context),
        desktopBuilder: (context) => buildDesktopLayout(context),
      ),
    );
  }

  Widget buildMobileLayout(BuildContext context) {
    _logger.info('buildMobileLayout called');
    return const Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: LoginForm(),
      ),
    );
  }

  Widget buildDesktopLayout(BuildContext context) {
    _logger.info('buildDesktopLayout called');
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const LoginForm(),
      ),
    );
  }
}

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends ConsumerState<LoginForm> {
  final Logger _logger = Logger('LoginFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _logger.info('initState called');
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    _logger.info('_loadSavedCredentials called');
    try {
      final email = await _secureStorage.read(key: 'email');
      final password = await _secureStorage.read(key: 'password');
      
      if (email != null && password != null) {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
          _rememberMe = true;
        });
      }
    } catch (e) {
      _logger.warning('Error loading saved credentials: $e');
    }
  }

  Future<void> _saveCredentials() async {
    _logger.info('_saveCredentials called');
    if (_rememberMe) {
      await _secureStorage.write(key: 'email', value: _emailController.text);
      await _secureStorage.write(key: 'password', value: _passwordController.text);
    } else {
      await _secureStorage.delete(key: 'email');
      await _secureStorage.delete(key: 'password');
    }
  }

  void _showErrorSnackBar(String message) {
    _logger.info('_showErrorSnackBar called');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _navigateToDashboard() {
    _logger.info('_navigateToDashboard called');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  Future<void> _login() async {
    _logger.info('_login called');
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final response = await authNotifier.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (response.status == AuthStatus.authenticated) {
        await _saveCredentials();
        _navigateToDashboard();
      } else {
        _showErrorSnackBar(response.errorMessage ?? 'Login failed');
      }
    } catch (e) {
      if (!mounted) return;
      _logger.severe('Login error: $e');
      _showErrorSnackBar('An unexpected error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _forgotPassword() {
    _logger.info('_forgotPassword called');
    showDialog(
      context: context,
      builder: (context) => ForgotPasswordDialog(
        emailController: _emailController,
        onPasswordResetRequested: _handlePasswordReset,
      ),
    );
  }

  Future<void> _handlePasswordReset(String email) async {
    _logger.info('_handlePasswordReset called');
    try {
      if (!_isValidEmail(email)) {
        _showErrorSnackBar('Please enter a valid email address');
        return;
      }

      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.resetPassword(email);

      if (!mounted) return;

      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent to your email'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      _logger.severe('Password reset error: $e');
      _showErrorSnackBar('Failed to send password reset link');
    }
  }

  bool _isValidEmail(String email) {
    _logger.info('_isValidEmail called');
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('build method called');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                ),
                const Text('Remember Me'),
              ],
            ),
            TextButton(
              onPressed: _forgotPassword,
              child: const Text('Forgot Password?'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
          child: _isLoading 
            ? const CircularProgressIndicator() 
            : const Text('Login'),
        ),
        const SizedBox(height: 20),
        const SocialLoginButton(),
      ],
    );
  }

  @override
  void dispose() {
    _logger.info('dispose method called');
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class ForgotPasswordDialog extends StatefulWidget {
  final TextEditingController emailController;
  final Future<void> Function(String) onPasswordResetRequested;

  const ForgotPasswordDialog({
    Key? key,
    required this.emailController,
    required this.onPasswordResetRequested,
  }) : super(key: key);

  @override
  ForgotPasswordDialogState createState() => ForgotPasswordDialogState();
}

class ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final Logger _logger = Logger('ForgotPasswordDialogState');
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    _logger.info('build method called');
    return AlertDialog(
      title: const Text('Forgot Password'),
      content: TextField(
        controller: widget.emailController,
        decoration: const InputDecoration(
          labelText: 'Email Address',
          hintText: 'Enter your email',
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading 
            ? null 
            : () async {
                setState(() => _isLoading = true);
                try {
                  await widget.onPasswordResetRequested(
                    widget.emailController.text.trim()
                  );
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
          child: _isLoading 
            ? const CircularProgressIndicator() 
            : const Text('Reset Password'),
        ),
      ],
    );
  }
}

class SocialLoginButton extends ConsumerStatefulWidget {
  const SocialLoginButton({Key? key}) : super(key: key);

  @override
  SocialLoginButtonState createState() => SocialLoginButtonState();
}

class SocialLoginButtonState extends ConsumerState<SocialLoginButton> {
  final Logger _logger = Logger('SocialLoginButtonState');
  bool _isLoading = false;

  void _showErrorSnackBar(String message) {
    _logger.info('_showErrorSnackBar called');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _navigateToDashboard() {
    _logger.info('_navigateToDashboard called');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    _logger.info('_handleGoogleSignIn called');
    if (!mounted) return;

    setState(() => _isLoading = true);
    
    try {
      final authNotifier = ref.read(authProvider.notifier);
      final response = await authNotifier.signInWithGoogle();

      if (!mounted) return;

      if (response.status == AuthStatus.authenticated) {
        _navigateToDashboard();
      } else {
        _showErrorSnackBar(response.errorMessage ?? 'Google Sign-In failed');
      }
    } catch (e) {
      _logger.severe('Google Sign-In error: $e');
      _showErrorSnackBar('An unexpected error occurred during Google Sign-In');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    _logger.info('_handleAppleSignIn called');
    if (!mounted) return;

    setState(() => _isLoading = true);
    
    try {
      final authNotifier = ref.read(authProvider.notifier);
      final response = await authNotifier.signInWithApple();

      if (!mounted) return;

      if (response.status == AuthStatus.authenticated) {
        _navigateToDashboard();
      } else {
        _showErrorSnackBar(response.errorMessage ?? 'Apple Sign-In failed');
      }
    } catch (e) {
      _logger.severe('Apple Sign-In error: $e');
      _showErrorSnackBar('An unexpected error occurred during Apple Sign-In');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('build method called');
    return Column(
      children: [
        const Text('Or continue with'),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              onPressed: _isLoading ? null : _handleGoogleSignIn,
              isLoading: _isLoading,
            ),
            const SizedBox(width: 20),
            _buildSocialButton(
              icon: Icons.apple,
              onPressed: _isLoading ? null : _handleAppleSignIn,
              isLoading: _isLoading,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon, 
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    _logger.info('_buildSocialButton called');
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.all(15),
        shape: const CircleBorder(),
        side: const BorderSide(color: Colors.grey, width: 1),
      ),
      child: isLoading 
        ? const CircularProgressIndicator()
        : Icon(icon, size: 30),
    );
  }
}
