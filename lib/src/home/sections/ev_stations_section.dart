import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_widget.dart';
import '../../widgets/fade_slide_in.dart';

class EVStationsSection extends StatelessWidget {
  const EVStationsSection({super.key});

  Future<void> _launchMaps() async {
    const double lat = 9.9312;
    const double lng = 76.2673;
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=EV+charging+stations+near+$lat,$lng');
    if (!await launchUrl(googleMapsUrl)) {
      throw Exception('Could not launch $googleMapsUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWidget.isLargeScreen(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.scaffoldBackgroundColor,
            AppTheme.surfaceVariant,
            AppTheme.scaffoldBackgroundColor,
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 100 : 60,
        horizontal: isDesktop ? 80 : 20,
      ),
      child: Column(
        children: [
          // Section header
          FadeSlideIn(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const FadeSlideIn(
            delay: Duration(milliseconds: 100),
            child: Text(
              'CHARGING NETWORK',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Find EV Stations\nNear You',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 42 : 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: SizedBox(
              width: 500,
              child: Text(
                'Access our growing network of fast-charging stations across India. Real-time availability, route planning, and seamless payments.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  color: AppTheme.secondaryTextColor,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),

          // Stats row
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: isDesktop ? 40 : 20,
                runSpacing: 20,
                children: [
                  _buildStatCard(
                    context,
                    '500+',
                    'Charging Stations',
                    Icons.ev_station_rounded,
                    isDesktop,
                  ),
                  _buildStatCard(
                    context,
                    '50kW',
                    'Fast Charging',
                    Icons.bolt_rounded,
                    isDesktop,
                  ),
                  _buildStatCard(
                    context,
                    '24/7',
                    'Availability',
                    Icons.access_time_filled_rounded,
                    isDesktop,
                  ),
                  _buildStatCard(
                    context,
                    '15+',
                    'Cities Covered',
                    Icons.location_city_rounded,
                    isDesktop,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),

          // Map Card
          FadeSlideIn(
            delay: const Duration(milliseconds: 500),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.06),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: isDesktop ? 420 : 300,
                  child: Stack(
                    children: [
                      // Map placeholder with dark overlay
                      Positioned.fill(
                        child: _buildMapPlaceholder(isDesktop),
                      ),

                      // Station pins
                      ..._buildStationPins(isDesktop),

                      // Gradient overlay at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 160,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF0F1923).withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom bar with info and CTA
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 32 : 20),
                          child: isDesktop
                              ? Row(
                                  children: [
                                    // Left: info
                                    Expanded(child: _buildMapInfo()),
                                    const SizedBox(width: 24),
                                    // Right: CTA
                                    _buildMapCTA(),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMapInfo(),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: _buildMapCTA(),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),

          // Feature cards row
          FadeSlideIn(
            delay: const Duration(milliseconds: 600),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildFeatureCard(
                    context,
                    Icons.speed_rounded,
                    'Fast Charging',
                    'Level 2 & Level 3 DC fast chargers with up to 50kW output',
                    isDesktop,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.route_rounded,
                    'Route Planning',
                    'Smart route planning with charging stops optimized for your journey',
                    isDesktop,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.payment_rounded,
                    'Easy Payments',
                    'Seamless digital payments via UPI, cards, and in-app wallet',
                    isDesktop,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label,
      IconData icon, bool isDesktop) {
    return Container(
      width: isDesktop ? 185 : 150,
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: AppTheme.cardFillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 12 : 11,
              color: AppTheme.secondaryTextColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(bool isDesktop) {
    return Container(
      color: const Color(0xFF1A2530),
      child: CustomPaint(
        painter: _MapGridPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  List<Widget> _buildStationPins(bool isDesktop) {
    final pins = [
      {'top': 0.2, 'left': 0.3, 'label': 'Kochi'},
      {'top': 0.35, 'left': 0.55, 'label': 'Trivandrum'},
      {'top': 0.15, 'left': 0.65, 'label': 'Coimbatore'},
      {'top': 0.45, 'left': 0.4, 'label': 'Bangalore'},
      {'top': 0.25, 'left': 0.75, 'label': 'Chennai'},
      if (isDesktop) {'top': 0.5, 'left': 0.2, 'label': 'Mysore'},
      if (isDesktop) {'top': 0.3, 'left': 0.15, 'label': 'Calicut'},
    ];

    return pins.map((pin) {
      return Positioned(
        top: null,
        left: null,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return const SizedBox.shrink();
          },
        ),
      );
    }).toList();
  }

  Widget _buildStationPin(String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Live Station Map',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Find real-time availability and navigate to the nearest charging point',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildMapCTA() {
    return ElevatedButton.icon(
      onPressed: _launchMaps,
      icon: const Icon(Icons.map_rounded, size: 20),
      label: const Text(
        'OPEN MAP',
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title,
      String description, bool isDesktop) {
    final cardWidth = isDesktop ? 300.0 : double.infinity;

    return SizedBox(
      width: cardWidth,
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 28 : 24),
        decoration: BoxDecoration(
          color: AppTheme.cardFillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.15),
                    AppTheme.primaryColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.secondaryTextColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───── Map Grid Painter ─────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dark grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Glowing station dots
    final dotPaint = Paint()..color = AppTheme.primaryColor;
    final glowPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final dots = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.35, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.65, size.height * 0.45),
      Offset(size.width * 0.8, size.height * 0.35),
      Offset(size.width * 0.15, size.height * 0.6),
      Offset(size.width * 0.45, size.height * 0.7),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.55, size.height * 0.55),
      Offset(size.width * 0.3, size.height * 0.2),
      Offset(size.width * 0.85, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.4),
    ];

    // Draw connection lines between nearby dots
    final linePaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (int i = 0; i < dots.length; i++) {
      for (int j = i + 1; j < dots.length; j++) {
        final dist = (dots[i] - dots[j]).distance;
        if (dist < size.width * 0.25) {
          canvas.drawLine(dots[i], dots[j], linePaint);
        }
      }
    }

    // Draw dots with glow
    for (final dot in dots) {
      canvas.drawCircle(dot, 6, glowPaint);
      canvas.drawCircle(dot, 3, dotPaint);
      // White center
      canvas.drawCircle(
          dot, 1.5, Paint()..color = Colors.white.withValues(alpha: 0.8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
