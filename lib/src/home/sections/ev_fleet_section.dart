import 'package:flutter/material.dart';
import 'package:taxi_demo/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_widget.dart';
import '../../widgets/fade_slide_in.dart';

class EVFleetSection extends StatelessWidget {
  const EVFleetSection({super.key});

  static const List<Map<String, String>> _cars = [
    {
      'name': 'Tata Nexon EV',
      'range': '465 km',
      'power': '143 hp',
      'battery': '40.5 kWh',
      'topSpeed': '150 km/h',
      'charge': '0-80% in 56 min',
      'category': 'COMPACT SUV',
      'image': 'assets/images/cars/Nexon_ev.webp',
    },
    {
      'name': 'MG ZS EV',
      'range': '461 km',
      'power': '176 hp',
      'battery': '50.3 kWh',
      'topSpeed': '175 km/h',
      'charge': '0-80% in 42 min',
      'category': 'MID-SIZE SUV',
      'image': 'assets/images/cars/MG_ZS_ev.webp',
    },
    {
      'name': 'BYD e6',
      'range': '520 km',
      'power': '95 hp',
      'battery': '71.7 kWh',
      'topSpeed': '130 km/h',
      'charge': '0-80% in 90 min',
      'category': 'MPV',
      'image': 'assets/images/cars/BYD_e6.webp',
    },
    {
      'name': 'Hyundai Ioniq 5',
      'range': '631 km',
      'power': '325 hp',
      'battery': '72.6 kWh',
      'topSpeed': '185 km/h',
      'charge': '10-80% in 18 min',
      'category': 'PREMIUM CROSSOVER',
      'image': 'assets/images/cars/Hyundai_IONIQ5.webp',
    },
    {
      'name': 'Tata Tiago EV',
      'range': '315 km',
      'power': '74 hp',
      'battery': '24 kWh',
      'topSpeed': '120 km/h',
      'charge': '0-80% in 57 min',
      'category': 'HATCHBACK',
      'image': 'assets/images/cars/TATA_Tiago_ev.webp',
    },
    {
      'name': 'Mahindra XUV400',
      'range': '456 km',
      'power': '150 hp',
      'battery': '39.4 kWh',
      'topSpeed': '150 km/h',
      'charge': '0-80% in 50 min',
      'category': 'COMPACT SUV',
      'image': 'assets/images/cars/XUV400_ev.webp',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWidget.isLargeScreen(context);
    final isModern = context.isModernStyle;
    final green = isModern ? const Color(0xFF16A34A) : AppTheme.primaryColor;
    final yellow = const Color(0xFFF59E0B);

    return Container(
      width: double.infinity,
      color: isModern
          ? const Color(0xFFF9FAFB)
          : Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isDesktop ? 60 : 20,
      ),
      child: Column(
        children: [
          // Section header
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: context.isYellowTheme ? yellow : green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: Text(
              AppLocalizations.of(context)?.ourEVFleet ?? 'OUR EV FLEET',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: context.isYellowTheme ? yellow : green,
                letterSpacing: 3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: Text(
              AppLocalizations.of(context)?.fleetSubtitle ?? 'Premium electric vehicles powering your journey',
              style: TextStyle(
                color: isModern
                    ? const Color(0xFF6B7280)
                    : Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 60),
          // Car grid
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int crossAxisCount;
              double aspectRatio;

              if (isDesktop) {
                crossAxisCount = 3;
                aspectRatio = 0.72;
              } else if (width > 700) {
                // Tablet: 2 columns, slightly taller cards
                crossAxisCount = 2;
                aspectRatio = 0.76;
              } else if (width > 480) {
                // Large phone: 2 columns
                crossAxisCount = 2;
                aspectRatio = 0.72;
              } else {
                // Small phone: 1 column
                crossAxisCount = 1;
                aspectRatio = 1.0;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _cars.length,
                itemBuilder: (context, index) => RepaintBoundary(
                  child: FadeSlideIn(
                    // Cap delay at 800ms so last card doesn't wait 1.4s
                    delay: Duration(
                      milliseconds: (500 + (index * 100)).clamp(0, 800),
                    ),
                    child: _EVCarCard(car: _cars[index]),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EVCarCard extends StatefulWidget {
  final Map<String, String> car;
  const _EVCarCard({required this.car});

  @override
  State<_EVCarCard> createState() => _EVCarCardState();
}

class _EVCarCardState extends State<_EVCarCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isModern = context.isModernStyle;
    final isYellow = context.isYellowTheme;

    // Single source of truth: amber in Yellow Theme, green in Green Theme
    final activeColor = isYellow
        ? const Color(0xFFF59E0B)
        : (isModern ? const Color(0xFF16A34A) : AppTheme.primaryColor);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0.0, -6.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isModern ? Colors.white : AppTheme.cardFillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? activeColor.withValues(alpha: 0.5)
                : (isModern
                      ? const Color(0xFFE5E7EB)
                      : Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _buildCarVisual(isModern, activeColor, isYellow),
              ),
              Expanded(
                flex: 5,
                child: _buildDetails(isModern, activeColor, isYellow),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // activeColor = amber in Yellow Theme, green in Green Theme
  // isYellow = whether Yellow Theme is currently active
  Widget _buildCarVisual(bool isV2, Color activeColor, bool isYellow) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isV2
              ? [
                  Colors.white,
                  isYellow ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
                ]
              : [
                  Theme.of(context).cardColor,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
        ),
      ),
      child: Stack(
        children: [
          // Background glow — matches active theme color
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    activeColor.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Category badge
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isV2
                    ? (isYellow
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFF0FDF4))
                    : activeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isV2
                      ? (isYellow
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFF86EFAC))
                      : activeColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _getLocalizedCategory(context, widget.car['category']!),
                style: TextStyle(
                  color: activeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          // Car Image
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              transform: _isHovered
                  ? (Matrix4.identity()..scale(1.05))
                  : Matrix4.identity(),
              transformAlignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Image.asset(
                  widget.car['image']!,
                  fit: BoxFit.contain,
                  cacheWidth: 400,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.electric_car,
                      size: 80,
                      color: activeColor.withValues(alpha: 0.3),
                    );
                  },
                ),
              ),
            ),
          ),
          // Range badge — themed color
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt,
                    size: 14,
                    color: isYellow ? Colors.black87 : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.car['range']!,
                    style: TextStyle(
                      color: isYellow ? Colors.black87 : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(bool isV2, Color activeColor, bool isYellow) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Car name with accent bar
          Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.car['name']!,
                  style: TextStyle(
                    color: isV2
                        ? const Color(0xFF111827)
                        : Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Spec grid
          Row(
            children: [
              Expanded(
                child: _buildSpecTile(
                  Icons.flash_on,
                  AppLocalizations.of(context)?.powerLabel ?? 'Power',
                  widget.car['power']!,
                  isV2,
                  activeColor,
                  isYellow,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildSpecTile(
                  Icons.battery_charging_full,
                  AppLocalizations.of(context)?.batteryLabel ?? 'Battery',
                  widget.car['battery']!,
                  isV2,
                  activeColor,
                  isYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildSpecTile(
                  Icons.speed,
                  AppLocalizations.of(context)?.topSpeedLabel ?? 'Top Speed',
                  widget.car['topSpeed']!,
                  isV2,
                  activeColor,
                  isYellow,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildSpecTile(
                  Icons.ev_station,
                  AppLocalizations.of(context)?.chargeLabel ?? 'Charge',
                  widget.car['charge']!,
                  isV2,
                  activeColor,
                  isYellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecTile(
    IconData icon,
    String label,
    String value,
    bool isV2,
    Color activeColor,
    bool isYellow,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isV2
            ? const Color(0xFFF9FAFB)
            : Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isV2
              ? const Color(0xFFE5E7EB)
              : activeColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isV2
                  ? (isYellow
                        ? const Color(0xFFFFFBEB)
                        : const Color(0xFFF0FDF4))
                  : activeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: activeColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isV2
                        ? const Color(0xFF9CA3AF)
                        : Theme.of(context).textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.45),
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: isV2
                        ? const Color(0xFF111827)
                        : Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return category;

    switch (category) {
      case 'COMPACT SUV':
        return l10n.compactSUV;
      case 'MID-SIZE SUV':
        return l10n.midSizeSUV;
      case 'MPV':
        return l10n.mpv;
      case 'PREMIUM CROSSOVER':
        return l10n.premiumCrossover;
      case 'HATCHBACK':
        return l10n.hatchback;
      default:
        return category;
    }
  }
}
