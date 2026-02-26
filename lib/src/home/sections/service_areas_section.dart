import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_widget.dart';

/// Service Areas Section — swipeable PageView carousel.
/// Each page: place image on the left, descriptive text on the right.
/// Dot indicators + prev/next arrow buttons for navigation.
class ServiceAreasSection extends StatefulWidget {
  const ServiceAreasSection({super.key});

  @override
  State<ServiceAreasSection> createState() => _ServiceAreasSectionState();
}

class _ServiceAreasSectionState extends State<ServiceAreasSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Defer timer until after the first frame so it doesn't compete
    // with initial layout and paint on load.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentPage < _areas.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _resetTimer() {
    _startTimer();
  }

  static const _areas = [
    _AreaData(
      name: 'Kerala',
      tagline: "God's Own Country",
      highlight: 'Kochi · Trivandrum · Kozhikode',
      imageAsset: 'assets/images/places/Kerala.webp',
      accentColor: Color(0xFF059669),
      description:
          'Experience the serene backwaters, lush greenery, and vibrant culture of Kerala. '
          'Our EV taxis connect you seamlessly across Kochi, Trivandrum, and Kozhikode — '
          'clean, quiet, and comfortable.',
      features: [
        'Backwater Routes',
        'Airport Transfers',
        'City Commutes',
        'Hill Station Trips',
      ],
    ),
    _AreaData(
      name: 'Karnataka',
      tagline: 'One State, Many Worlds',
      highlight: 'Bangalore · Mysore · Mangalore',
      imageAsset: 'assets/images/places/Karnataka.webp',
      accentColor: Color(0xFF4338CA),
      description:
          'From the tech corridors of Bangalore to the royal heritage of Mysore, '
          'Karnataka offers a world of contrasts. Our EVs navigate every corner '
          'efficiently — zero emissions, zero compromise.',
      features: [
        'Tech Park Shuttles',
        'Heritage Tours',
        'Corporate Rides',
        'Weekend Getaways',
      ],
    ),
    _AreaData(
      name: 'Tamil Nadu',
      tagline: 'Land of Temples',
      highlight: 'Chennai · Coimbatore · Madurai',
      imageAsset: 'assets/images/places/Tamilnadu.webp',
      accentColor: Color(0xFFEA580C),
      description:
          'Discover the ancient temples, bustling cities, and coastal beauty of Tamil Nadu. '
          'Whether it\'s a pilgrimage to Madurai or a business trip to Chennai, '
          'our EV fleet gets you there sustainably.',
      features: [
        'Temple Circuit Rides',
        'Port City Transfers',
        'IT Corridor Commutes',
        'Coastal Drives',
      ],
    ),
    _AreaData(
      name: 'Puducherry',
      tagline: 'The French Riviera of the East',
      highlight: 'Pondicherry · Karaikal · Yanam',
      imageAsset: 'assets/images/places/Puducherry.webp',
      accentColor: Color(0xFF0284C7),
      description:
          'Stroll through French colonial streets, pristine beaches, and spiritual ashrams. '
          'Puducherry\'s charm deserves a ride as elegant as the destination — '
          'our silent EVs blend right in.',
      features: [
        'Beach Transfers',
        'Heritage Town Tours',
        'Ashram Visits',
        'Scenic Coastal Rides',
      ],
    ),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _resetTimer();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWidget.isLargeScreen(context);
    final isTablet = ResponsiveWidget.isTabletScreen(context);
    final isModern = context.isModernStyle;
    final isYellow = context.isYellowTheme;
    final green = isModern ? const Color(0xFF16A34A) : AppTheme.primaryColor;
    final amber = const Color(0xFFF59E0B);
    // Controls accent color: amber in Yellow Theme, green in Green Theme
    final accent = isYellow ? amber : green;

    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 80 : 56,
        horizontal: isDesktop ? 60 : (isTablet ? 40 : 20),
      ),
      child: Column(
        children: [
          // ── Header ──
          _buildHeader(isDesktop, accent, amber),
          SizedBox(height: isDesktop ? 52 : 36),

          LayoutBuilder(
            builder: (ctx, box) {
              final carouselH = isDesktop
                  ? 420.0
                  : isTablet
                  ? 480.0
                  // Mobile: taller because content stacks vertically
                  : (box.maxWidth < 400 ? 620.0 : 560.0);

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1280 : double.infinity,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          // Reserve space for arrow buttons on desktop & tablet
                          horizontal: isDesktop ? 68 : (isTablet ? 52 : 0),
                        ),
                        child: SizedBox(
                          height: carouselH,
                          child: Listener(
                            onPointerDown: (_) => _timer?.cancel(),
                            onPointerUp: (_) => _resetTimer(),
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _areas.length,
                              onPageChanged: (i) =>
                                  setState(() => _currentPage = i),
                              itemBuilder: (context, index) {
                                return RepaintBoundary(
                                  child: _AreaPage(
                                    area: _areas[index],
                                    isDesktop: isDesktop,
                                    isV2: isModern,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // ── Side Arrows (Desktop & Tablet only, hidden on mobile) ──
                      if (isDesktop || isTablet) ...[
                        Positioned(
                          left: 0,
                          child: _ArrowButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            enabled: _currentPage > 0,
                            onTap: () => _goTo(_currentPage - 1),
                            color: accent,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: _ArrowButton(
                            icon: Icons.arrow_forward_ios_rounded,
                            enabled: _currentPage < _areas.length - 1,
                            onTap: () => _goTo(_currentPage + 1),
                            color: accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // ── Controls: arrows + dots ──
          _buildControls(isDesktop, accent),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop, Color green, Color amber) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: green.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_rounded, color: green, size: 15),
              const SizedBox(width: 6),
              Text(
                'WHERE WE OPERATE',
                style: GoogleFonts.poppins(
                  color: green,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 40 : 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
              color: const Color(0xFF111827),
            ),
            children: [
              const TextSpan(text: 'Available Across '),
              TextSpan(
                text: '4 States',
                // amber in Yellow Theme, green in Green Theme
                style: TextStyle(color: green),
              ),
              const TextSpan(text: ' in South India'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Expanding our clean mobility network to more cities every month.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: const Color(0xFF6B7280),
            fontSize: isDesktop ? 15 : 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // Only shows dot indicators — arrows are in the Stack for desktop/tablet, hidden on mobile
  Widget _buildControls(bool isDesktop, Color green) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_areas.length, (i) {
            final active = i == _currentPage;
            return GestureDetector(
              onTap: () => _goTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? green : green.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Arrow Button ─────────────────────────────────────────────────────────────
class _ArrowButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color color;

  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.color,
  });

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.enabled
                ? (_hovered
                      ? widget.color
                      : widget.color.withValues(alpha: 0.1))
                : const Color(0xFFE5E7EB),
            border: Border.all(
              color: widget.enabled
                  ? widget.color.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: widget.enabled
                ? (_hovered ? Colors.white : widget.color)
                : const Color(0xFFD1D5DB),
          ),
        ),
      ),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────
class _AreaData {
  final String name;
  final String tagline;
  final String highlight;
  final String imageAsset;
  final Color accentColor;
  final String description;
  final List<String> features;

  const _AreaData({
    required this.name,
    required this.tagline,
    required this.highlight,
    required this.imageAsset,
    required this.accentColor,
    required this.description,
    required this.features,
  });
}

// ─── Single Carousel Page ─────────────────────────────────────────────────────
class _AreaPage extends StatelessWidget {
  final _AreaData area;
  final bool isDesktop;
  final bool isV2;

  const _AreaPage({
    required this.area,
    required this.isDesktop,
    required this.isV2,
  });

  static const _darkBg = Color(0xFF0D1F12);
  static const _green = Color(0xFF16A34A);
  static const _amber = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    const br = BorderRadius.all(Radius.circular(24));
    // Resolve accent and tagline colors per active theme
    final isYellow = context.isYellowTheme;
    final cardBorderColor = isYellow ? _amber : _green;
    final circleColor = isYellow ? _amber : _green;

    return Container(
      // 1. Shadows & Background go BEHIND the child
      decoration: BoxDecoration(
        borderRadius: br,
        color: _darkBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // 2. Border goes IN FRONT of the child (framing the image)
      foregroundDecoration: BoxDecoration(
        borderRadius: br,
        border: Border.all(
          color: cardBorderColor.withValues(alpha: 0.5),
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      // 3. Child is clipped to range
      child: ClipRRect(
        borderRadius: br,
        child: isDesktop
            ? _buildDesktop(context, circleColor)
            : _buildMobile(context),
      ),
    );
  }

  // ── Desktop: full-bleed image, dark overlay left, text on top ──
  Widget _buildDesktop(BuildContext context, Color circleColor) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Full-bleed place image
        Image.asset(
          area.imageAsset,
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
          cacheWidth: 800,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_darkBg, area.accentColor.withValues(alpha: 0.4)],
              ),
            ),
          ),
        ),

        // 2. Dark gradient overlay — left 65% dark, right fades to transparent
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.45, 0.72, 1.0],
              colors: [
                const Color(0xF0050F0A),
                const Color(0xCC0D1F12),
                const Color(0x880D1F12),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // 3. Decorative circle — top right (matching driver section style)
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor.withValues(alpha: 0.10),
              border: Border.all(
                color: circleColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          right: 80,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _amber.withValues(alpha: 0.07),
            ),
          ),
        ),

        // 4. Text content on top of overlay
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.38,
          child: _buildContent(context, true),
        ),
      ],
    );
  }

  // ── Mobile: image top half, dark overlay bottom half, text on top ──
  Widget _buildMobile(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Full-bleed image
        Image.asset(
          area.imageAsset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          cacheWidth: 500,
          errorBuilder: (_, __, ___) => Container(color: _darkBg),
        ),

        // 2. Full dark overlay (stronger on mobile for readability)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.3, 0.65, 1.0],
              colors: [
                Colors.transparent,
                const Color(0x660D1F12),
                const Color(0xCC0D1F12),
                const Color(0xF0050F0A),
              ],
            ),
          ),
        ),

        // 3. Text content pinned to bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildContent(context, false),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 16,
        vertical: isDesktop ? 40 : 12,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: isDesktop
              ? double.infinity
              : (MediaQuery.of(context).size.height * 0.5),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isDesktop
                ? MainAxisAlignment.center
                : MainAxisAlignment.end,
            children: [
              // ── "Available Now" badge ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _amber.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _amber,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Available Now',
                      style: GoogleFonts.poppins(
                        color: _amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 6),

              // ── State name ──
              Text(
                area.name,
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 42 : 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),

              // ── Tagline ──
              Text(
                area.tagline,
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 14 : 10,
                  color: _amber,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: isDesktop ? 20 : 10),

              // ── Description ──
              Text(
                area.description,
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 13.5 : 11.5,
                  color: Colors.white.withValues(alpha: 0.78),
                  height: 1.5,
                ),
                maxLines: isDesktop ? 4 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isDesktop ? 22 : 10),

              // ── Feature chips ──
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: area.features.map((f) {
                  // Feature chip colors respond to active theme
                  final isYellow = context.isYellowTheme;
                  final chipColor = isYellow ? _amber : _green;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: chipColor.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 10,
                          color: chipColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          f,
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop ? 11.5 : 9.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: isDesktop ? 20 : 10),

              // ── Cities ──
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 11,
                    color: _amber,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      area.highlight,
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 12 : 10,
                        color: Colors.white.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
