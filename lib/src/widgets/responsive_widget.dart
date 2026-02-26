import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // ── Breakpoints ──────────────────────────────────────────────────
  /// < 600 px  → phone
  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  /// 600–1023 px → tablet / large phone
  static bool isTabletScreen(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 1024;
  }

  /// ≥ 1024 px → desktop / wide
  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  /// < 1024 px  (phone OR tablet) — kept for backwards compat
  static bool isMobileOrTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1024;

  @override
  Widget build(BuildContext context) {
    if (isLargeScreen(context)) return desktop;
    if (isTabletScreen(context) && tablet != null) return tablet!;
    return mobile;
  }
}
