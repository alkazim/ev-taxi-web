import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_widget.dart';
import '../../widgets/fade_slide_in.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveWidget.isLargeScreen(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isDesktop ? 700 : 620),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.scaffoldBackgroundColor,
            AppTheme.surfaceColor,
            AppTheme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background decorative elements (positioned, drawn first = behind)
          Positioned.fill(
            child: RepaintBoundary(
              child: _buildBackgroundEffects(isDesktop),
            ),
          ),
          // Subtle grid
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _HeroGridPainter(
                  color: AppTheme.textColor.withValues(alpha: 0.04),
                ),
              ),
            ),
          ),
          // Bottom fade-out gradient for smooth transition to next section
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                    AppTheme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
          // Main content (non-positioned, determines Stack size, drawn on top)
          Padding(
            padding: EdgeInsets.only(top: isDesktop ? 100 : 90),
            child: isDesktop
                ? _buildDesktopLayout(context)
                : _buildMobileLayout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundEffects(bool isDesktop) {
    return Stack(
      children: [
        // Top-right glow
        Positioned(
          top: -120,
          right: -80,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom-left glow
        Positioned(
          bottom: -100,
          left: -60,
          child: Container(
            width: 300,
            height: 300,
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
        ),
        // Decorative dots
        Positioned(top: 140, left: 60, child: _buildDot(6)),
        Positioned(top: 220, right: 100, child: _buildDot(8)),
        Positioned(bottom: 180, left: 180, child: _buildDot(5)),
        Positioned(bottom: 120, right: 60, child: _buildDot(7)),
        // Decorative rings
        if (isDesktop) ...[
          Positioned(
            top: 100,
            right: 300,
            child: _buildRing(50, 1.2),
          ),
          Positioned(
            bottom: 160,
            left: 120,
            child: _buildRing(35, 1),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Text content
          Expanded(
            flex: 5,
            child: _buildHeroContent(context, true),
          ),
          const SizedBox(width: 40),
          // Right: EV Car showcase
          Expanded(
            flex: 5,
            child: _buildCarShowcase(context, true),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildHeroContent(context, false),
          const SizedBox(height: 30),
          _buildCarShowcase(context, false),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // EV Badge
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.5),
                  width: 1.5),
              color: AppTheme.cardFillColor,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, color: AppTheme.primaryColor, size: 16),
                SizedBox(width: 6),
                Text(
                  '100% ELECTRIC FLEET',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Title
        FadeSlideIn(
          delay: const Duration(milliseconds: 400),
          child: Text(
            'PREMIUM TAXI\nSERVICE IN INDIA',
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: isDesktop ? 52 : 32,
              fontWeight: FontWeight.w800,
              letterSpacing: isDesktop ? 3 : 1.5,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 18),
        // Subtitle
        FadeSlideIn(
          delay: const Duration(milliseconds: 600),
          child: Text(
            'Experience luxury and comfort with our elite\nelectric vehicle fleet across India.',
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 17 : 14,
              color: AppTheme.secondaryTextColor,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // CTA Buttons
        FadeSlideIn(
          delay: const Duration(milliseconds: 800),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 36 : 28,
                    vertical: isDesktop ? 18 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('BOOK A RIDE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(
                    color: AppTheme.primaryColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 28 : 20,
                    vertical: isDesktop ? 18 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Watch Demo', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // Stat badges
        FadeSlideIn(
          delay: const Duration(milliseconds: 1000),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 12, vertical: isDesktop ? 16 : 10),
            decoration: BoxDecoration(
              color: AppTheme.cardFillColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisSize: isDesktop ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(context, '1000+', 'Happy Riders', Icons.people_alt_outlined, isDesktop),
                _buildStatDivider(isDesktop),
                _buildStatItem(context, '50+', 'EV Cars', Icons.electric_car_outlined, isDesktop),
                _buildStatDivider(isDesktop),
                _buildStatItem(context, '4', 'States', Icons.location_on_outlined, isDesktop),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon, bool isDesktop) {
    int target = 0;
    String suffix = '';
    final RegExp regex = RegExp(r'(\d+)(.*)');
    final match = regex.firstMatch(value);
    if (match != null) {
      target = int.parse(match.group(1)!);
      suffix = match.group(2) ?? '';
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 8 : 5),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isDesktop ? 10 : 8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: isDesktop ? 18 : 14),
          ),
          SizedBox(width: isDesktop ? 10 : 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CountUpText(
                target: target,
                suffix: suffix,
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: isDesktop ? 20 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.greyTextColor,
                  fontSize: isDesktop ? 11 : 9,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDesktop) {
    return Container(
      width: 1,
      height: isDesktop ? 36 : 28,
      color: AppTheme.primaryColor.withValues(alpha: 0.15),
    );
  }

  Widget _buildCarShowcase(BuildContext context, bool isDesktop) {
    final double showcaseSize = isDesktop ? 420 : 300;
    return FadeSlideIn(
      delay: const Duration(milliseconds: 500),
      child: SizedBox(
        width: showcaseSize,
        height: showcaseSize,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Soft ambient glow that blends with background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.12),
                      AppTheme.primaryColor.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Outer ring
            Center(
              child: Container(
                width: isDesktop ? 340 : 240,
                height: isDesktop ? 340 : 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Middle glowing circle
            Center(
              child: Container(
                width: isDesktop ? 260 : 185,
                height: isDesktop ? 260 : 185,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.14),
                      AppTheme.primaryColor.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Inner bright circle with subtle glow
            Center(
              child: Container(
                width: isDesktop ? 170 : 120,
                height: isDesktop ? 170 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.18),
                      AppTheme.primaryColor.withValues(alpha: 0.06),
                    ],
                  ),
                ),
              ),
            ),
            // Central EV concept icon composition
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main icon - EV car with glow
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 22 : 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.electric_car,
                      size: isDesktop ? 48 : 32,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 10 : 6),
                  // "EV TAXI" pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.35),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      'EV TAXI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 12 : 9,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Unified Feature Nodes (Icon + Text Badge)
            Positioned(
              top: isDesktop ? 20 : 10,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.translate(
                  offset: Offset(isDesktop ? -130 : -95, 0),
                  child: _buildFeatureNode(Icons.eco, 'Eco Friendly', isDesktop),
                ),
              ),
            ),
            Positioned(
              top: isDesktop ? 30 : 18,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.translate(
                  offset: Offset(isDesktop ? 140 : 100, 0),
                  child: _buildFeatureNode(Icons.bolt, '0 Emission', isDesktop),
                ),
              ),
            ),
            Positioned(
              bottom: isDesktop ? 50 : 35,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.translate(
                  offset: Offset(isDesktop ? -150 : -105, 0),
                  child: _buildFeatureNode(Icons.access_time_filled, '24/7 Service', isDesktop),
                ),
              ),
            ),
            Positioned(
              bottom: isDesktop ? 30 : 20,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.translate(
                  offset: Offset(isDesktop ? 135 : 95, 0),
                  child: _buildFeatureNode(Icons.ev_station, '100% Electric', isDesktop),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureNode(IconData icon, String text, bool isDesktop) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular Icon
        Container(
          padding: EdgeInsets.all(isDesktop ? 12 : 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cardFillColor,
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: isDesktop ? 20 : 14,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        // Text Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.cardFillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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

  Widget _buildRing(double size, double borderWidth) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.12),
          width: borderWidth,
        ),
      ),
    );
  }
}

// ───── Grid Painter ─────
class _HeroGridPainter extends CustomPainter {
  final Color? color;
  _HeroGridPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ───── Count Up Animation ─────
class CountUpText extends StatefulWidget {
  final int target;
  final String suffix;
  final TextStyle? style;
  final Duration duration;

  const CountUpText({
    super.key,
    required this.target,
    this.suffix = '',
    this.style,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = IntTween(begin: 0, end: widget.target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${_animation.value}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
