import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext) mobileBuilder;
  final Widget Function(BuildContext) tabletBuilder;
  final Widget Function(BuildContext) desktopBuilder;

  const ResponsiveLayout({
    Key? key,
    required this.mobileBuilder,
    required this.tabletBuilder,
    required this.desktopBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logger = Logger('ResponsiveLayout');
    
    try {
      return LayoutBuilder(
        builder: (context, constraints) {
          logger.info('Screen width: ${constraints.maxWidth}');
          
          if (constraints.maxWidth < 600) {
            logger.info('Mobile layout selected');
            return mobileBuilder(context);
          } else if (constraints.maxWidth < 1200) {
            logger.info('Tablet layout selected');
            return tabletBuilder(context);
          } else {
            logger.info('Desktop layout selected');
            return desktopBuilder(context);
          }
        },
      );
    } catch (e, stackTrace) {
      logger.severe('Error in ResponsiveLayout: $e', e, stackTrace);
      
      return Center(
        child: ErrorWidget(
          FlutterError.fromParts([
            ErrorSummary('Responsive Layout Error'),
            ErrorDescription('An unexpected error occurred while rendering the layout.'),
            DiagnosticsProperty<dynamic>('Error Details', e),
          ]),
        ),
      );
    }
  }

  // Static utility methods for checking device type
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
