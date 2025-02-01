import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mkd/features/auth/pages/login_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: LoginPage, initial: true),
    // Add more routes as needed
  ],
)
class $AppRouter {}

class AppRouter {
  static final _appRouter = $AppRouter();

  static AutoRouter get router => _appRouter;
}
