import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_widget.dart';
import 'package:taxi_demo/l10n/app_localizations.dart';
import '../forms/franchise_application_dialog.dart';
import '../forms/driver_application_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWidget.isLargeScreen(context);
    final isModern = context.isModernStyle;
    final screenHeight = MediaQuery.of(context).size.height;

    // ── Classic theme: keep the original gradient look ──
    if (!isModern) return _buildClassicHero(context, isDesktop);

    // Clamp height: desktop 800–1000, mobile uses screen height (680–850)
    final heroHeight = isDesktop
        ? screenHeight.clamp(800.0, 1000.0)
        : screenHeight.clamp(680.0, 850.0);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: heroHeight),
      child: Stack(
        fit: StackFit.loose,
        alignment: Alignment.centerLeft,
        children: [
          Positioned.fill(
            child: Image.asset(
              context.isYellowTheme
                  ? 'assets/images/cars/yellow_taxi_homescreen.webp'
                  : 'assets/images/cars/green_taxi_homescreen.webp',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              // Limit GPU decode resolution — no screen needs more than 1600px wide
              cacheWidth: 1600,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF0A1628)),
            ),
          ),

          // ── Gradient overlay: dark on left, transparent on right ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.55, 0.85, 1.0],
                  colors: [
                    Color(0xE8050F1A), // very dark left
                    Color(0xCC0A1628), // dark mid-left
                    Color(0x660A1628), // semi-transparent mid-right
                    Color(0x220A1628), // almost transparent right
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom fade to white ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 100,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white],
                ),
              ),
            ),
          ),

          // ── Content ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                  SizedBox(height: isDesktop ? 100 : 80),

                  // Small label
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildLabel(isDesktop),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 20 : 14),

                  // Main headline
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildHeadline(isDesktop),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 12 : 8),

                  // Subtext
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildSubtext(isDesktop),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 24 : 16),

                  // CTA Buttons
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildCTAButtons(isDesktop),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 30 : 20),

                  // Franchise Shortcuts
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildFranchiseShortcuts(isDesktop),
                    ),
                  ),

                  SizedBox(height: isDesktop ? 60 : 40),

                  // Stats row pinned to bottom
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildStatsRow(isDesktop),
                  ),
                  SizedBox(height: isDesktop ? 40 : 30),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildLabel(bool isDesktop) {
    final accentColor = context.isYellowTheme
        ? const Color(0xFFF59E0B)
        : const Color(0xFF4ADE80);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 28, height: 2, color: accentColor),
        const SizedBox(width: 10),
        Text(
          AppLocalizations.of(context)?.premierEVService ?? "India's Premier EV Service",
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: isDesktop ? 14 : 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.heroTitle ?? 'E-CABBZ',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isDesktop ? 64 : 38,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -1,
          ),
        ),
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 64 : 38,
              fontWeight: FontWeight.w800,
              height: 1.05,
              letterSpacing: -1,
            ),
            children: [
              TextSpan(
                text: '${AppLocalizations.of(context)?.serviceInIndia ?? 'Service in India'}',
                style: TextStyle(
                  color: context.isYellowTheme
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFF4ADE80),
                ), // light green / gold
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtext(bool isDesktop) {
    return SizedBox(
      width: isDesktop ? 440 : double.infinity,
      child: Text(
        AppLocalizations.of(context)?.heroSubtitle ??
            'Celebrating a new era of clean, comfortable, and affordable electric mobility across India.',
        style: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.75),
          fontSize: isDesktop ? 16 : 13,
          height: 1.65,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildCTAButtons(bool isDesktop) {
    final primaryBg = context.isYellowTheme
        ? const Color(0xFFF59E0B)
        : const Color(0xFF16A34A);
    final primaryFg = context.isYellowTheme ? Colors.black87 : Colors.white;
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      children: [
        // Primary pill — matches active theme
        _HoverButton(
          label: AppLocalizations.of(context)?.bookARide ?? 'Book a Ride',
          icon: Icons.arrow_forward_rounded,
          bgColor: primaryBg,
          textColor: primaryFg,
          isDesktop: isDesktop,
        ),
        // Ghost — white outline (text centred)
        _HoverButton(
          label: AppLocalizations.of(context)?.learnMore ?? 'Learn More',
          icon: null,
          bgColor: Colors.transparent,
          textColor: Colors.white,
          borderColor: Colors.white.withValues(alpha: 0.5),
          isDesktop: isDesktop,
        ),
      ],
    );
  }

  Widget _buildFranchiseShortcuts(bool isDesktop) {
    final title = AppLocalizations.of(context)?.partnerWithUs ?? 'Partner With Us';
    final green = const Color(0xFF16A34A);
    final amber = const Color(0xFFF59E0B);
    final blue = const Color(0xFF3B82F6);
    final purple = const Color(0xFF8B5CF6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: isDesktop ? 12 : 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _FranchiseButton(
              label: AppLocalizations.of(context)?.megaFranchise ?? 'Mega Franchise',
              icon: FontAwesomeIcons.buildingColumns,
              color: green,
              isDesktop: isDesktop,
              onTap: () => _openFranchiseDialog(AppLocalizations.of(context)?.megaFranchise ?? 'Mega Franchise'),
            ),
            _FranchiseButton(
              label: AppLocalizations.of(context)?.masterFranchise ?? 'Master Franchise',
              icon: FontAwesomeIcons.mapLocationDot,
              color: amber,
              isDesktop: isDesktop,
              onTap: () => _openFranchiseDialog(AppLocalizations.of(context)?.masterFranchise ?? 'Master Franchise'),
            ),
            _FranchiseButton(
              label: AppLocalizations.of(context)?.superFranchise ?? 'Super Franchise',
              icon: FontAwesomeIcons.carSide,
              color: blue,
              isDesktop: isDesktop,
              onTap: () => _openFranchiseDialog(AppLocalizations.of(context)?.superFranchise ?? 'Super Franchise'),
            ),
            _FranchiseButton(
              label: AppLocalizations.of(context)?.applyAsDriver ?? 'Apply as Driver',
              icon: FontAwesomeIcons.idCard,
              color: purple,
              isDesktop: isDesktop,
              onTap: _openDriverDialog,
            ),
          ],
        ),
      ],
    );
  }

  void _openFranchiseDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => FranchiseApplicationDialog(franchiseType: type),
    );
  }

  void _openDriverDialog() {
    showDialog(
      context: context,
      builder: (context) => const DriverApplicationDialog(),
    );
  }


  Widget _buildStatsRow(bool isDesktop) {
    final stats = [
      _StatItem(value: '1000+', label: AppLocalizations.of(context)?.happyRiders ?? 'Happy Riders'),
      _StatItem(value: '50+', label: AppLocalizations.of(context)?.evCars ?? 'EV Cars'),
      _StatItem(value: '4', label: AppLocalizations.of(context)?.states ?? 'States'),
      _StatItem(value: '24/7', label: AppLocalizations.of(context)?.service ?? 'Service'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 16,
        vertical: isDesktop ? 20 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        // frosted glass feel
      ),
      child: isDesktop
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: stats
                  .expand(
                    (s) => [
                      _buildStat(s, isDesktop),
                      if (s != stats.last)
                        Container(
                          width: 1,
                          height: 36,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                    ],
                  )
                  .toList(),
            )
          // Mobile: 2×2 grid using LayoutBuilder to fill available width
          : LayoutBuilder(
              builder: (ctx, box) {
                final itemW = (box.maxWidth - 24) / 2;
                return Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: stats
                      .map(
                        (s) => SizedBox(
                          width: itemW,
                          child: _buildStat(s, isDesktop),
                        ),
                      )
                      .toList(),
                );
              },
            ),
    );
  }

  Widget _buildStat(_StatItem stat, bool isDesktop) {
    final statColor = context.isYellowTheme
        ? const Color(0xFFF59E0B)
        : const Color(0xFF4ADE80);
    return SizedBox(
      width: isDesktop ? null : 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat.value,
            style: GoogleFonts.poppins(
              color: statColor,
              fontSize: isDesktop ? 26 : 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            stat.label,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: isDesktop ? 12 : 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CLASSIC HERO (unchanged visual language, just kept as fallback)
  // ─────────────────────────────────────────────────────────────────
  Widget _buildClassicHero(BuildContext context, bool isDesktop) {
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
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                color: AppTheme.textColor.withValues(alpha: 0.04),
              ),
            ),
          ),
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
                    Colors.transparent,
                    AppTheme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: isDesktop ? 100 : 90),
            child: isDesktop
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildClassicContent(context, true),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 5,
                          child: _buildClassicShowcase(context, true),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildClassicContent(context, false),
                        const SizedBox(height: 30),
                        _buildClassicShowcase(context, false),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassicContent(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            color: AppTheme.cardFillColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt, color: AppTheme.primaryColor, size: 16),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)?.electricFleet ?? '100% ELECTRIC FLEET',
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
        const SizedBox(height: 28),
        Text(
          AppLocalizations.of(context)?.premiumTaxiService ?? 'PREMIUM TAXI\nSERVICE IN INDIA',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: AppTheme.textColor,
            fontSize: isDesktop ? 52 : 32,
            fontWeight: FontWeight.w800,
            letterSpacing: isDesktop ? 3 : 1.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          AppLocalizations.of(context)?.classicHeroSubtitle ?? 'Experience luxury and comfort with our elite\nelectric vehicle fleet across India.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 17 : 14,
            color: AppTheme.secondaryTextColor,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
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
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)?.bookARide.toUpperCase() ?? 'BOOK A RIDE',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)?.watchDemo ?? 'Watch Demo',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassicShowcase(BuildContext context, bool isDesktop) {
    final size = isDesktop ? 380.0 : 280.0;
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
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
            Container(
              width: isDesktop ? 260 : 185,
              height: isDesktop ? 260 : 185,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.ecabbzTaxi ?? 'E-CABBZ TAXI',
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
          ],
        ),
      ),
    );
  }
}

// ─── Hover CTA Button ───
class _HoverButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final bool isDesktop;

  const _HoverButton({
    required this.label,
    this.icon,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    required this.isDesktop,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isDesktop ? 32 : 24,
            vertical: widget.isDesktop ? 16 : 13,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? (widget.bgColor == Colors.transparent
                      ? Colors.white.withValues(alpha: 0.12)
                      : widget.bgColor.withValues(alpha: 0.85))
                : widget.bgColor,
            borderRadius: BorderRadius.circular(50),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 1.5)
                : null,
            boxShadow: _hovered && widget.bgColor != Colors.transparent
                ? [
                    BoxShadow(
                      color: widget.bgColor.withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  color: widget.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: widget.isDesktop ? 15 : 13,
                  letterSpacing: 0.5,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(widget.icon, color: widget.textColor, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FranchiseButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDesktop;
  final VoidCallback onTap;

  const _FranchiseButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  State<_FranchiseButton> createState() => _FranchiseButtonState();
}

class _FranchiseButtonState extends State<_FranchiseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isDesktop ? 20 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                widget.icon,
                color: _hovered ? widget.color : Colors.white.withValues(alpha: 0.8),
                size: widget.isDesktop ? 18 : 16,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: widget.isDesktop ? 14 : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});
}

// ─── Grid Painter ───
class _GridPainter extends CustomPainter {
  final Color? color;
  _GridPainter({this.color});

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
