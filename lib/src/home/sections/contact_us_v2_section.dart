import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../widgets/responsive_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class OfficeRecordV2 {
  final String state;
  final String? district;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String? whatsapp;

  const OfficeRecordV2({
    required this.state,
    this.district,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    this.whatsapp,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE OFFICE DATA — 4 always-visible state offices
// ─────────────────────────────────────────────────────────────────────────────

class _StateOfficeInfo {
  final String state;
  final String displayName;
  final String company;
  final String address;
  final String email;
  final String stateCode;

  const _StateOfficeInfo({
    required this.state,
    required this.displayName,
    required this.company,
    required this.address,
    required this.email,
    required this.stateCode,
  });
}

const List<_StateOfficeInfo> kStateOffices = [
  _StateOfficeInfo(
    state: 'Kerala',
    displayName: 'KERALA STATE ADMINISTRATIVE OFFICE',
    company: 'ECABBZ TAXI PVT LTD',
    address: '40/5635, Banarjee Road,\nErnakulam – 682035.',
    email: 'KL@ECABBZ.IN',
    stateCode: 'KL',
  ),
  _StateOfficeInfo(
    state: 'Karnataka',
    displayName: 'KARNATAKA STATE ADMINISTRATIVE OFFICE',
    company: 'ECABBZ TAXI PVT LTD',
    address:
        'Arunodayam, 3rd A Cross, Mariyappa Street,\nHRBR, 2nd Stage, Kalyan Nagar,\nBENGALURU, KARNATAKA 560043',
    email: 'KA@ECABBZ.IN',
    stateCode: 'KA',
  ),
  _StateOfficeInfo(
    state: 'Tamil Nadu',
    displayName: 'TAMIL NADU STATE ADMINISTRATIVE OFFICE',
    company: 'ECABBZ TAXI PVT LTD',
    address: '2/7 W/C, Udayampalayam,\nCoimbatore – 641028.',
    email: 'TN@ECABBZ.IN',
    stateCode: 'TN',
  ),
  _StateOfficeInfo(
    state: 'Pondicherry',
    displayName: 'PONDICHERRY STATE ADMINISTRATIVE OFFICE',
    company: 'ECABBZ TAXI PVT LTD',
    address:
        'No. 12, Romain Rolland Street,\nWhite Town, Pondicherry – 605 001.',
    email: 'PY@ECABBZ.IN',
    stateCode: 'PY',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// DISTRICT DATA — All official districts, alphabetical per state
// ─────────────────────────────────────────────────────────────────────────────

const Map<String, List<String>> kDistrictsByState = {
  'Kerala': [
    'Alappuzha',
    'Ernakulam',
    'Idukki',
    'Kannur',
    'Kasaragod',
    'Kollam',
    'Kottayam',
    'Kozhikode',
    'Malappuram',
    'Palakkad',
    'Pathanamthitta',
    'Thiruvananthapuram',
    'Thrissur',
    'Wayanad',
  ],
  'Karnataka': [
    'Bagalkot',
    'Ballari',
    'Belagavi',
    'Bengaluru Rural',
    'Bengaluru Urban',
    'Bidar',
    'Chamarajanagara',
    'Chikkaballapur',
    'Chikkamagaluru',
    'Chitradurga',
    'Dakshina Kannada',
    'Davanagere',
    'Dharwad',
    'Gadag',
    'Hassan',
    'Haveri',
    'Kalaburagi',
    'Kodagu',
    'Kolar',
    'Koppal',
    'Mandya',
    'Mysuru',
    'Raichur',
    'Ramanagara',
    'Shivamogga',
    'Tumakuru',
    'Udupi',
    'Uttara Kannada',
    'Vijayapura',
    'Yadgir',
  ],
  'Tamil Nadu': [
    'Ariyalur',
    'Chennai',
    'Coimbatore',
    'Cuddalore',
    'Dharmapuri',
    'Dindigul',
    'Erode',
    'Kallakurichi',
    'Kancheepuram',
    'Kanniyakumari',
    'Karur',
    'Krishnagiri',
    'Madurai',
    'Nagapattinam',
    'Namakkal',
    'Nilgiris',
    'Perambalur',
    'Pudukkottai',
    'Ramanathapuram',
    'Ranipet',
    'Salem',
    'Sivaganga',
    'Tenkasi',
    'Thanjavur',
    'Theni',
    'Thoothukudi',
    'Tiruchirappalli',
    'Tirunelveli',
    'Tirupathur',
    'Tiruppur',
    'Tiruvallur',
    'Tiruvannamalai',
    'Tiruvarur',
    'Vellore',
    'Villupuram',
    'Virudhunagar',
  ],
  'Puducherry': ['Karaikal', 'Mahe', 'Puducherry', 'Yanam'],
};

const List<String> kStates = [
  'Kerala',
  'Karnataka',
  'Tamil Nadu',
  'Puducherry',
];

// ─────────────────────────────────────────────────────────────────────────────
// DISTRICT OFFICE DATA
// ─────────────────────────────────────────────────────────────────────────────

const List<OfficeRecordV2> kOfficeData = [
  // ── DISTRICT (Kerala) ──
  OfficeRecordV2(
    state: 'Kerala',
    district: 'Ernakulam',
    name: 'Ernakulam District Office',
    address: 'Near Kaloor Stadium,\nErnakulam – 682 017',
    phone: '+91 484 3467 8901',
    email: 'ernakulam@ecabbz.in',
    whatsapp: '+919400001001',
  ),
  OfficeRecordV2(
    state: 'Kerala',
    district: 'Thiruvananthapuram',
    name: 'Thiruvananthapuram District Office',
    address: 'Pattom Palace Road,\nThiruvananthapuram – 695 004',
    phone: '+91 471 2456 789',
    email: 'trivandrum@ecabbz.in',
    whatsapp: '+919400001002',
  ),
  OfficeRecordV2(
    state: 'Kerala',
    district: 'Thrissur',
    name: 'Thrissur District Office',
    address: 'M.G Road, Round South,\nThrissur – 680 001',
    phone: '+91 487 2345 678',
    email: 'thrissur@ecabbz.in',
    whatsapp: '+919400001003',
  ),
  OfficeRecordV2(
    state: 'Kerala',
    district: 'Kozhikode',
    name: 'Kozhikode District Office',
    address: 'Mavoor Road,\nKozhikode – 673 004',
    phone: '+91 495 2345 678',
    email: 'kozhikode@ecabbz.in',
    whatsapp: '+919400001004',
  ),

  // ── DISTRICT (Karnataka) ──
  OfficeRecordV2(
    state: 'Karnataka',
    district: 'Bengaluru Urban',
    name: 'Bengaluru Urban District Office',
    address: '12th Cross, Indiranagar,\nBangalore – 560 038',
    phone: '+91 80 3456 7890',
    email: 'bengaluru@ecabbz.in',
    whatsapp: '+919400002001',
  ),
  OfficeRecordV2(
    state: 'Karnataka',
    district: 'Mysuru',
    name: 'Mysuru District Office',
    address: 'Sayyaji Rao Road,\nMysuru – 570 001',
    phone: '+91 821 2345 678',
    email: 'mysuru@ecabbz.in',
    whatsapp: '+919400002002',
  ),

  // ── DISTRICT (Tamil Nadu) ──
  OfficeRecordV2(
    state: 'Tamil Nadu',
    district: 'Chennai',
    name: 'Chennai District Office',
    address: 'No. 5, Mount Road,\nChennai – 600 002',
    phone: '+91 44 5678 9012',
    email: 'chennai@ecabbz.in',
    whatsapp: '+919400003001',
  ),
  OfficeRecordV2(
    state: 'Tamil Nadu',
    district: 'Coimbatore',
    name: 'Coimbatore District Office',
    address: 'Race Course Road,\nCoimbatore – 641 018',
    phone: '+91 422 3456 789',
    email: 'coimbatore@ecabbz.in',
    whatsapp: '+919400003002',
  ),
  OfficeRecordV2(
    state: 'Tamil Nadu',
    district: 'Madurai',
    name: 'Madurai District Office',
    address: 'North Veli Street,\nMadurai – 625 001',
    phone: '+91 452 2345 678',
    email: 'madurai@ecabbz.in',
    whatsapp: '+919400003003',
  ),

  // ── DISTRICT (Puducherry) ──
  OfficeRecordV2(
    state: 'Puducherry',
    district: 'Puducherry',
    name: 'Puducherry District Office',
    address: '3A, Mission Street,\nWhite Town, Pondicherry – 605 001',
    phone: '+91 413 2345 678',
    email: 'pondicherry.dist@ecabbz.in',
    whatsapp: '+919400004001',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SECTION WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class ContactUsV2Section extends StatefulWidget {
  const ContactUsV2Section({super.key});

  @override
  State<ContactUsV2Section> createState() => _ContactUsV2SectionState();
}

class _ContactUsV2SectionState extends State<ContactUsV2Section> {
  // ── Selection state ──
  String? _selectedState;
  String? _selectedDistrict;

  // ── Theme constants ──
  static const _darkBg = Color(0xFF0D1F12);
  static const _green = Color(0xFF16A34A);
  static const _amber = Color(0xFFF59E0B);
  static const _lightGreen = Color(0xFF4ADE80);

  // ── Derived data ──
  OfficeRecordV2? get _resolvedOffice {
    if (_selectedState == null || _selectedDistrict == null) return null;
    return kOfficeData
        .where(
          (o) => o.state == _selectedState && o.district == _selectedDistrict,
        )
        .firstOrNull;
  }

  bool get _showResult => _selectedState != null && _selectedDistrict != null;

  bool get _showDistrictStep => _selectedState != null;

  List<String> get _availableDistricts =>
      _selectedState != null ? (kDistrictsByState[_selectedState!] ?? []) : [];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWidget.isLargeScreen(context);
    final isTablet = ResponsiveWidget.isTabletScreen(context);
    final isMobile = !isDesktop && !isTablet;
    final green = context.isV2Theme ? _green : AppTheme.primaryColor;
    final accent = context.isYellowTheme ? _amber : green;

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
          _buildHeader(isDesktop, accent),
          SizedBox(height: isDesktop ? 52 : 36),

          // HQ Card — original design, real address
          _buildHQCard(isDesktop, isTablet, accent),
          SizedBox(height: isDesktop ? 40 : 28),

          // ── State Offices (4 always-visible cards) ──
          _buildStateOfficesSection(isDesktop, isTablet, isMobile, accent),
          SizedBox(height: isDesktop ? 40 : 28),

          // ── Regional Office Finder ──
          _buildFinderCard(isMobile, isDesktop, accent),
          SizedBox(height: isDesktop ? 48 : 32),

          // ── Bottom contact strip ──
          _buildContactStrip(isDesktop, accent),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDesktop, Color accent) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'OUR OFFICES',
                style: GoogleFonts.poppins(
                  color: accent,
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
                style: TextStyle(color: accent),
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

  // ── HQ Card ───────────────────────────────────────────────────────────────
  Widget _buildHQCard(bool isDesktop, bool isTablet, Color accent) {
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
            color: accent.withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isDesktop ? _hqDesktop() : _hqMobile(),
    );
  }

  Widget _hqDesktop() {
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
                'Arunodayam, 3rd A Cross, Mariyappa Street,\nHRBR, 2nd Stage, Kalyan Nagar, BENGALURU, KARNATAKA 560043',
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
        _hqStat(Icons.phone_rounded, '+91 44 6789 0123', 'Main Hotline'),
        const SizedBox(width: 32),
        _hqStat(Icons.email_rounded, 'hello@ecabbz.in', 'General Enquiry'),
        const SizedBox(width: 32),
        _hqStat(
          Icons.access_time_filled_rounded,
          'Mon–Sat: 9 AM – 7 PM',
          'Working Hours',
        ),
      ],
    );
  }

  Widget _hqMobile() {
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Arunodayam, 3rd A Cross, Mariyappa Street,\nHRBR, 2nd Stage, Kalyan Nagar,\nBENGALURU, KARNATAKA 560043',
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 13,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
        const SizedBox(height: 18),
        Wrap(
          spacing: 24,
          runSpacing: 14,
          children: [
            _hqStat(Icons.phone_rounded, '+91 44 6789 0123', 'Main Hotline'),
            _hqStat(Icons.email_rounded, 'hello@ecabbz.in', 'General Enquiry'),
            _hqStat(
              Icons.access_time_filled_rounded,
              'Mon–Sat: 9 AM – 7 PM',
              'Working Hours',
            ),
          ],
        ),
      ],
    );
  }

  Widget _hqStat(IconData icon, String value, String label) {
    final accent = context.isYellowTheme ? _amber : _lightGreen;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accent, size: 16),
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

  // ── State Offices (4 static cards) ────────────────────────────────────────
  Widget _buildStateOfficesSection(
    bool isDesktop,
    bool isTablet,
    bool isMobile,
    Color accent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.location_city_rounded, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'State Offices',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  'Administrative offices across our operating states',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Cards grid
        if (isDesktop || isTablet)
          // 2-column layout for desktop/tablet
          _buildStateOfficesGrid(isDesktop, accent)
        else
          // Single column for mobile
          Column(
            children: kStateOffices
                .map(
                  (info) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildStateOfficeCard(info, accent, false),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildStateOfficesGrid(bool isDesktop, Color accent) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - (isDesktop ? 24.0 : 16.0)) / 2;
        return Wrap(
          spacing: isDesktop ? 24 : 16,
          runSpacing: isDesktop ? 24 : 16,
          children: kStateOffices
              .map(
                (info) => SizedBox(
                  width: cardWidth,
                  child: _buildStateOfficeCard(info, accent, isDesktop),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildStateOfficeCard(
    _StateOfficeInfo info,
    Color accent,
    bool isDesktop,
  ) {
    // State color accent
    final Color stateAccent = _stateAccentColor(info.stateCode, accent);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stateAccent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: stateAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_city_rounded,
                  color: stateAccent,
                  size: 20,
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
                        color: stateAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        info.stateCode,
                        style: GoogleFonts.poppins(
                          color: stateAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      info.state,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF111827),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: const Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 14),

          // Office title
          Text(
            info.displayName,
            style: GoogleFonts.poppins(
              color: stateAccent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            info.company,
            style: GoogleFonts.poppins(
              color: const Color(0xFF374151),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_rounded, size: 15, color: stateAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info.address,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6B7280),
                    fontSize: 12.5,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Email
          Row(
            children: [
              Icon(Icons.email_rounded, size: 15, color: stateAccent),
              const SizedBox(width: 8),
              Text(
                info.email,
                style: GoogleFonts.poppins(
                  color: stateAccent,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _stateAccentColor(String stateCode, Color defaultAccent) {
    if (context.isYellowTheme) return _amber;
    switch (stateCode) {
      case 'KL':
        return const Color(0xFF16A34A); // green
      case 'KA':
        return const Color(0xFF1D4ED8); // blue
      case 'TN':
        return const Color(0xFFDC2626); // red
      case 'PY':
        return const Color(0xFF7C3AED); // purple
      default:
        return defaultAccent;
    }
  }

  // ── Regional Office Finder ─────────────────────────────────────────────────
  Widget _buildFinderCard(bool isMobile, bool isDesktop, Color accent) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 40 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.search_rounded, color: accent, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find a Regional Office',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Select your state and district to find the nearest office',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Step 1 — State
          _buildStepLabel('1', 'Select State', true, accent),
          const SizedBox(height: 14),
          _buildStateSelector(isMobile, accent),

          // Step 2 — District
          if (_showDistrictStep) ...[
            const SizedBox(height: 28),
            _buildStepLabel(
              '2',
              'Select District (for ${_selectedState ?? ''})',
              true,
              accent,
            ),
            const SizedBox(height: 14),
            _buildDistrictSelector(accent),
          ],

          // Result
          if (_showResult) ...[
            const SizedBox(height: 32),
            _buildResultCard(accent, isMobile),
          ],
        ],
      ),
    );
  }

  Widget _buildStepLabel(String step, String label, bool active, Color accent) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? accent : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: GoogleFonts.poppins(
                color: active ? Colors.white : const Color(0xFF9CA3AF),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF374151),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStateSelector(bool isMobile, Color accent) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: kStates.map((state) {
        final isSelected = _selectedState == state;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedState = state;
              _selectedDistrict = null;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? accent : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? accent : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.25),
                        blurRadius: 10,
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
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 15,
                    color: Colors.white,
                  )
                else
                  Icon(
                    Icons.map_outlined,
                    size: 15,
                    color: const Color(0xFF6B7280),
                  ),
                const SizedBox(width: 8),
                Text(
                  state.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDistrictSelector(Color accent) {
    final districts = _availableDistricts;
    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: districts.length,
          separatorBuilder: (_, __) => Container(
            height: 1,
            color: const Color(0xFFF3F4F6),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          itemBuilder: (context, index) {
            final district = districts[index];
            final isSelected = _selectedDistrict == district;
            return InkWell(
              onTap: () => setState(() => _selectedDistrict = district),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                color: isSelected
                    ? accent.withValues(alpha: 0.08)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: isSelected ? accent : const Color(0xFFD1D5DB),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      district,
                      style: GoogleFonts.poppins(
                        color: isSelected ? accent : const Color(0xFF374151),
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, size: 16, color: accent),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Result Card ───────────────────────────────────────────────────────────
  Widget _buildResultCard(Color accent, bool isMobile) {
    final office = _resolvedOffice;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey('${_selectedState}-${_selectedDistrict}'),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: office != null
                ? [
                    accent.withValues(alpha: 0.06),
                    accent.withValues(alpha: 0.02),
                  ]
                : [const Color(0xFFFFF7ED), const Color(0xFFFFFBF5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: office != null
                ? accent.withValues(alpha: 0.2)
                : const Color(0xFFFEDE68).withValues(alpha: 0.5),
          ),
        ),
        child: office != null
            ? _buildOfficeDetails(office, accent, isMobile)
            : _buildComingSoonCard(accent, isMobile),
      ),
    );
  }

  Widget _buildOfficeDetails(
    OfficeRecordV2 office,
    Color accent,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.maps_home_work_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
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
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DISTRICT OFFICE',
                        style: GoogleFonts.poppins(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      office.name,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: accent.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 20),

          // Details grid
          isMobile
              ? Column(
                  children: [
                    _detailRow(
                      Icons.location_on_rounded,
                      'Address',
                      office.address,
                      accent,
                    ),
                    const SizedBox(height: 16),
                    _detailRow(
                      Icons.phone_rounded,
                      'Phone',
                      office.phone,
                      accent,
                    ),
                    const SizedBox(height: 16),
                    _detailRow(
                      Icons.email_rounded,
                      'Email',
                      office.email,
                      accent,
                    ),
                    if (office.whatsapp != null) ...[
                      const SizedBox(height: 16),
                      _detailRow(
                        Icons.chat_rounded,
                        'WhatsApp',
                        office.whatsapp!,
                        accent,
                      ),
                    ],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _detailRow(
                        Icons.location_on_rounded,
                        'Address',
                        office.address,
                        accent,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          _detailRow(
                            Icons.phone_rounded,
                            'Phone',
                            office.phone,
                            accent,
                          ),
                          const SizedBox(height: 14),
                          _detailRow(
                            Icons.email_rounded,
                            'Email',
                            office.email,
                            accent,
                          ),
                          if (office.whatsapp != null) ...[
                            const SizedBox(height: 14),
                            _detailRow(
                              Icons.chat_rounded,
                              'WhatsApp',
                              office.whatsapp!,
                              accent,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color accent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF111827),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoonCard(Color accent, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.construction_rounded,
              color: Color(0xFFD97706),
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Office Coming Soon',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF111827),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This location is not yet operational. Please reach us at our headquarters.',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6B7280),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _comingSoonChip(
                      Icons.phone_rounded,
                      'Call HQ',
                      '+91 44 6789 0123',
                      accent,
                    ),
                    _comingSoonChip(
                      Icons.email_rounded,
                      'Email HQ',
                      'hello@ecabbz.in',
                      accent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _comingSoonChip(
    IconData icon,
    String label,
    String value,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Contact Strip ─────────────────────────────────────────────────────────
  Widget _buildContactStrip(bool isDesktop, Color accent) {
    final items = [
      _ContactItem(
        icon: Icons.phone_rounded,
        label: 'Call Us',
        value: '1800-XXX-XXXX',
      ),
      _ContactItem(
        icon: Icons.email_rounded,
        label: 'Email Us',
        value: 'support@ecabbz.in',
      ),
      _ContactItem(
        icon: Icons.chat_rounded,
        label: 'WhatsApp',
        value: '+91 98765 43210',
      ),
      _ContactItem(
        icon: Icons.headset_mic_rounded,
        label: 'Live Support',
        value: 'Mon–Sat, 9 AM – 8 PM',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
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
              children: items
                  .map((e) => _buildContactChip(e, accent, true))
                  .toList(),
            )
          : Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: items
                  .map((e) => _buildContactChip(e, accent, false))
                  .toList(),
            ),
    );
  }

  Widget _buildContactChip(_ContactItem item, Color accent, bool isDesktop) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(item.icon, color: accent, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.label,
              style: GoogleFonts.poppins(
                color: const Color(0xFF6B7280),
                fontSize: 11,
              ),
            ),
            Text(
              item.value,
              style: GoogleFonts.poppins(
                color: const Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContactItem {
  final IconData icon;
  final String label;
  final String value;
  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
