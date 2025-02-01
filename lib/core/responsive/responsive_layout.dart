import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext)? mobileBuilder;
  final Widget Function(BuildContext)? tabletBuilder;
  final Widget Function(BuildContext)? desktopBuilder;

  const ResponsiveLayout({
    Key? key,
    this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isMobile(context)) {
          return mobileBuilder?.call(context) ?? _defaultBuilder(context);
        } else if (isTablet(context)) {
          return tabletBuilder?.call(context) ?? 
                 mobileBuilder?.call(context) ?? 
                 _defaultBuilder(context);
        } else {
          return desktopBuilder?.call(context) ?? 
                 tabletBuilder?.call(context) ?? 
                 mobileBuilder?.call(context) ?? 
                 _defaultBuilder(context);
        }
      },
    );
  }

  Widget _defaultBuilder(BuildContext context) {
    return const Center(
      child: Text('No layout defined'),
    );
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }
}

class ResponsiveSpacing {
  static double getResponsiveSpacing(BuildContext context) {
    if (ResponsiveLayout.isMobile(context)) {
      return 8.0;  // Smaller spacing for mobile
    } else if (ResponsiveLayout.isTablet(context)) {
      return 16.0; // Medium spacing for tablet
    } else {
      return 24.0; // Larger spacing for desktop
    }
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
