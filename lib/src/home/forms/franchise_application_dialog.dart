import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firebase_service.dart';

// ─── Colour palette (consistent with driver dialog) ─────────────────────────
const _green = Color(0xFF16A34A);
const _darkGreen = Color(0xFF14532D);
const _red = Color(0xFFDC2626);

// ─── Helper for mandatory-field labels ──────────────────────────────────────
Widget _label(String text, {bool required = true}) => RichText(
  text: TextSpan(
    text: text,
    style: GoogleFonts.poppins(
      fontSize: 13,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    ),
    children: required
        ? [
            const TextSpan(
              text: ' *',
              style: TextStyle(color: _red, fontWeight: FontWeight.w700),
            ),
          ]
        : [],
  ),
);

// ─── Section header ─────────────────────────────────────────────────────────
Widget _section(String title) => Padding(
  padding: const EdgeInsets.only(top: 28, bottom: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _darkGreen,
          letterSpacing: 0.5,
        ),
      ),
      const Divider(thickness: 1.2, color: Color(0xFFDCFCE7)),
    ],
  ),
);

// ─── Main Dialog ─────────────────────────────────────────────────────────────
class FranchiseApplicationDialog extends StatefulWidget {
  final String franchiseType; // e.g. "Master Franchise"
  const FranchiseApplicationDialog({super.key, required this.franchiseType});

  @override
  State<FranchiseApplicationDialog> createState() =>
      _FranchiseApplicationDialogState();
}

class _FranchiseApplicationDialogState
    extends State<FranchiseApplicationDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ── Personal Info ─────────────────────────────────────────────────────────
  final _fullNameCtrl = TextEditingController();
  final _spouseNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  String? _ownershipType;
  static const _ownershipOptions = [
    'Individual',
    'Pvt Ltd',
    'Partnership',
    'Trust',
  ];

  // ── Contact ───────────────────────────────────────────────────────────────
  final _mobile1Ctrl = TextEditingController();
  final _mobile2Ctrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // ── Identity ──────────────────────────────────────────────────────────────
  final _panCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();

  // ── Address ───────────────────────────────────────────────────────────────
  final _stateCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _townCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _avgPopulationCtrl = TextEditingController();

  // ── Nearby Landmarks ──────────────────────────────────────────────────────
  final _policeStationCtrl = TextEditingController();
  final _policeContactCtrl = TextEditingController();
  final _railwayStationCtrl = TextEditingController();
  final _airportCtrl = TextEditingController();
  final _seaportCtrl = TextEditingController();
  final _metroStationCtrl = TextEditingController();
  // Highway — 5 types, each with a name + km controller
  final _expresswayNameCtrl = TextEditingController();
  final _expresswayKmCtrl = TextEditingController();
  final _nationalHwyNameCtrl = TextEditingController();
  final _nationalHwyKmCtrl = TextEditingController();
  final _stateHwyNameCtrl = TextEditingController();
  final _stateHwyKmCtrl = TextEditingController();
  final _mainRoadNameCtrl = TextEditingController();
  final _mainRoadKmCtrl = TextEditingController();
  final _townRoadNameCtrl = TextEditingController();
  final _townRoadKmCtrl = TextEditingController();
  final _corpRoadNameCtrl = TextEditingController();
  final _corpRoadKmCtrl = TextEditingController();

  // ── Business Profile ──────────────────────────────────────────────────────
  bool _hasTaxiDatabase = false;
  final _taxiDriverCountCtrl = TextEditingController();
  bool _hasEvCharger = false;
  final _evChargerDetailsCtrl = TextEditingController();
  final _locationOverviewCtrl = TextEditingController();

  // ── Infrastructure ────────────────────────────────────────────────────────
  bool _hasLand = false;
  final _landDetailsCtrl = TextEditingController();
  bool _hasOffice = false;
  final _officeDetailsCtrl = TextEditingController();

  // ── Experience ────────────────────────────────────────────────────────────
  final _taxiExpCtrl = TextEditingController();
  final _evSolarExpCtrl = TextEditingController();

  // ── Verification ─────────────────────────────────────────────────────────
  final _verifiedCityCtrl = TextEditingController();
  final _verifiedDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _verifiedDateCtrl.text =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  void _onDobSelected(DateTime picked) {
    final now = DateTime.now();
    int age = now.year - picked.year;
    if (now.month < picked.month ||
        (now.month == picked.month && now.day < picked.day)) {
      age--;
    }
    setState(() {
      _dobCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      _ageCtrl.text = age.toString();
    });
  }

  @override
  void dispose() {
    for (final c in [
      _fullNameCtrl,
      _spouseNameCtrl,
      _dobCtrl,
      _ageCtrl,
      _companyNameCtrl,
      _mobile1Ctrl,
      _mobile2Ctrl,
      _emailCtrl,
      _panCtrl,
      _aadhaarCtrl,
      _stateCtrl,
      _districtCtrl,
      _townCtrl,
      _addressCtrl,
      _pinCtrl,
      _avgPopulationCtrl,
      _policeStationCtrl,
      _policeContactCtrl,
      _railwayStationCtrl,
      _airportCtrl,
      _seaportCtrl,
      _metroStationCtrl,
      _expresswayNameCtrl,
      _expresswayKmCtrl,
      _nationalHwyNameCtrl,
      _nationalHwyKmCtrl,
      _stateHwyNameCtrl,
      _stateHwyKmCtrl,
      _mainRoadNameCtrl,
      _mainRoadKmCtrl,
      _townRoadNameCtrl,
      _townRoadKmCtrl,
      _corpRoadNameCtrl,
      _corpRoadKmCtrl,
      _taxiDriverCountCtrl,
      _evChargerDetailsCtrl,
      _locationOverviewCtrl,
      _landDetailsCtrl,
      _officeDetailsCtrl,
      _taxiExpCtrl,
      _evSolarExpCtrl,
      _verifiedCityCtrl,
      _verifiedDateCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Date formatter ────────────────────────────────────────────────────────
  Future<DateTime?> _selectDateReturn(
    BuildContext context, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate ?? DateTime(1970),
      lastDate: lastDate ?? DateTime(now.year + 1),
      useRootNavigator: true,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _green,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final picked = await _selectDateReturn(
      context,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        final d = picked.day.toString().padLeft(2, '0');
        final m = picked.month.toString().padLeft(2, '0');
        controller.text = '$d/$m/${picked.year}';
      });
    }
  }

  /// Converts the form's "DD/MM/YYYY" date to "YYYY-MM-DD" for Firestore DATE representation.
  String? _parseDateForDB(String raw) {
    final parts = raw.trim().split('/');
    if (parts.length != 3) return null;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  // ── Submission ────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final isMaster = widget.franchiseType == 'Master Franchise';
      final isMega = widget.franchiseType == 'Mega Franchise';

      // Build the common data payload
      final data = <String, dynamic>{
        'full_name': _fullNameCtrl.text.trim().toUpperCase(),
        'spouse_name': _spouseNameCtrl.text.trim().toUpperCase(),
        'dob': _dobCtrl.text.trim(),
        'age': int.tryParse(_ageCtrl.text.trim()) ?? 0,
        'company_name': _companyNameCtrl.text.trim().toUpperCase(),
        'ownership_type': _ownershipType,
        'mobile1': _mobile1Ctrl.text.trim(),
        'mobile2': _mobile2Ctrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'pan': _panCtrl.text.trim().toUpperCase(),
        'aadhaar': _aadhaarCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'district': _districtCtrl.text.trim(),
        'town': _townCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'pin': _pinCtrl.text.trim(),
        'avg_population': _avgPopulationCtrl.text.trim(),
        'police_station_name': _policeStationCtrl.text.trim(),
        'police_station_contact': _policeContactCtrl.text.trim(),
        'railway_station': _railwayStationCtrl.text.trim(),
        'airport': _airportCtrl.text.trim(),
        'seaport': _seaportCtrl.text.trim(),
        'metro_station': _metroStationCtrl.text.trim(),
        'expressway_name': _expresswayNameCtrl.text.trim(),
        'expressway_km': _expresswayKmCtrl.text.trim(),
        'national_hwy_name': _nationalHwyNameCtrl.text.trim(),
        'national_hwy_km': _nationalHwyKmCtrl.text.trim(),
        'state_hwy_name': _stateHwyNameCtrl.text.trim(),
        'state_hwy_km': _stateHwyKmCtrl.text.trim(),
        'main_road_name': _mainRoadNameCtrl.text.trim(),
        'main_road_km': _mainRoadKmCtrl.text.trim(),
        'town_road_name': _townRoadNameCtrl.text.trim(),
        'town_road_km': _townRoadKmCtrl.text.trim(),
        // master_franchise has corp_road_name/km columns;
        // mega_franchise & super_franchise use local_body_type/km instead.
        if (isMaster) ...{
          'corp_road_name': _corpRoadNameCtrl.text.trim(),
          'corp_road_km': _corpRoadKmCtrl.text.trim(),
        } else ...{
          'local_body_type': _corpRoadNameCtrl.text.trim(),
          'local_body_km': _corpRoadKmCtrl.text.trim(),
        },
        'has_taxi_driver_database': _hasTaxiDatabase,
        'taxi_driver_count': _taxiDriverCountCtrl.text.trim(),
        'has_ev_charging_station': _hasEvCharger,
        'ev_charging_details': _evChargerDetailsCtrl.text.trim(),
        'location_overview': _locationOverviewCtrl.text.trim(),
        'has_land': _hasLand,
        'land_details': _landDetailsCtrl.text.trim(),
        'has_office': _hasOffice,
        'office_details': _officeDetailsCtrl.text.trim(),
        'taxi_experience': _taxiExpCtrl.text.trim(),
        'ev_solar_experience': _evSolarExpCtrl.text.trim(),
        'verified_city': _verifiedCityCtrl.text.trim(),
        'verified_date': _parseDateForDB(_verifiedDateCtrl.text.trim()),
        'status': 'pending',
      };

      // Route to the correct collection
      final String code;
      if (isMaster) {
        code = await FirebaseService().insertMasterFranchise(data);
      } else if (isMega) {
        code = await FirebaseService().insertMegaFranchise(data);
      } else {
        code = await FirebaseService().insertSuperFranchise(data);
      }

      if (!mounted) return;
      _showSuccessDialog(code);
    } catch (e) {
      if (!mounted) return;
      final isAppEx = e is FirebaseAppException;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAppEx ? e.userMessage : 'Submission failed: $e'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String code) {
    final name = _fullNameCtrl.text.trim();
    final mobile = _mobile1Ctrl.text.trim();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: _green, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Application Submitted!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your ${widget.franchiseType} application has been received successfully.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      color: _darkGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mobile,
                    style: GoogleFonts.robotoMono(
                      color: _darkGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFBBF7D0)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR FRANCHISE CODE',
                              style: GoogleFonts.poppins(
                                color: _darkGreen.withValues(alpha: 0.6),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              code,
                              style: GoogleFonts.robotoMono(
                                color: _darkGreen,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Code copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: _darkGreen,
                        ),
                        tooltip: 'Copy Code',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please save this code for your reference. Our team will contact you shortly.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              'Done',
              style: GoogleFonts.poppins(
                color: _green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form field builder ────────────────────────────────────────────────────
  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    bool required = true,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    int? exactLength,
    TextCapitalization capitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: required),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          maxLength: maxLength,
          textCapitalization: capitalization,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.black26),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _green, width: 1.5),
            ),
            counterText: '',
          ),
          validator:
              validator ??
              (required
                  ? (v) {
                      if (v == null || v.trim().isEmpty) {
                        return '$label is required';
                      }
                      if (exactLength != null &&
                          v.replaceAll(' ', '').length != exactLength) {
                        return 'Must be $exactLength digits';
                      }
                      return null;
                    }
                  : null),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _yesNoTile(String question, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              question,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: _green),
          Text(
            value ? 'Yes' : 'No',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: value ? _green : Colors.black38,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// A highway row: label on the left, then [Name field | KM field] side by side.
  Widget _highwayRow(
    String label,
    TextEditingController nameCtrl,
    TextEditingController kmCtrl, {
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    final inputDecoration = InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Name field
          Expanded(
            flex: 5,
            child: TextFormField(
              controller: nameCtrl,
              textCapitalization: capitalization,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: inputDecoration.copyWith(
                hintText: 'Name / Route',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.black26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // KM field
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: kmCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: inputDecoration.copyWith(
                hintText: 'km',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.black26,
                ),
                suffixText: 'km',
                suffixStyle: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.black38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Dialog Header ──────────────────────────────────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.business_center_rounded,
                            color: _darkGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${widget.franchiseType} Application',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _darkGreen,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please fill all mandatory fields marked with *',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ╔═══════════════════════════════════════════╗
                    // ║  SECTION 1 — PERSONAL / OWNER DETAILS     ║
                    // ╚═══════════════════════════════════════════╝
                    _section('1. Personal / Owner Details'),
                    _field(
                      'Full Name',
                      _fullNameCtrl,
                      hint: 'e.g. RAJESH KUMAR',
                      capitalization: TextCapitalization.characters,
                    ),
                    _field(
                      'Spouse Name',
                      _spouseNameCtrl,
                      hint: 'e.g. SMITA KUMARI',
                      capitalization: TextCapitalization.characters,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _field(
                            'Date of Birth',
                            _dobCtrl,
                            hint: 'DD/MM/YYYY',
                            readOnly: true,
                            onTap: () async {
                              final picked = await _selectDateReturn(context);
                              if (picked != null) _onDobSelected(picked);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          child: _field(
                            'Age',
                            _ageCtrl,
                            hint: '--',
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    _field(
                      'Company Name',
                      _companyNameCtrl,
                      hint: 'Optional',
                      required: false,
                      capitalization: TextCapitalization.characters,
                    ),

                    // Ownership type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Type of Ownership'),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: _ownershipOptions.map((opt) {
                            final selected = _ownershipType == opt;
                            return GestureDetector(
                              onTap: () => setState(() => _ownershipType = opt),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? _green
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selected
                                        ? _darkGreen
                                        : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Text(
                                  opt,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: selected
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_ownershipType == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Please select ownership type',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: _red,
                              ),
                            ),
                          ),
                        const SizedBox(height: 14),
                      ],
                    ),

                    // ╔═══════════════════════════════════════════╗
                    // ║  SECTION 2 — CONTACT                      ║
                    // ╚═══════════════════════════════════════════╝
                    _section('2. Contact Information'),
                    _field(
                      'Mobile Number (1)',
                      _mobile1Ctrl,
                      hint: '10-digit mobile number',
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      exactLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    _field(
                      'Mobile Number (2)',
                      _mobile2Ctrl,
                      hint: 'Optional alternate number',
                      required: false,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      exactLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    _field(
                      'Email Address',
                      _emailCtrl,
                      hint: 'example@mail.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Email is required';
                        if (!v.contains('@') || !v.contains('.'))
                          return 'Enter a valid email';
                        return null;
                      },
                    ),

                    // ╔═══════════════════════════════════════════╗
                    // ║  SECTION 3 — IDENTITY DOCUMENTS           ║
                    // ╚═══════════════════════════════════════════╝
                    _section('3. Identity Documents'),
                    _field(
                      'PAN Card Number',
                      _panCtrl,
                      hint: 'e.g. ABCDE1234F',
                      capitalization: TextCapitalization.characters,
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          return newValue.copyWith(
                            text: newValue.text.toUpperCase(),
                          );
                        }),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'PAN is required';
                        final pan = v.trim().toUpperCase();
                        if (!RegExp(
                          r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
                        ).hasMatch(pan)) {
                          return 'Enter a valid PAN (e.g. ABCDE1234F)';
                        }
                        return null;
                      },
                    ),
                    _field(
                      'Aadhaar Card Number',
                      _aadhaarCtrl,
                      hint: 'Enter 12-digit Aadhaar number',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Aadhaar is required';
                        if (v.trim().length != 12)
                          return 'Aadhaar must be 12 digits';
                        return null;
                      },
                    ),

                    // ╔═══════════════════════════════════════════╗
                    // ║  SECTION 4 — ADDRESS                      ║
                    // ╚═══════════════════════════════════════════╝
                    _section('4. Address'),
                    _field(
                      'State',
                      _stateCtrl,
                      hint: 'e.g. TAMIL NADU',
                      capitalization: TextCapitalization.characters,
                    ),
                    _field(
                      'District',
                      _districtCtrl,
                      hint: 'e.g. COIMBATORE',
                      capitalization: TextCapitalization.characters,
                    ),
                    _field(
                      'Town',
                      _townCtrl,
                      hint: 'e.g. POLLACHI',
                      capitalization: TextCapitalization.characters,
                    ),
                    _field(
                      'Full Address',
                      _addressCtrl,
                      hint: 'Door no., Street, Area...',
                      maxLines: 3,
                    ),
                    _field(
                      'PIN Code',
                      _pinCtrl,
                      hint: '6-digit PIN',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'PIN is required';
                        if (v.trim().length != 6) return 'PIN must be 6 digits';
                        return null;
                      },
                    ),
                    _field(
                      'Average Population in Your Area',
                      _avgPopulationCtrl,
                      hint: 'e.g. 2,00,000',
                      required: false,
                    ),

                    // ╔═══════════════════════════════════════════╗
                    // ║  SECTION 5 — NEARBY LANDMARKS             ║
                    // ╚═══════════════════════════════════════════╝
                    _section('5. Nearby Landmarks & Infrastructure'),
                    _field(
                      'Nearest Police Station',
                      _policeStationCtrl,
                      hint: 'Name of police station',
                      required: false,
                      capitalization: TextCapitalization.characters,
                    ),
                    _field(
                      'Police Station Contact Number',
                      _policeContactCtrl,
                      hint: 'Contact number',
                      required: false,
                      keyboardType: TextInputType.phone,
                    ),
                    _field(
                      'Nearest Railway Station (Name & Distance)',
                      _railwayStationCtrl,
                      hint: 'e.g. Coimbatore Junction — 5 km',
                      required: false,
                    ),
                    _field(
                      'Nearest Airport (Name & Distance)',
                      _airportCtrl,
                      hint: 'e.g. Coimbatore International — 8 km',
                      required: false,
                    ),
                    _field(
                      'Nearest Seaport (Name & Distance)',
                      _seaportCtrl,
                      hint: 'e.g. Chennai Port — 500 km',
                      required: false,
                    ),
                    _field(
                      'Nearest Metro Station (Name & Distance)',
                      _metroStationCtrl,
                      hint: 'e.g. N/A or Chennai Metro — 200 km',
                      required: false,
                    ),
                    // Highway rows — name + km side by side
                    Text(
                      'Nearest Highways',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _highwayRow(
                      'Expressway',
                      _expresswayNameCtrl,
                      _expresswayKmCtrl,
                      capitalization: TextCapitalization.characters,
                    ),
                    _highwayRow(
                      'National Highway',
                      _nationalHwyNameCtrl,
                      _nationalHwyKmCtrl,
                      capitalization: TextCapitalization.characters,
                    ),
                    _highwayRow(
                      'State Highway',
                      _stateHwyNameCtrl,
                      _stateHwyKmCtrl,
                      capitalization: TextCapitalization.characters,
                    ),
                    _highwayRow(
                      'Main Central Road',
                      _mainRoadNameCtrl,
                      _mainRoadKmCtrl,
                      capitalization: TextCapitalization.characters,
                    ),
                    _highwayRow(
                      'Nearest Town',
                      _townRoadNameCtrl,
                      _townRoadKmCtrl,
                      capitalization: TextCapitalization.characters,
                    ),
                    _highwayRow(
                      'Corp/Municipality/\nPanchayath Road',
                      _corpRoadNameCtrl,
                      _corpRoadKmCtrl,
                      capitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 8),

                    // ╔═══════════════════════════════════════════╗
                    // ║  SECTION 6 — BUSINESS PROFILE             ║
                    // ╚═══════════════════════════════════════════╝
                    _section('6. Business Profile'),

                    _yesNoTile(
                      'Do you have a database of online taxi drivers?',
                      _hasTaxiDatabase,
                      (v) => setState(() => _hasTaxiDatabase = v),
                    ),
                    if (_hasTaxiDatabase)
                      _field(
                        'Number of Drivers in Database',
                        _taxiDriverCountCtrl,
                        hint: 'e.g. 50 drivers',
                        required: false,
                      ),

                    _yesNoTile(
                      'Do you own or lease an EV charging station?',
                      _hasEvCharger,
                      (v) => setState(() => _hasEvCharger = v),
                    ),
                    if (_hasEvCharger)
                      _field(
                        'EV Charging Station Details',
                        _evChargerDetailsCtrl,
                        hint:
                            'Company name, location, power in kw, no of points',
                        maxLines: 3,
                        required: false,
                      ),

                    _field(
                      'Location Overview',
                      _locationOverviewCtrl,
                      hint:
                          'Is it a pilgrimage centre, tourist destination, IT park, industrial hub or residential area?',
                      maxLines: 4,
                    ),

                    // ╔═══════════════════════════════════════════╗
                    // ║  SECTION 7 — LAND & OFFICE                ║
                    // ╚═══════════════════════════════════════════╝
                    _section('7. Land & Office Availability'),

                    _yesNoTile(
                      'Do you own or lease 30–50 cents of level land on a State/National Highway?',
                      _hasLand,
                      (v) => setState(() => _hasLand = v),
                    ),
                    if (_hasLand)
                      _field(
                        'Land Details',
                        _landDetailsCtrl,
                        hint: 'Size, highway type, location, address...',
                        maxLines: 3,
                        required: false,
                      ),

                    _yesNoTile(
                      'Do you have an office?',
                      _hasOffice,
                      (v) => setState(() => _hasOffice = v),
                    ),
                    if (_hasOffice)
                      _field(
                        'Office Details',
                        _officeDetailsCtrl,
                        hint: 'Square footage, location, address...',
                        maxLines: 3,
                        required: false,
                      ),

                    // ╔═══════════════════════════════════════════╗
                    // ║  SECTION 8 — EXPERIENCE                   ║
                    // ╚═══════════════════════════════════════════╝
                    _section('8. Past Experience'),
                    _field(
                      'Experience in Online / Private Taxi Services',
                      _taxiExpCtrl,
                      hint:
                          'Describe any prior experience in taxi or transport services...',
                      maxLines: 3,
                      required: false,
                    ),
                    _field(
                      'Experience in Solar Panel / EV Charging Services',
                      _evSolarExpCtrl,
                      hint:
                          'Describe any prior experience in solar or EV charging...',
                      maxLines: 3,
                      required: false,
                    ),

                    // ╔═══════════════════════════════════════════╗
                    // ║  SECTION 9 — VERIFICATION                 ║
                    // ╚═══════════════════════════════════════════╝
                    _section('9. Verification'),
                    _field(
                      'City / Place of Verification',
                      _verifiedCityCtrl,
                      hint: 'e.g. COIMBATORE',
                      capitalization: TextCapitalization.characters,
                    ),
                    _field(
                      'Date',
                      _verifiedDateCtrl,
                      hint: 'DD/MM/YYYY',
                      readOnly: true,
                      onTap: () => _selectDate(context, _verifiedDateCtrl),
                    ),

                    // ── Submit Button ──────────────────────────────────
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_ownershipType == null) {
                                  setState(() {});
                                  return;
                                }
                                _submit();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          shadowColor: _green.withValues(alpha: 0.4),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Submit Application',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: _green),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
