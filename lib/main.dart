import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/pages/login_page.dart';
import 'features/dashboard/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', 
      defaultValue: 'https://bkhfpjckozgowcfcmbji.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', 
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJraGZwamNrb3pnb3djZmNtYmppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzczNjU1NDUsImV4cCI6MjA1Mjk0MTU0NX0.yNcAVIKFYNCsm-fuYEGayim8x4qQpnBnJUMIIdR_LGE'),
    debug: true,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Total Money Flow Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaleFactor: 1.0,
          boldText: false,
        ),
        child: child!,
      ),
    );
  }
}
