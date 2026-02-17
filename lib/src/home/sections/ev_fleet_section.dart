import 'package:flutter/material.dart';
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
      'image': 'assets/images/cars/Nexon_ev.png',
    },
    {
      'name': 'MG ZS EV',
      'range': '461 km',
      'power': '176 hp',
      'battery': '50.3 kWh',
      'topSpeed': '175 km/h',
      'charge': '0-80% in 42 min',
      'category': 'MID-SIZE SUV',
      'image': 'assets/images/cars/MG_ZS_ev.png',
    },
    {
      'name': 'BYD e6',
      'range': '520 km',
      'power': '95 hp',
      'battery': '71.7 kWh',
      'topSpeed': '130 km/h',
      'charge': '0-80% in 90 min',
      'category': 'MPV',
      'image': 'assets/images/cars/BYD_e6.png',
    },
    {
      'name': 'Hyundai Ioniq 5',
      'range': '631 km',
      'power': '325 hp',
      'battery': '72.6 kWh',
      'topSpeed': '185 km/h',
      'charge': '10-80% in 18 min',
      'category': 'PREMIUM CROSSOVER',
      'image': 'assets/images/cars/Hyundai_IONIQ5.png',
    },
    {
      'name': 'Tata Tiago EV',
      'range': '315 km',
      'power': '74 hp',
      'battery': '24 kWh',
      'topSpeed': '120 km/h',
      'charge': '0-80% in 57 min',
      'category': 'HATCHBACK',
      'image': 'assets/images/cars/TATA_Tiago_ev.png',
    },
    {
      'name': 'Mahindra XUV400',
      'range': '456 km',
      'power': '150 hp',
      'battery': '39.4 kWh',
      'topSpeed': '150 km/h',
      'charge': '0-80% in 50 min',
      'category': 'COMPACT SUV',
      'image': 'assets/images/cars/XUV400_ev.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWidget.isLargeScreen(context);

    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isDesktop ? 60 : 20,
      ),
      child: Column(
        children: [
          // Section header with stagger
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
          const FadeSlideIn(
            delay: Duration(milliseconds: 300),
            child: Text(
              'OUR EV FLEET',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                letterSpacing: 3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Premium electric vehicles powering your journey',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 60),
          // Car grid with staggered cards
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int crossAxisCount;
              double aspectRatio;

              if (isDesktop) {
                crossAxisCount = 3;
                aspectRatio = 0.78;
              } else if (width > 500) {
                crossAxisCount = 2;
                aspectRatio = 0.72;
              } else {
                crossAxisCount = 1;
                aspectRatio = 0.82;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: _cars.length,
                itemBuilder: (context, index) => FadeSlideIn(
                  delay: Duration(milliseconds: 500 + (index * 150)),
                  child: _EVCarCard(car: _cars[index]),
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
          color: AppTheme.cardFillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? AppTheme.primaryColor.withValues(alpha: 0.4)
                : Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
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
              // Car visual area
              Expanded(
                flex: 5,
                child: _buildCarVisual(),
              ),
              // Details area
              Expanded(
                flex: 5,
                child: _buildDetails(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarVisual() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).cardColor,
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background glow
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
                    AppTheme.primaryColor.withValues(alpha: 0.1),
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
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.car['category']!,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Image.asset(
                  widget.car['image']!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.electric_car,
                      size: 80,
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    );
                  },
                ),
              ),
            ),
          ),
          // Range badge bottom-right
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    widget.car['range']!,
                    style: const TextStyle(
                      color: Colors.white,
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

  Widget _buildDetails() {
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
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.car['name']!,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 2x2 Spec Grid — intrinsic sizing, no Expanded
          Row(
            children: [
              Expanded(
                child: _buildSpecTile(
                  Icons.flash_on,
                  'Power',
                  widget.car['power']!,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildSpecTile(
                  Icons.battery_charging_full,
                  'Battery',
                  widget.car['battery']!,
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
                  'Top Speed',
                  widget.car['topSpeed']!,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildSpecTile(
                  Icons.ev_station,
                  'Charge',
                  widget.car['charge']!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 13, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.45),
                    fontSize: 9,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 11,
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
}
