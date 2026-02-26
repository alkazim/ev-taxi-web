import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class EVStationsSection extends StatelessWidget {
  const EVStationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    final isModern = context.isModernStyle;

    // V2 / Yellow Variant Colors
    final activeGreen = context.isYellowTheme
        ? const Color(0xFFF59E0B)
        : const Color(0xFF16A34A);
    final activeAmber = const Color(0xFFF59E0B);
    final textDark = const Color(0xFF111827);

    // Classic Fallback
    if (!isModern) {
      return _buildClassic(context, isMobile);
    }

    // Responsive horizontal padding
    final hPad = isMobile
        ? 20.0
        : isTablet
        ? 40.0
        : 80.0;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF9FAFB),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: hPad,
      ),
      child: Column(
        children: [
          // ── Header ──
          Text(
            'CHARGING NETWORK',
            style: GoogleFonts.poppins(
              color: activeGreen,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Powering Your Journey',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isMobile
                  ? 28
                  : isTablet
                  ? 38
                  : 48,
              fontWeight: FontWeight.w800,
              color: textDark,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: isMobile ? double.infinity : 600,
            child: Text(
              'Strategically placed charging stations across South India ensuring you never run out of charge.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF6B7280),
                fontSize: isMobile ? 13 : 16,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 40 : 60),

          // ── Stats Row ──
          Wrap(
            spacing: isMobile ? 12 : 20,
            runSpacing: isMobile ? 12 : 20,
            alignment: WrapAlignment.center,
            children: [
              _buildStatCardV2(
                '50+',
                'Active Stations',
                FontAwesomeIcons.chargingStation,
                activeGreen,
                isMobile,
              ),
              _buildStatCardV2(
                '4',
                'States Covered',
                FontAwesomeIcons.mapLocationDot,
                activeAmber,
                isMobile,
              ),
              _buildStatCardV2(
                '24/7',
                'Availability',
                FontAwesomeIcons.clock,
                const Color(0xFF3B82F6),
                isMobile,
              ),
              _buildStatCardV2(
                '100%',
                'Green Energy',
                FontAwesomeIcons.leaf,
                const Color(0xFF10B981),
                isMobile,
              ),
            ],
          ),
          SizedBox(height: isMobile ? 48 : 80),

          // ── Main Content (Map + Features) ──
          // Desktop: side-by-side. Tablet + Mobile: stacked.
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildMapContainer(context, isMobile, activeGreen),
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      flex: 4,
                      child: _buildFeatureList(
                        context,
                        isMobile,
                        activeGreen,
                        activeAmber,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildMapContainer(context, isMobile, activeGreen),
                    const SizedBox(height: 40),
                    _buildFeatureList(
                      context,
                      isMobile,
                      activeGreen,
                      activeAmber,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStatCardV2(
    String value,
    String label,
    IconData icon,
    Color color, [
    bool isMobile = false,
  ]) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 14 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapContainer(
    BuildContext context,
    bool isMobile,
    Color activeGreen,
  ) {
    return Container(
      height: isMobile ? 300 : 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Placeholder Grid (Replace with GoogleMap widget)
            Positioned.fill(
              child: CustomPaint(
                painter: _MapGridPainter(color: const Color(0xFFE5E7EB)),
              ),
            ),
            // Map UI Overlay (Mock)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const FaIcon(
                  FontAwesomeIcons.crosshairs,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            // Center Message
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeGreen.withValues(alpha: 0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.mapLocationDot,
                      size: 40,
                      color: activeGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      'Interactive Map Integration',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(
    BuildContext context,
    bool isMobile,
    Color green,
    Color amber,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isMobile) const SizedBox(height: 20),
        _buildFeatureItem(
          FontAwesomeIcons.boltLightning,
          'Ultra-Fast Charging',
          'DC Fast Chargers capable of charging 0-80% in under 45 minutes.',
          amber,
        ),
        const SizedBox(height: 32),
        _buildFeatureItem(
          FontAwesomeIcons.road,
          'Smart Route Planning',
          'Intelligent trip planning with automatic charging stop suggestions.',
          const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 32),
        _buildFeatureItem(
          FontAwesomeIcons.creditCard,
          'Seamless Payments',
          'Pay instantly via UPI, Credit Card, or EV Wallet.',
          const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(
                'https://www.google.com/maps/search/EV+charging+stations+Kerala',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: context.isYellowTheme
                  ? Colors.black87
                  : Colors.white,
              elevation: 4,
              shadowColor: green.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(
                  FontAwesomeIcons.magnifyingGlassLocation,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  'OPEN IN GOOGLE MAPS',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String desc,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: FaIcon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.5,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CLASSIC FALLBACK (Retained for safety, minimal implementation)
  // ─────────────────────────────────────────────────────────────────
  Widget _buildClassic(BuildContext context, bool isMobile) {
    final isV2 = context.isV2Theme;
    final activeGreen = context.isYellowTheme
        ? const Color(0xFFF59E0B)
        : (isV2 ? const Color(0xFF16A34A) : AppTheme.primaryColor);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Container(
      color: isV2
          ? const Color(0xFFF9FAFB)
          : Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isDesktop ? 80 : 20,
      ),
      child: Column(
        children: [
          // Basic Classic Header
          Text(
            'CHARGING NETWORK',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: activeGreen,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 20),
          // Basic placeholder for classic
          const Text("Classic View Enabled"),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final Color? color;
  _MapGridPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0; // Slightly thicker grid for V2

    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
