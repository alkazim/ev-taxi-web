import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/responsive_widget.dart';
import '../../theme/app_theme.dart';
import '../forms/franchise_application_dialog.dart';

class FranchiseRegistrationSection extends StatefulWidget {
  const FranchiseRegistrationSection({super.key});

  @override
  State<FranchiseRegistrationSection> createState() => _FranchiseRegistrationSectionState();
}

class _FranchiseRegistrationSectionState extends State<FranchiseRegistrationSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _autoSwipeTimer;
  int _currentIndex = 0;

  // Track if content should animate in
  bool _contentVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Trigger initial content animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _contentVisible = true);
    });

    // Auto-cycle tabs every 5 seconds
    _startAutoSwipe();
  }

  void _startAutoSwipe() {
    _autoSwipeTimer?.cancel();
    _autoSwipeTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        final nextIndex = (_tabController.index + 1) % 3;
        _tabController.animateTo(nextIndex);
      }
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentIndex = _tabController.index;
      _contentVisible = false;
    });
    // Re-trigger content animation on tab change
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _contentVisible = true);
    });
    // Reset auto-swipe timer on manual interaction
    _startAutoSwipe();
  }

  @override
  void dispose() {
    _autoSwipeTimer?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveWidget.isSmallScreen(context);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isMobile ? 16 : 20),
      child: Column(
        children: [
          Text(
            'FRANCHISE OPPORTUNITIES',
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Partner with the future of transportation',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              fontSize: isMobile ? 14 : 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          // Animated Tab Bar
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.35),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontSize: isMobile ? 11 : 14,
                height: 1.2,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
                fontSize: isMobile ? 11 : 14,
                height: 1.2,
              ),
              dividerColor: Colors.transparent,
              splashBorderRadius: BorderRadius.circular(8),
              tabs: [
                Tab(
                  height: isMobile ? 48 : 46,
                  child: Text(
                    isMobile ? 'MEGA\nFRANCHISE' : 'MEGA FRANCHISE',
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  height: isMobile ? 48 : 46,
                  child: Text(
                    isMobile ? 'MASTER\nFRANCHISE' : 'MASTER FRANCHISE',
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  height: isMobile ? 48 : 46,
                  child: Text(
                    isMobile ? 'SUPER\nFRANCHISE' : 'SUPER FRANCHISE',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tab progress indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 24 : 8,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: _currentIndex == index
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          // Animated Content Area - renders based on current tab index
          [
            _buildAnimatedCard(
              title: 'MEGA FRANCHISE',
              subtitle: 'STATE LEVEL OPERATIONS',
              role: 'Orchestrate the entire state\'s EV fleet and infrastructure.',
              investment: 'High Investment | High ROI',
              details: '• Manage Master Franchises\n• Infrastructure: Large Office, State HQ\n• Compliance: State-level transport liaison\n• Revenue: Share from all operations in state',
              icon: Icons.domain,
            ),
            _buildAnimatedCard(
              title: 'MASTER FRANCHISE',
              subtitle: 'DISTRICT GROUP OPERATIONS',
              role: 'Manage operations across 2-5 districts.',
              investment: 'Medium Investment',
              details: '• Manage Super Franchises\n• Infrastructure: District Office\n• Tech: Fleet Monitoring\n• Duties: Recruitment & Training',
              icon: Icons.hub,
            ),
            _buildAnimatedCard(
              title: 'SUPER FRANCHISE',
              subtitle: 'FLEET MANAGEMENT',
              role: 'Own and manage a fleet of 10-30 EV Cars.',
              investment: 'ROI: 18-25% (Est. 24-36 months)',
              details: '• Responsibilities: Driver hiring, Vehicle Maintenance (Battery/Cooling)\n• Requirements: 500-1500 sq ft Office, Parking\n• Documentation: GST, Trade License, MSME\n• Charging: Level 2/3 Chargers',
              icon: Icons.electric_car,
            ),
          ][_currentIndex],
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({
    required String title,
    required String subtitle,
    required String role,
    required String investment,
    required String details,
    required IconData icon,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _contentVisible ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        offset: _contentVisible ? Offset.zero : const Offset(0, 0.08),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.04),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with glow
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.35),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  role,
                  style: const TextStyle(fontSize: 18, color: AppTheme.primaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    details,
                    style: TextStyle(
                      height: 1.8,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  investment,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => FranchiseApplicationDialog(franchiseType: title),
                    );
                  },
                  child: Text('APPLY FOR $title'),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}
