import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../services/locale_provider.dart';
import '../theme/app_theme.dart';

class NavBar extends StatelessWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onDriversTap;
  final VoidCallback? onFleetsTap;
  final VoidCallback? onFranchiseTap;
  final VoidCallback? onEvStationsTap;
  final VoidCallback? onContactTap;

  const NavBar({
    super.key,
    this.onHomeTap,
    this.onDriversTap,
    this.onFleetsTap,
    this.onFranchiseTap,
    this.onEvStationsTap,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isV2 = context.isV2Theme;

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
              color: isV2
                  ? Colors.white.withValues(alpha: 0.97)
                  : AppTheme.cardFillColor.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isV2
                    ? const Color(0xFFE5E7EB)
                    : AppTheme.primaryColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isV2
                      ? Colors.black.withValues(alpha: 0.08)
                      : AppTheme.primaryColor.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Logo (left)
                GestureDetector(
                  onTap: onHomeTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.isYellowTheme
                              ? const Color(0xFFF59E0B)
                              : (isV2
                                    ? const Color(0xFF16A34A)
                                    : AppTheme.primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.bolt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'E-CABBZ',
                        style: TextStyle(
                          color: isV2
                              ? const Color(0xFF111827)
                              : AppTheme.textColor,
                          fontSize: isDesktop ? 20 : 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isDesktop) const Spacer(),

                // Right side: Nav Links + CTA (desktop) or Menu Icon (mobile)
                if (isDesktop)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NavLink(title: AppLocalizations.of(context)?.home ?? 'Home', onTap: onHomeTap),
                      const SizedBox(width: 4),
                      _NavLink(title: AppLocalizations.of(context)?.drivers ?? 'Drivers', onTap: onDriversTap),
                      const SizedBox(width: 4),
                      _NavLink(title: AppLocalizations.of(context)?.fleets ?? 'Fleets', onTap: onFleetsTap),
                      const SizedBox(width: 4),
                      _NavLink(title: AppLocalizations.of(context)?.franchise ?? 'Franchise', onTap: onFranchiseTap),
                      const SizedBox(width: 4),
                      _NavLink(title: AppLocalizations.of(context)?.evStations ?? 'EV Stations', onTap: onEvStationsTap),
                      const SizedBox(width: 4),
                      _NavLink(title: AppLocalizations.of(context)?.contactUs ?? 'Contact Us', onTap: onContactTap),
                      const SizedBox(width: 20),
                      const _LanguageSwitcher(),
                      const SizedBox(width: 12),
                      _BookNowButton(isV2: isV2, onTap: onHomeTap),
                    ],
                  )
                else ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showMobileMenu(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.isYellowTheme
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                            : const Color(0xFF16A34A).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.isYellowTheme
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                              : const Color(0xFF16A34A).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.menu_rounded,
                        color: context.isYellowTheme
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF16A34A),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    final isV2 = context.isV2Theme;
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with Logo and Close Button
                    FadeTransition(
                      opacity: animation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: context.isYellowTheme
                                        ? const Color(0xFFF59E0B)
                                        : (isV2
                                              ? const Color(0xFF16A34A)
                                              : AppTheme.primaryColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.bolt,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'EV TAXI',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                            // Close Button
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF111827),
                                size: 28,
                              ),
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
                              isV2: isV2,
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
                              isV2: isV2,
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
                              title: 'Fleets',
                              isV2: isV2,
                              onTap: () {
                                Navigator.pop(context);
                                onFleetsTap?.call();
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAnimatedMenuItem(
                            context: context,
                            animation: animation,
                            index: 3,
                            child: _MobileMenuItem(
                              title: 'Franchise',
                              isV2: isV2,
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
                            index: 4,
                            child: _MobileMenuItem(
                              title: 'EV Stations',
                              isV2: isV2,
                              onTap: () {
                                Navigator.pop(context);
                                onEvStationsTap?.call();
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAnimatedMenuItem(
                            context: context,
                            animation: animation,
                            index: 5,
                            child: _MobileMenuItem(
                              title: AppLocalizations.of(context)?.contactUs ?? 'Contact Us',
                              isV2: isV2,
                              onTap: () {
                                Navigator.pop(context);
                                onContactTap?.call();
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          const _LanguageSwitcher(),
                          const SizedBox(height: 30),
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
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
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
    final double beginX = index.isEven ? -0.5 : 0.5;
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
      child: FadeTransition(opacity: curvedAnimation, child: child),
    );
  }
}

// ── Book Now Button (V2 = yellow, Classic = green) ──
class _BookNowButton extends StatefulWidget {
  final bool isV2;
  final VoidCallback? onTap;
  const _BookNowButton({required this.isV2, this.onTap});

  @override
  State<_BookNowButton> createState() => _BookNowButtonState();
}

class _BookNowButtonState extends State<_BookNowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isYellow = context.isYellowTheme;
    final accentColor = isYellow
        ? const Color(0xFFF59E0B)
        : const Color(0xFF16A34A);
    final hoverAccent = isYellow
        ? const Color(0xFFB45309)
        : const Color(0xFF15803D);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isV2
                ? (_hovered ? hoverAccent : accentColor)
                : (isYellow ? const Color(0xFFF59E0B) : AppTheme.primaryColor),
            borderRadius: BorderRadius.circular(30),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            AppLocalizations.of(context)?.bookNow ?? 'Book Now',
            style: TextStyle(
              color: isYellow ? Colors.black87 : Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileMenuItem extends StatelessWidget {
  final String title;
  final bool isV2;
  final VoidCallback onTap;

  const _MobileMenuItem({
    required this.title,
    required this.isV2,
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
          color: isV2 ? const Color(0xFFF9FAFB) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isV2
                ? const Color(0xFFE5E7EB)
                : AppTheme.primaryColor.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: context.isYellowTheme
                  ? const Color(0xFFF59E0B)
                  : (isV2 ? const Color(0xFF16A34A) : AppTheme.primaryColor),
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
    final isV2 = context.isV2Theme;
    final isYellow = context.isYellowTheme;
    final accentColor = isYellow
        ? const Color(0xFFF59E0B)
        : (isV2 ? const Color(0xFF16A34A) : AppTheme.primaryColor);
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
                ? accentColor.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: _isHovered
                  ? accentColor
                  : (isV2 || isYellow
                        ? const Color(0xFF374151)
                        : AppTheme.textColor.withValues(alpha: 0.7)),
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

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final currentCode = provider.locale?.languageCode ?? 'en';

    final languages = [
      {'code': 'en', 'label': 'English', 'short': 'EN'},
      {'code': 'hi', 'label': 'हिन्दी', 'short': 'हि'},
      {'code': 'ml', 'label': 'മലയാളം', 'short': 'മ'},
    ];

    return PopupMenuButton<String>(
      onSelected: (code) {
        provider.setLocale(Locale(code));
      },
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      tooltip: 'Select Language',
      // Trigger Button
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 20, color: Color(0xFF6B7280)),
            const SizedBox(width: 10),
            Text(
              currentCode.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF374151),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
      itemBuilder: (context) {
        return languages.map((lang) {
          final isSelected = currentCode == lang['code'];
          return PopupMenuItem<String>(
            value: lang['code']!,
            height: 64,
            child: Row(
              children: [
                // Icon Box (Lead)
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8F5E9) // Light green for active
                        : const Color(0xFFF3F4F6), // Light grey for inactive
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lang['short']!,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF4B5563),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Label
                Expanded(
                  child: Text(
                    lang['label']!,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF111827),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Checkmark
                if (isSelected)
                  const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF16A34A),
                    size: 20,
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
