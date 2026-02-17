import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_widget.dart';
import '../../widgets/fade_slide_in.dart';
import '../forms/driver_application_dialog.dart';

class DriverRegistrationSection extends StatelessWidget {
  const DriverRegistrationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWidget.isLargeScreen(context);

    return Container(
      color: AppTheme.scaffoldBackgroundColor,
      width: double.infinity,
      child: isDesktop
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SizedBox(
      height: 700,
      child: Row(
        children: [
          // Left: Visual panel with car + road + stats
          Expanded(
            flex: 5,
            child: _buildVisualPanel(context, true),
          ),
          // Right: Content
          Expanded(
            flex: 5,
            child: _buildContent(context, true),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          SizedBox(
            height: 320,
            child: _buildVisualPanel(context, false),
          ),
          _buildContent(context, false),
        ],
      ),
    );
  }

  Widget _buildVisualPanel(BuildContext context, bool isDesktop) {
    return Container(
      margin: isDesktop ? const EdgeInsets.all(80) : const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grid pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                color: AppTheme.textColor.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Top-right glow
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom glow
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Central: Road + Car illustration
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Car in a gradient circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Container(
                      width: isDesktop ? 200 : 150,
                      height: isDesktop ? 200 : 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Circle border
                    Container(
                      width: isDesktop ? 160 : 120,
                      height: isDesktop ? 160 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cardFillColor,
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.25),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.12),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            'assets/images/cars/driver_partner.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.electric_car,
                                size: isDesktop ? 50 : 36,
                                color: AppTheme.primaryColor,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // Charging bolt badge
                    Positioned(
                      bottom: isDesktop ? 15 : 8,
                      right: isDesktop ? 15 : 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.bolt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 30 : 20),
                // Stats row
                FadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatCard(context, '500+', 'Drivers', Icons.person_outline),
                      SizedBox(width: isDesktop ? 16 : 10),
                      _buildStatCard(context, '4', 'States', Icons.map_outlined),
                      SizedBox(width: isDesktop ? 16 : 10),
                      _buildStatCard(context, '24/7', 'Support', Icons.headset_mic_outlined),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Floating dots
          Positioned(top: 40, left: 40, child: _buildDot(7)),
          Positioned(top: 80, right: 80, child: _buildDot(5)),
          Positioned(bottom: 60, right: 50, child: _buildDot(6)),
          Positioned(bottom: 40, left: 100, child: _buildDot(4)),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardFillColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.greyTextColor,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 24,
        vertical: isDesktop ? 60 : 30,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Accent line
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
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
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'JOIN AS A DRIVER',
              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 38 : 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryColor,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'We are hiring professional drivers across Kerala, Karnataka, Tamil Nadu, and Puducherry.',
              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: isDesktop ? 15 : 14,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Feature items in a 2x2 grid
          FadeSlideIn(
            delay: const Duration(milliseconds: 500),
            child: isDesktop
                ? Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureCard(
                              context,
                              Icons.electric_car,
                              'Premium EVs',
                              'Drive top electric vehicles',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFeatureCard(
                              context,
                              Icons.attach_money,
                              'Great Earnings',
                              'Competitive pay & incentives',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureCard(
                              context,
                              Icons.schedule,
                              'Flexible Hours',
                              'Work on your own schedule',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFeatureCard(
                              context,
                              Icons.health_and_safety,
                              'Health Benefits',
                              'Insurance & medical cover',
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildFeatureItem(
                          context, Icons.electric_car, 'Drive premium electric vehicles'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                          context, Icons.attach_money, 'Competitive earnings & incentives'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                          context, Icons.schedule, 'Flexible working hours'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                          context, Icons.health_and_safety, 'Insurance & health benefits'),
                    ],
                  ),
          ),
          const SizedBox(height: 32),
          FadeSlideIn(
            delay: const Duration(milliseconds: 700),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const DriverApplicationDialog(),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('FILL APPLICATION FORM'),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Desktop: Card-style feature with title + subtitle
  Widget _buildFeatureCard(
      BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardFillColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.greyTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mobile: Simple row feature item
  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryColor.withValues(alpha: 0.3),
      ),
    );
  }
}

// Subtle grid background
class _GridPainter extends CustomPainter {
  final Color? color;
  _GridPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += 45) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 45) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
