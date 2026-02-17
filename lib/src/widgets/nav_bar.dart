import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_widget.dart';

class NavBar extends StatelessWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onDriversTap;
  final VoidCallback? onFranchiseTap;
  final VoidCallback? onEvStationsTap;

  const NavBar({
    super.key,
    this.onHomeTap,
    this.onDriversTap,
    this.onFranchiseTap,
    this.onEvStationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWidget.isLargeScreen(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 80 : 16,
          vertical: 12,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : 16,
                vertical: isDesktop ? 14 : 10,
              ),
              decoration: BoxDecoration(
                color: AppTheme.cardFillColor.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nav Links (left side on desktop)
                  if (isDesktop)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _NavLink(title: 'Home', onTap: onHomeTap),
                        const SizedBox(width: 8),
                        _NavLink(title: 'Drivers', onTap: onDriversTap),
                        const SizedBox(width: 8),
                        _NavLink(title: 'Franchise', onTap: onFranchiseTap),
                        const SizedBox(width: 8),
                        _NavLink(title: 'EV Stations', onTap: onEvStationsTap),
                      ],
                    ),

                  // Logo (center)
                  GestureDetector(
                    onTap: onHomeTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.bolt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'EV TAXI',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side: CTA button (desktop) or menu icon (mobile)
                  if (isDesktop)
                    ElevatedButton(
                      onPressed: onHomeTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => _showMobileMenu(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with Logo and Close Button (No stagger, just fade)
                    FadeTransition(
                      opacity: animation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.bolt, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'EV TAXI',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            // Close Button
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: AppTheme.textColor, size: 28),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Menu Items
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildAnimatedMenuItem(
                            context: context,
                            animation: animation,
                            index: 0,
                            child: _MobileMenuItem(
                              title: 'Home',
                              onTap: () {
                                Navigator.pop(context);
                                onHomeTap?.call();
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAnimatedMenuItem(
                            context: context,
                            animation: animation,
                            index: 1,
                            child: _MobileMenuItem(
                              title: 'Drivers',
                              onTap: () {
                                Navigator.pop(context);
                                onDriversTap?.call();
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAnimatedMenuItem(
                            context: context,
                            animation: animation,
                            index: 2,
                            child: _MobileMenuItem(
                              title: 'Franchise',
                              onTap: () {
                                Navigator.pop(context);
                                onFranchiseTap?.call();
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAnimatedMenuItem(
                            context: context,
                            animation: animation,
                            index: 3,
                            child: _MobileMenuItem(
                              title: 'EV Stations',
                              onTap: () {
                                Navigator.pop(context);
                                onEvStationsTap?.call();
                              },
                            ),
                          ),
                          const SizedBox(height: 30), // Bottom padding
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  Widget _buildAnimatedMenuItem({
    required BuildContext context,
    required Animation<double> animation,
    required int index,
    required Widget child,
  }) {
    // Alternating direction: Even -> Left (-1), Odd -> Right (1)
    final double beginX = index.isEven ? -0.5 : 0.5;

    // Staggered interval
    final double startTime = 0.2 + (index * 0.1);
    final double endTime = startTime + 0.4;

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(
        startTime.clamp(0.0, 1.0),
        endTime.clamp(0.0, 1.0),
        curve: Curves.easeOutBack,
      ),
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(beginX, 0),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: FadeTransition(
        opacity: curvedAnimation,
        child: child,
      ),
    );
  }
}

class _MobileMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _MobileMenuItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA), // Very light grey
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;
  const _NavLink({required this.title, this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.primaryColor.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: _isHovered
                  ? AppTheme.primaryColor
                  : AppTheme.textColor.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
