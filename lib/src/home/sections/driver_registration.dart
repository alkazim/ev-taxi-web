import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_widget.dart';
import '../forms/driver_application_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_demo/l10n/app_localizations.dart';

class DriverRegistrationSection extends StatefulWidget {
  const DriverRegistrationSection({super.key});

  @override
  State<DriverRegistrationSection> createState() =>
      _DriverRegistrationSectionState();
}

class _DriverRegistrationSectionState extends State<DriverRegistrationSection> {
  static const _green = Color(0xFF16A34A);
  static const _darkGreen = Color(0xFF14532D);
  static const _amber = Color(0xFFF59E0B);
  static const _darkBg = Color(0xFF0D1F12);

  bool _hasExistingApplication = false;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getString('driver_id');
    if (mounted) {
      setState(() {
        _hasExistingApplication = driverId != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWidget.isLargeScreen(context);
    final isModern = context.isModernStyle;
    if (!isModern) return _buildClassic(context, isDesktop);
    return _buildV2(context, isDesktop);
  }

  // ─────────────────────────────────────────────────────────────────
  // V2 — Premium redesign
  // ─────────────────────────────────────────────────────────────────
  Widget _buildV2(BuildContext context, bool isDesktop) {
    return Container(
      color: const Color(0xFFF8FAFC),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 80 : 48,
        horizontal: isDesktop ? 80 : 20,
      ),
      child: isDesktop ? _buildDesktopV2(context) : _buildMobileV2(context),
    );
  }

  Widget _buildDesktopV2(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // LEFT — dark card with car image
        Expanded(flex: 5, child: _buildImageCard(context, true)),
        const SizedBox(width: 60),
        // RIGHT — content
        Expanded(flex: 5, child: _buildContentSide(context, true)),
      ],
    );
  }

  Widget _buildMobileV2(BuildContext context) {
    return Column(
      children: [
        _buildImageCard(context, false),
        const SizedBox(height: 40),
        _buildContentSide(context, false),
      ],
    );
  }

  // ── Dark card with car image + overlay stats ──
  Widget _buildImageCard(BuildContext context, bool isDesktop) {
    return Container(
      height: isDesktop ? 560 : 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isYellowTheme
              ? [
                  const Color(0xFF1F1B0D),
                  const Color(0xFF451A03),
                  const Color(0xFF78350F),
                ]
              : [_darkBg, const Color(0xFF0F2D1A), _darkGreen],
        ),
        boxShadow: [
          BoxShadow(
            color: (context.isYellowTheme ? _amber : _darkGreen).withValues(
              alpha: 0.35,
            ),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Decorative green circle top-right
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (context.isYellowTheme ? _amber : _green).withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _amber.withValues(alpha: 0.06),
                ),
              ),
            ),

            // Top badge
            Positioned(
              top: 28,
              left: 28,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: (context.isYellowTheme ? _amber : _green).withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (context.isYellowTheme ? _amber : _green).withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isYellowTheme
                            ? _amber
                            : const Color(0xFF4ADE80),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.nowHiring ?? 'NOW HIRING',
                      style: GoogleFonts.poppins(
                        color: context.isYellowTheme
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFF4ADE80),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Car image — centred, large
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  top: isDesktop ? 80 : 60,
                  bottom: isDesktop ? 120 : 90,
                  left: 20,
                  right: 20,
                ),
                // Using the new local asset for Driver Registration
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/cars/Driver_registration_image.webp',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    // Limit decode size for the 7MB asset
                    cacheWidth: isDesktop ? 900 : 600,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.person_pin_circle_rounded,
                        color: Colors.white24,
                        size: 80,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom frosted stats bar
            Positioned(
              left: isDesktop ? 20 : 12,
              right: isDesktop ? 20 : 12,
              bottom: isDesktop ? 24 : 16,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 20 : 12,
                  vertical: isDesktop ? 16 : 12,
                ),
                decoration: BoxDecoration(
                  color: context.isYellowTheme
                      ? _amber.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(isDesktop ? 18 : 14),
                  border: Border.all(
                    color: context.isYellowTheme
                        ? _amber.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('₹40K+', AppLocalizations.of(context)?.monthlyAvg ?? 'Monthly Avg', context, isDesktop),
                    _buildDivider(isDesktop),
                    _buildStatItem(
                      '500+',
                      AppLocalizations.of(context)?.activeDrivers ?? 'Active Drivers',
                      context,
                      isDesktop,
                    ),
                    _buildDivider(isDesktop),
                    _buildStatItem('4.8★', AppLocalizations.of(context)?.avgRating ?? 'Avg Rating', context, isDesktop),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    BuildContext context,
    bool isDesktop,
  ) {
    final isSmall = ResponsiveWidget.isSmallScreen(context);
    final statColor = context.isYellowTheme ? _amber : _green;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: statColor,
            fontSize: isDesktop ? 20 : (isSmall ? 15 : 17),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: isDesktop ? 11 : (isSmall ? 8 : 10),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDesktop) {
    return Container(
      width: 1,
      height: isDesktop ? 32 : 24,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  // ── Right content side ──
  Widget _buildContentSide(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Section label
        Row(
          children: [
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: context.isYellowTheme ? _amber : _green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)?.driverProgram ?? 'DRIVER PARTNER PROGRAM',
              style: GoogleFonts.poppins(
                color: context.isYellowTheme ? const Color(0xFFF59E0B) : _green,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        SizedBox(height: isDesktop ? 20 : 14),

        // Headline
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 44 : 30,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
              color: const Color(0xFF111827),
            ),
            children: [
              TextSpan(text: '${AppLocalizations.of(context)?.driveEarnGrow ?? 'Drive. Earn.\nGrow with us.'}'),
            ],
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),

        Text(
          AppLocalizations.of(context)?.joinNetwork ?? 'Join E-CABBZ\'s fastest-growing taxi network. Flexible hours, guaranteed income, and full support from day one.',
          style: GoogleFonts.poppins(
            color: const Color(0xFF6B7280),
            fontSize: isDesktop ? 15 : 13,
            height: 1.65,
          ),
        ),
        SizedBox(height: isDesktop ? 36 : 24),

        // Benefits grid
        _buildBenefitsGrid(isDesktop),
        SizedBox(height: isDesktop ? 40 : 28),

        // CTA row
        _buildCTARow(context, isDesktop),
      ],
    );
  }

  Widget _buildBenefitsGrid(bool isDesktop) {
    final benefits = [
      _Benefit(
        FontAwesomeIcons.wallet,
        AppLocalizations.of(context)?.weeklyPayouts ?? 'Weekly Payouts',
        AppLocalizations.of(context)?.weeklyPayoutsDesc ?? 'Get paid every week directly to your bank.',
      ),
      _Benefit(
        FontAwesomeIcons.clock,
        AppLocalizations.of(context)?.flexibleHours ?? 'Flexible Hours',
        AppLocalizations.of(context)?.flexibleHoursDesc ?? 'Work on your own schedule, any time.',
      ),
      _Benefit(
        FontAwesomeIcons.headset,
        AppLocalizations.of(context)?.support247 ?? '24/7 Support',
        AppLocalizations.of(context)?.support247Desc ?? 'Dedicated driver support team always on call.',
      ),
      _Benefit(
        FontAwesomeIcons.chargingStation,
        AppLocalizations.of(context)?.evProvided ?? 'EV Provided',
        AppLocalizations.of(context)?.evProvidedDesc ?? 'Drive a company EV or bring your own.',
      ),
    ];

    // Use LayoutBuilder so we can switch to 1-col on very narrow phones
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth < 380 ? 1 : 2;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: isDesktop ? 2.1 : (cols == 1 ? 2.7 : 1.5),
          children: benefits
              .map((b) => _BenefitCard(benefit: b, isDesktop: isDesktop))
              .toList(),
        );
      },
    );
  }

  Widget _buildCTARow(BuildContext context, bool isDesktop) {
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      children: [
        if (!_hasExistingApplication)
          _DriverApplyButton(
            isDesktop: isDesktop,
            onDialogClosed: _checkApplicationStatus,
          )
        else
          _DriverContinueButton(
            isDesktop: isDesktop,
            onDialogClosed: _checkApplicationStatus,
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CLASSIC (unchanged)
  // ─────────────────────────────────────────────────────────────────
  Widget _buildClassic(BuildContext context, bool isDesktop) {
    return Container(
      color: AppTheme.scaffoldBackgroundColor,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isDesktop ? 80 : 20,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: _buildClassicVisual(context, true)),
                const SizedBox(width: 60),
                Expanded(flex: 5, child: _buildClassicContent(context, true)),
              ],
            )
          : Column(
              children: [
                _buildClassicVisual(context, false),
                const SizedBox(height: 40),
                _buildClassicContent(context, false),
              ],
            ),
    );
  }

  Widget _buildClassicVisual(BuildContext context, bool isDesktop) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: isDesktop ? 320 : 240,
            height: isDesktop ? 320 : 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: isDesktop ? 240 : 180,
            height: isDesktop ? 240 : 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cardFillColor,
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 10 : 5),
                child: Image.asset(
                  'assets/images/cars/driver_partner.webp',
                  fit: BoxFit.contain,
                  cacheWidth: 400,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: isDesktop ? 10 : 5,
            right: isDesktop ? 10 : 5,
            child: Container(
              width: isDesktop ? 64 : 48,
              height: isDesktop ? 64 : 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                Icons.bolt,
                color: Colors.white,
                size: isDesktop ? 36 : 26,
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
      children: [
        Text(
          'JOIN AS A DRIVER',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: isDesktop ? 36 : 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
        ),
        const SizedBox(height: 14),
        Text(
          'Drive with E-CABBZ TAXI and earn more with flexible hours and guaranteed income.',
          style: TextStyle(
            color: AppTheme.secondaryTextColor,
            fontSize: isDesktop ? 16 : 14,
            height: 1.6,
          ),
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const DriverApplicationDialog(),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 36 : 28,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'APPLY NOW',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Benefit Card ───
class _Benefit {
  final IconData icon;
  final String title;
  final String desc;
  const _Benefit(this.icon, this.title, this.desc);
}

class _BenefitCard extends StatefulWidget {
  final _Benefit benefit;
  final bool isDesktop;
  const _BenefitCard({required this.benefit, required this.isDesktop});

  @override
  State<_BenefitCard> createState() => _BenefitCardState();
}

class _BenefitCardState extends State<_BenefitCard> {
  bool _hovered = false;

  static const _amber = Color(0xFFF59E0B);
  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hovered
              ? (context.isYellowTheme
                    ? const Color(0xFFFFFBEB)
                    : const Color(0xFFF0FDF4))
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? (context.isYellowTheme ? _amber : _green).withValues(
                    alpha: 0.35,
                  )
                : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color:
                        (context.isYellowTheme
                                ? _amber
                                : const Color(0xFF16A34A))
                            .withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44, // Reduced size
              height: 44, // Reduced size
              alignment: Alignment.center, // Explicitly centered
              decoration: BoxDecoration(
                color: _hovered
                    ? (context.isYellowTheme ? _amber : const Color(0xFF16A34A))
                          .withValues(alpha: 0.15)
                    : (context.isYellowTheme ? _amber : const Color(0xFF16A34A))
                          .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(
                widget.benefit.icon,
                color: context.isYellowTheme
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF16A34A),
                size: 20, // Slightly smaller for FA icons
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.benefit.title,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF111827),
                      fontSize: widget.isDesktop ? 13 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.benefit.desc,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6B7280),
                      fontSize: widget.isDesktop ? 11 : 10,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

// ─── Apply Button ───
class _DriverApplyButton extends StatefulWidget {
  final bool isDesktop;
  final VoidCallback onDialogClosed;
  const _DriverApplyButton({
    required this.isDesktop,
    required this.onDialogClosed,
  });

  @override
  State<_DriverApplyButton> createState() => _DriverApplyButtonState();
}

class _DriverApplyButtonState extends State<_DriverApplyButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isYellow = context.isYellowTheme;
    final normalColor = isYellow
        ? const Color(0xFFF59E0B)
        : const Color(0xFF16A34A);
    final hoverColor = isYellow
        ? const Color(0xFFD97706)
        : const Color(0xFF15803D);
    final fgColor = isYellow ? Colors.black87 : Colors.white;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (_) => const DriverApplicationDialog(),
        ).then((_) => widget.onDialogClosed()),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isDesktop ? 36 : 28,
            vertical: 17,
          ),
          decoration: BoxDecoration(
            color: _hovered ? hoverColor : normalColor,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: normalColor.withValues(alpha: _hovered ? 0.45 : 0.2),
                blurRadius: _hovered ? 24 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)?.applyAsDriver ?? 'Apply as Driver',
                style: GoogleFonts.poppins(
                  color: fgColor,
                  fontWeight: FontWeight.w700,
                  fontSize: widget.isDesktop ? 15 : 14,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, color: fgColor, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Continue Button ───
class _DriverContinueButton extends StatefulWidget {
  final bool isDesktop;
  final VoidCallback onDialogClosed;
  const _DriverContinueButton({
    required this.isDesktop,
    required this.onDialogClosed,
  });

  @override
  State<_DriverContinueButton> createState() => _DriverContinueButtonState();
}

class _DriverContinueButtonState extends State<_DriverContinueButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF59E0B);
    const green = Color(0xFF16A34A);
    final isYellow = context.isYellowTheme;
    final themeColor = isYellow ? amber : green;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (_) => const DriverApplicationDialog(),
        ).then((_) => widget.onDialogClosed()),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isDesktop ? 32 : 24,
            vertical: 17,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? themeColor.withValues(alpha: 0.15)
                : themeColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: themeColor.withValues(alpha: _hovered ? 0.35 : 0.2),
            ),
          ),
          child: Text(
            'Continue Application',
            style: GoogleFonts.poppins(
              color: isYellow
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF374151),
              fontWeight: FontWeight.w600,
              fontSize: widget.isDesktop ? 15 : 14,
            ),
          ),
        ),
      ),
    );
  }
}
