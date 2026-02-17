import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  // Simple breakpoint for mobile vs desktop
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 1024;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  @override
  Widget build(BuildContext context) {
    if (isLargeScreen(context)) {
      return desktop;
    } else {
      return mobile;
    }
  }
}
