import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../../main.dart'; // import to access useYellowTheme notifier
import 'sections/hero_section.dart';
import 'sections/driver_registration.dart';
import 'sections/ev_fleet_section.dart';
import 'sections/franchise_registration.dart';
import 'sections/ev_map_page.dart';
import 'sections/service_areas_section.dart';

import 'sections/contact_us_v2_section.dart';
import 'sections/footer_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  // Keys on the section widgets themselves (not on RepaintBoundary wrappers)
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _driversKey = GlobalKey();
  final GlobalKey _fleetsKey = GlobalKey();
  final GlobalKey _franchiseKey = GlobalKey();
  final GlobalKey _evStationsKey = GlobalKey();

  final GlobalKey _contactV2Key = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    const imagesToPrecache = [
      'assets/images/cars/hero_section_image2.webp',
      'assets/images/cars/Driver_registration_image.webp',
      'assets/images/cars/driver_partner.webp',
      'assets/images/cars/Nexon_ev.webp',
      'assets/images/cars/MG_ZS_ev.webp',
      'assets/images/cars/BYD_e6.webp',
      'assets/images/cars/Hyundai_IONIQ5.webp',
      'assets/images/cars/TATA_Tiago_ev.webp',
      'assets/images/cars/XUV400_ev.webp',
      'assets/images/places/Kerala.webp',
      'assets/images/places/Karnataka.webp',
      'assets/images/places/Tamilnadu.webp',
      'assets/images/places/Puducherry.webp',
    ];
    for (final path in imagesToPrecache) {
      precacheImage(AssetImage(path), context);
    }
  }

  /// Scrolls to the section identified by [key].
  ///
  /// Because we use [SingleChildScrollView], every section is always mounted
  /// so [GlobalKey.currentContext] is never null.
  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    final renderBox = ctx.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // localToGlobal tells us where the widget is on screen right now.
    // By adding the current scroll offset we get its absolute scroll position.
    final screenPosition = renderBox.localToGlobal(Offset.zero);
    final targetOffset = (_scrollController.offset + screenPosition.dy).clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          // SingleChildScrollView keeps ALL sections mounted at all times,
          // which guarantees GlobalKey.currentContext is always valid.
          SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RepaintBoundary(child: HeroSection(key: _heroKey)),
                const RepaintBoundary(child: ServiceAreasSection()),
                RepaintBoundary(
                  child: DriverRegistrationSection(key: _driversKey),
                ),
                RepaintBoundary(child: EVFleetSection(key: _fleetsKey)),
                RepaintBoundary(
                  child: FranchiseRegistrationSection(key: _franchiseKey),
                ),
                RepaintBoundary(child: EVMapPage(key: _evStationsKey)),
                RepaintBoundary(child: ContactUsV2Section(key: _contactV2Key)),

                const RepaintBoundary(child: FooterSection()),
              ],
            ),
          ),

          // ── Floating NavBar overlay ─────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NavBar(
              onHomeTap: () => _scrollToSection(_heroKey),
              onDriversTap: () => _scrollToSection(_driversKey),
              onFleetsTap: () => _scrollToSection(_fleetsKey),
              onFranchiseTap: () => _scrollToSection(_franchiseKey),
              onEvStationsTap: () => _scrollToSection(_evStationsKey),
              onContactTap: () => _scrollToSection(_contactV2Key),
            ),
          ),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: useYellowTheme,
        builder: (context, isYellow, _) {
          return FloatingActionButton.extended(
            onPressed: () => useYellowTheme.value = !useYellowTheme.value,
            backgroundColor: isYellow
                ? const Color(0xFF16A34A)
                : const Color(0xFFF59E0B),
            foregroundColor: isYellow ? Colors.white : Colors.black87,
            elevation: 8,
            icon: Icon(
              isYellow ? Icons.palette_outlined : Icons.brush_outlined,
            ),
            label: Text(
              isYellow ? 'Green Theme' : 'Yellow Theme',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
