import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/supabase_config.dart';
import 'features/auth/pages/login_page.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase
  await SupabaseConfig().initialize(
    supabaseUrl: 'https://bkhfpjckozgowcfcmbji.supabase.co',
    supabaseAnonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJraGZwamNrb3pnb3djZmNtYmppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzczNjU1NDUsImV4cCI6MjA1Mjk0MTU0NX0.yNcAVIKFYNCsm-fuYEGayim8x4qQpnBnJUMIIdR_LGE',
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
      title: 'Flutter MKD',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginPage(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,  // Disable text scaling
              boldText: false,       // Prevent bold text scaling
            ),
            child: child!,
          ),
        );
      },
      // Add accessibility attributes
      localizationsDelegates: const [],
      supportedLocales: const [
        Locale('en', 'IN'),  // English (India)
      ],
    );
  }
}
