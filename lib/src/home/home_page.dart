import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import 'sections/hero_section.dart';
import 'sections/driver_registration.dart';
import 'sections/ev_fleet_section.dart';
import 'sections/franchise_registration.dart';
import 'sections/ev_stations_section.dart';
import 'sections/footer_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _driversKey = GlobalKey();
  final GlobalKey _franchiseKey = GlobalKey();
  final GlobalKey _evStationsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                RepaintBoundary(child: HeroSection(key: _heroKey)),
                RepaintBoundary(child: DriverRegistrationSection(key: _driversKey)),
                const RepaintBoundary(child: EVFleetSection()),
                RepaintBoundary(child: FranchiseRegistrationSection(key: _franchiseKey)),
                RepaintBoundary(child: EVStationsSection(key: _evStationsKey)),
                const RepaintBoundary(child: FooterSection()),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NavBar(
              onHomeTap: () => _scrollToSection(_heroKey),
              onDriversTap: () => _scrollToSection(_driversKey),
              onFranchiseTap: () => _scrollToSection(_franchiseKey),
              onEvStationsTap: () => _scrollToSection(_evStationsKey),
            ),
          ),
        ],
      ),
    );
  }
}
