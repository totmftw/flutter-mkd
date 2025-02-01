import 'package:auto_route/auto_route.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    // Define your routes here
    AutoRoute(page: LoginPage, initial: true),
    // Add more routes as needed
  ],
)
class $AppRouter {}
