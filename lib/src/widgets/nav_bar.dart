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
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.menu_rounded, color: AppTheme.primaryColor),
                        offset: const Offset(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          ),
                        ),
                        color: Colors.white,
                        elevation: 8,
                        onSelected: (value) {
                          switch (value) {
                            case 'home':
                              onHomeTap?.call();
                            case 'drivers':
                              onDriversTap?.call();
                            case 'franchise':
                              onFranchiseTap?.call();
                            case 'ev_stations':
                              onEvStationsTap?.call();
                          }
                        },
                        itemBuilder: (context) => [
                          _buildPopupItem('home', Icons.home_rounded, 'Home'),
                          _buildPopupItem('drivers', Icons.person_outline, 'Drivers'),
                          _buildPopupItem('franchise', Icons.business_outlined, 'Franchise'),
                          _buildPopupItem('ev_stations', Icons.ev_station_outlined, 'EV Stations'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  static PopupMenuEntry<String> _buildPopupItem(String value, IconData icon, String title) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
        ],
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
