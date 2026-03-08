import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_widget.dart';

// ─── Office Type Enum ─────────────────────────────────────────────────────────
enum _OfficeType { regional, state, district, zonal }

extension _OfficeTypeLabel on _OfficeType {
  String get label {
    switch (this) {
      case _OfficeType.regional:
        return 'Regional Office';
      case _OfficeType.state:
        return 'State Office';
      case _OfficeType.district:
        return 'District Office';
      case _OfficeType.zonal:
        return 'Zonal Office';
    }
  }

  IconData get icon {
    switch (this) {
      case _OfficeType.regional:
        return Icons.account_balance_rounded;
      case _OfficeType.state:
        return Icons.location_city_rounded;
      case _OfficeType.district:
        return Icons.maps_home_work_rounded;
      case _OfficeType.zonal:
        return Icons.store_rounded;
    }
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────
class _Office {
  final _OfficeType type;
  final String name;
  final String area;
  final String address;
  final String phone;
  final String email;

  const _Office({
    required this.type,
    required this.name,
    required this.area,
    required this.address,
    required this.phone,
    required this.email,
  });
}

// ─── Office Data ──────────────────────────────────────────────────────────────
const _allOffices = <_Office>[
  // Regional Offices
  _Office(
    type: _OfficeType.regional,
    name: 'South India Regional Office',
    area: 'Chennai, Tamil Nadu',
    address: '14/2, Anna Salai, 3rd Floor,\nNungambakkam, Chennai – 600 006',
    phone: '+91 44 4567 8900',
    email: 'south.regional@ecabbz.in',
  ),
  _Office(
    type: _OfficeType.regional,
    name: 'West Region Office',
    area: 'Bangalore, Karnataka',
    address: 'Unit 502, Prestige Tech Park,\nWhitefield, Bangalore – 560 066',
    phone: '+91 80 7654 3210',
    email: 'west.regional@ecabbz.in',
  ),

  // State Offices
  _Office(
    type: _OfficeType.state,
    name: 'Kerala State Office',
    area: 'Kochi, Kerala',
    address: '8th Floor, Kaloor Tower,\nMG Road, Kochi – 682 016',
    phone: '+91 484 2345 6789',
    email: 'kerala@ecabbz.in',
  ),
  _Office(
    type: _OfficeType.state,
    name: 'Tamil Nadu State Office',
    area: 'Chennai, Tamil Nadu',
    address: 'No. 5, Mount Road,\nChennai – 600 002',
    phone: '+91 44 5678 9012',
    email: 'tamilnadu@ecabbz.in',
  ),
  _Office(
    type: _OfficeType.state,
    name: 'Karnataka State Office',
    area: 'Bangalore, Karnataka',
    address: '12th Cross, Indiranagar,\nBangalore – 560 038',
    phone: '+91 80 3456 7890',
    email: 'karnataka@ecabbz.in',
  ),
  _Office(
    type: _OfficeType.state,
    name: 'Puducherry State Office',
    area: 'Pondicherry',
    address: '3A, Mission Street,\nWhite Town, Pondicherry – 605 001',
    phone: '+91 413 2345 678',
    email: 'pondicherry@ecabbz.in',
  ),

  // District Offices
  _Office(
    type: _OfficeType.district,
    name: 'Ernakulam District Office',
    area: 'Ernakulam, Kerala',
    address: 'Near Kaloor Stadium,\nErnakulam – 682 017',
    phone: '+91 484 3467 8901',
    email: 'ernakulam@ecabbz.in',
  ),
  _Office(
    type: _OfficeType.district,
    name: 'Trivandrum District Office',
    area: 'Thiruvananthapuram, Kerala',
    address: 'Pattom Palace Road,\nThiruvananthapuram – 695 004',
    phone: '+91 471 2456 789',
    email: 'trivandrum@ecabbz.in',
  ),
  _Office(
    type: _OfficeType.district,
    name: 'Coimbatore District Office',
    area: 'Coimbatore, Tamil Nadu',
    address: 'Race Course Road,\nCoimbatore – 641 018',
    phone: '+91 422 3456 789',
    email: 'coimbatore@ecabbz.in',
  ),

  // Zonal Offices
  _Office(
    type: _OfficeType.zonal,
    name: 'Kochi North Zonal Office',
    area: 'Thrissur, Kerala',
    address: 'M.G Road, Round South,\nThrissur – 680 001',
    phone: '+91 487 2345 678',
    email: 'kochi.north@ecabbz.in',
  ),
  _Office(
    type: _OfficeType.zonal,
    name: 'Chennai South Zonal Office',
    area: 'Tambaram, Tamil Nadu',
    address: 'GST Road, Near Tambaram,\nChennai – 600 045',
    phone: '+91 44 2234 5678',
    email: 'chennai.south@ecabbz.in',
  ),
  _Office(
    type: _OfficeType.zonal,
    name: 'Mysuru Zonal Office',
    area: 'Mysuru, Karnataka',
    address: 'Sayyaji Rao Road,\nMysuru – 570 001',
    phone: '+91 821 2345 678',
    email: 'mysuru@ecabbz.in',
  ),
];

// ─── Section Widget ────────────────────────────────────────────────────────────
class ContactUsSection extends StatefulWidget {
  const ContactUsSection({super.key});

  @override
  State<ContactUsSection> createState() => _ContactUsSectionState();
}

class _ContactUsSectionState extends State<ContactUsSection> {
  _OfficeType _selectedType = _OfficeType.regional;

  static const _darkBg = Color(0xFF0D1F12);
  static const _green = Color(0xFF16A34A);
  static const _amber = Color(0xFFF59E0B);
  static const _lightGreen = Color(0xFF4ADE80);

  List<_Office> get _filteredOffices =>
      _allOffices.where((o) => o.type == _selectedType).toList();

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWidget.isLargeScreen(context);
    final isTablet = ResponsiveWidget.isTabletScreen(context);
    final isV2 = context.isV2Theme;
    final green = isV2 ? _green : AppTheme.primaryColor;

    return Container(
      color: context.isYellowTheme
          ? const Color(0xFFFFFBEB)
          : const Color(0xFFF0FDF4),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 80 : 56,
        horizontal: isDesktop
            ? 80
            : isTablet
            ? 40
            : 20,
      ),
      child: Column(
        children: [
          // ── Header ──
          _buildHeader(context, isDesktop, green),
          SizedBox(height: isDesktop ? 52 : 36),

          // ── Headquarters Card ──
          _buildHQCard(context, isDesktop, isTablet, green),
          SizedBox(height: isDesktop ? 36 : 24),

          // ── Office Type Tabs ──
          _buildTypeTabs(context, green),
          SizedBox(height: isDesktop ? 24 : 16),

          // ── Offices Grid ──
          _buildOfficesGrid(context, isDesktop, isTablet, green),
          SizedBox(height: isDesktop ? 52 : 36),

          // ── Contact Row ──
          _buildContactRow(context, isDesktop, green),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop, Color green) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: (context.isYellowTheme ? _amber : _green).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (context.isYellowTheme ? _amber : _green).withValues(
                alpha: 0.25,
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
                  color: context.isYellowTheme ? _amber : _lightGreen,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'OUR OFFICES',
                style: GoogleFonts.poppins(
                  color: context.isYellowTheme ? _amber : _green,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
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
              const TextSpan(text: 'Get in '),
              TextSpan(
                text: 'Touch',
                style: TextStyle(color: context.isYellowTheme ? _amber : green),
              ),
              const TextSpan(text: ' With Us'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We are spread across South India to serve you better.\nFind your nearest office or contact us directly.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: const Color(0xFF6B7280),
            fontSize: isDesktop ? 15 : 13,
            height: 1.65,
          ),
        ),
      ],
    );
  }

  Widget _buildHQCard(
    BuildContext context,
    bool isDesktop,
    bool isTablet,
    Color green,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 40 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isYellowTheme
              ? [
                  const Color(0xFF451A03),
                  const Color(0xFF78350F),
                  const Color(0xFF92400E),
                ]
              : [_darkBg, const Color(0xFF0F2D1A), const Color(0xFF14532D)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (context.isYellowTheme ? _amber : _green).withValues(
              alpha: 0.2,
            ),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isDesktop ? _buildHQDesktop(context) : _buildHQMobile(context),
    );
  }

  Widget _buildHQDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _amber,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.business_rounded,
            color: Color(0xFF052014),
            size: 36,
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'HEADQUARTERS',
                  style: GoogleFonts.poppins(
                    color: _amber,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'E-CABBZ TAXI PRIVATE LIMITED',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'No. 21, GST Road, 5th Floor, Chromepet,\nChennai – 600 044, Tamil Nadu, India',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13.5,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        _buildHQStat(
          context,
          Icons.phone_rounded,
          '+91 44 6789 0123',
          'Main Hotline',
        ),
        const SizedBox(width: 32),
        _buildHQStat(
          context,
          Icons.email_rounded,
          'hello@ecabbz.in',
          'General Enquiry',
        ),
        const SizedBox(width: 32),
        _buildHQStat(
          context,
          Icons.access_time_filled_rounded,
          'Mon–Sat: 9 AM – 7 PM',
          'Working Hours',
        ),
      ],
    );
  }

  Widget _buildHQMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _amber,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.business_rounded,
                color: Color(0xFF052014),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'HEADQUARTERS',
                    style: GoogleFonts.poppins(
                      color: _amber,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'E-CABBZ TAXI PRIVATE LIMITED',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'No. 21, GST Road, 5th Floor, Chromepet,\nChennai – 600 044, Tamil Nadu, India',
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 13,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 24,
          runSpacing: 14,
          children: [
            _buildHQStat(
              context,
              Icons.phone_rounded,
              '+91 44 6789 0123',
              'Main Hotline',
            ),
            _buildHQStat(
              context,
              Icons.email_rounded,
              'hello@ecabbz.in',
              'General Enquiry',
            ),
            _buildHQStat(
              context,
              Icons.access_time_filled_rounded,
              'Mon–Sat: 9 AM – 7 PM',
              'Working Hours',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHQStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: context.isYellowTheme ? _amber : _lightGreen,
          size: 16,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Office Type Tab Bar ────────────────────────────────────────────────────
  Widget _buildTypeTabs(BuildContext context, Color green) {
    final accentColor = context.isYellowTheme ? _amber : green;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _OfficeType.values.map((type) {
          final isSelected = type == _selectedType;
          return GestureDetector(
            onTap: () => setState(() => _selectedType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? accentColor : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type.icon,
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type.label,
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF374151),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Offices Grid ──────────────────────────────────────────────────────────
  Widget _buildOfficesGrid(
    BuildContext context,
    bool isDesktop,
    bool isTablet,
    Color green,
  ) {
    final offices = _filteredOffices;
    if (offices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          'No offices in this category yet.',
          style: GoogleFonts.poppins(
            color: const Color(0xFF9CA3AF),
            fontSize: 14,
          ),
        ),
      );
    }

    // Mobile: single column, cards size to content
    if (!isDesktop && !isTablet) {
      return Column(
        children: offices
            .map(
              (o) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _OfficeCard(office: o, green: green),
              ),
            )
            .toList(),
      );
    }

    // Desktop / Tablet: chunked rows so cards are only as tall as needed
    final cols = isDesktop
        ? (offices.length == 1
              ? 1
              : offices.length == 2
              ? 2
              : 3)
        : 2;

    final rows = <Widget>[];
    for (int i = 0; i < offices.length; i += cols) {
      final chunk = offices.skip(i).take(cols).toList();
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int j = 0; j < chunk.length; j++) ...[
                  if (j > 0) const SizedBox(width: 16),
                  Expanded(
                    child: _OfficeCard(office: chunk[j], green: green),
                  ),
                ],
                // Fill empty slots if last row has fewer cards
                for (int k = chunk.length; k < cols; k++) ...[
                  const SizedBox(width: 16),
                  const Expanded(child: SizedBox()),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildContactRow(BuildContext context, bool isDesktop, Color green) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (context.isYellowTheme ? _amber : _green).withValues(
            alpha: 0.12,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _contactItems(context, isDesktop),
            )
          : Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: _contactItems(context, isDesktop),
            ),
    );
  }

  List<Widget> _contactItems(BuildContext context, bool isDesktop) => [
    _ContactChip(
      icon: Icons.phone_rounded,
      label: 'Call Us',
      value: '1800-XXX-XXXX',
      isDesktop: isDesktop,
    ),
    _ContactChip(
      icon: FontAwesomeIcons.envelope,
      label: 'Email Us',
      value: 'support@ecabbz.in',
      isDesktop: isDesktop,
      isFontAwesome: true,
    ),
    _ContactChip(
      icon: FontAwesomeIcons.whatsapp,
      label: 'WhatsApp',
      value: '+91 98765 43210',
      isDesktop: isDesktop,
      isFontAwesome: true,
    ),
    _ContactChip(
      icon: FontAwesomeIcons.headset,
      label: 'Live Support',
      value: 'Mon–Sat, 9 AM – 8 PM',
      isDesktop: isDesktop,
      isFontAwesome: true,
    ),
  ];
}

// ─── Office Card ──────────────────────────────────────────────────────────────
class _OfficeCard extends StatefulWidget {
  final _Office office;
  final Color green;

  const _OfficeCard({required this.office, required this.green});

  @override
  State<_OfficeCard> createState() => _OfficeCardState();
}

class _OfficeCardState extends State<_OfficeCard> {
  bool _hovered = false;

  static const _amber = Color(0xFFF59E0B);
  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    final activeColor = context.isYellowTheme ? _amber : _green;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _hovered
              ? (context.isYellowTheme
                    ? const Color(0xFFFFFBEB)
                    : const Color(0xFFF0FDF4))
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered
                ? activeColor.withValues(alpha: 0.4)
                : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Badge + Icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _hovered
                        ? activeColor
                        : activeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.office.type.icon,
                    color: _hovered ? Colors.white : activeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.office.type.label.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: activeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.office.name,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF111827),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      Text(
                        widget.office.area,
                        style: GoogleFonts.poppins(
                          color: activeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.office.address,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Container(height: 1, color: const Color(0xFFE5E7EB)),
            const SizedBox(height: 10),

            // Phone
            _iconRow(Icons.phone_rounded, widget.office.phone),
            const SizedBox(height: 6),

            // Email
            _iconRow(Icons.email_outlined, widget.office.email),
          ],
        ),
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) {
    final activeColor = context.isYellowTheme ? _amber : widget.green;
    return Row(
      children: [
        Icon(icon, size: 14, color: activeColor),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color(0xFF374151),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Contact Chip ─────────────────────────────────────────────────────────────
class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDesktop;
  final bool isFontAwesome;
  final Widget? iconWidget;

  const _ContactChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDesktop,
    this.isFontAwesome = false,
  });

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    final activeColor = context.isYellowTheme
        ? const Color(0xFFF59E0B)
        : _green;

    final resolvedIcon =
        iconWidget ??
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: activeColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: isFontAwesome
                ? FaIcon(icon, color: Colors.white, size: 20)
                : Icon(icon, color: Colors.white, size: 22),
          ),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        resolvedIcon,
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: const Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: const Color(0xFF111827),
                fontSize: isDesktop ? 13.5 : 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
