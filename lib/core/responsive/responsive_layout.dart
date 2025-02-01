import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktop;
        } else if (constraints.maxWidth >= 650) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Gesture Handler Mixin
mixin GestureHandlerMixin {
  void handleHorizontalDragEnd(DragEndDetails details, BuildContext context, 
      {required VoidCallback onSwipeRight, required VoidCallback onSwipeLeft}) {
    if (details.primaryVelocity != null) {
      if (details.primaryVelocity! > 0) {
        // Swipe Right
        onSwipeRight();
      } else if (details.primaryVelocity! < 0) {
        // Swipe Left
        onSwipeLeft();
      }
    }
  }
}
