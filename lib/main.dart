import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/pages/login_page.dart';
import 'features/dashboard/pages/dashboard_page.dart';

void main() async {
  // Set up logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final logger = Logger('MainApp');

  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Supabase
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL', 
        defaultValue: 'https://bkhfpjckozgowcfcmbji.supabase.co'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', 
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJraGZwamNrb3pnb3djZmNtYmppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzczNjU1NDUsImV4cCI6MjA1Mjk0MTU0NX0.yNcAVIKFYNCsm-fuYEGayim8x4qQpnBnJUMIIdR_LGE'),
      debug: true,
    );

    // Set global error handler
    ErrorWidget.builder = (FlutterErrorDetails details) {
      logger.severe('Unhandled Flutter Error', details.exception, details.stack);
      return ErrorWidget(details.exception);
    };

    runApp(
      ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    logger.severe('Fatal error during app initialization', e, stackTrace);
    runApp(ErrorApp(error: e, stackTrace: stackTrace));
  }
}

class ErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorApp({Key? key, required this.error, this.stackTrace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'App Initialization Failed',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (stackTrace != null)
                SingleChildScrollView(
                  child: Text(
                    stackTrace.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.left,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // Define the router configuration
  late final GoRouter _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Navigation error: ${state.error}'),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Total Money Flow Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
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
