import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveLayout(
        mobileBuilder: _buildMobileLayout,
        tabletBuilder: _buildDesktopLayout,
        desktopBuilder: _buildDesktopLayout,
      ),
    );
  }

  static Widget _buildMobileLayout(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: _LoginForm(),
      ),
    );
  }

  static Widget _buildDesktopLayout(BuildContext context) {
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
        child: const _LoginForm(),
      ),
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm({Key? key}) : super(key: key);

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _logger = Logger('LoginForm');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = const FlutterSecureStorage();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final email = await _secureStorage.read(key: 'user_email');
      final password = await _secureStorage.read(key: 'user_password');
      
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
    try {
      if (_rememberMe) {
        await _secureStorage.write(
          key: 'user_email', 
          value: _emailController.text.trim()
        );
        await _secureStorage.write(
          key: 'user_password', 
          value: _passwordController.text.trim()
        );
      } else {
        await _secureStorage.delete(key: 'user_email');
        await _secureStorage.delete(key: 'user_password');
      }
    } catch (e) {
      _logger.warning('Error saving credentials: $e');
    }
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Save credentials if remember me is checked
        await _saveCredentials();

        final authNotifier = ref.read(authProvider.notifier);
        await authNotifier.signIn(
          _emailController.text.trim(), 
          _passwordController.text.trim()
        );

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      } on AuthException catch (error) {
        _logger.warning('Login failed: ${error.message}');
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: AppColors.error,
          ),
        );
      } catch (error) {
        _logger.warning('Unexpected login error: $error');
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _forgotPassword() async {
    final emailText = _emailController.text.trim();
    
    if (emailText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email first'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(emailText);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      _logger.warning('Password reset error: $error');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset failed: ${error.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'MKD Invoice Manager',
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Email Input
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email, color: AppColors.primary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          // Password Input
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textLight,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Remember Me and Forgot Password
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
                    activeColor: AppColors.primary,
                  ),
                  const Text(
                    'Remember Me',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              TextButton(
                onPressed: _forgotPassword,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Login Button
          ElevatedButton(
            onPressed: _login,
            child: const Text('Login'),
          ),
          const SizedBox(height: 30),

          // Social Login Divider
          const Row(
            children: [
              Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('Or continue with'),
              ),
              Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 20),

          // Social Login Buttons
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialLoginButton(
                icon: Icons.g_mobiledata,
                color: Colors.red,
              ),
              SizedBox(width: 15),
              _SocialLoginButton(
                icon: Icons.apple,
                color: Colors.black,
              ),
              SizedBox(width: 15),
              _SocialLoginButton(
                icon: Icons.facebook,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SocialLoginButton({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 40, color: color),
      onPressed: null,
      style: IconButton.styleFrom(
        backgroundColor: color.withAlpha(50),
        shape: const CircleBorder(),
      ),
    );
  }
}
