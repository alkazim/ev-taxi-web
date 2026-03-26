import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi_demo/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'form_persistence_state.dart';
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
    'Proprietorship',
    'Capitalize',
    'Private Limited',
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
  String? _selectedState;
  String? _selectedDistrict;
  final _townCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _avgPopulationCtrl = TextEditingController();

  // ── Nearby Landmarks ──────────────────────────────────────────────────────
  final _policeStationCtrl = TextEditingController();
  final _policeContactCtrl = TextEditingController();
  final _railwayStationNameCtrl = TextEditingController();
  final _railwayStationKmCtrl = TextEditingController();
  final _airportNameCtrl = TextEditingController();
  final _airportKmCtrl = TextEditingController();
  final _seaportNameCtrl = TextEditingController();
  final _seaportKmCtrl = TextEditingController();
  final _metroStationNameCtrl = TextEditingController();
  final _metroStationKmCtrl = TextEditingController();
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

  final _verifiedCityCtrl = TextEditingController();
  final _verifiedDateCtrl = TextEditingController();
  bool _declarationAccepted = false;

  final List<String> _states = [
    'KERALA',
    'KARNATAKA',
    'TAMIL NADU',
    'PUDUCHERRY',
  ];
  final Map<String, List<String>> _stateDistricts = {
    'KERALA': [
      'ALAPPUZHA',
      'ERNAKULAM',
      'IDUKKI',
      'KANNUR',
      'KASARAGOD',
      'KOLLAM',
      'KOTTAYAM',
      'KOZHIKODE',
      'MALAPPURAM',
      'PALAKKAD',
      'PATHANAMTHITTA',
      'THIRUVANANTHAPURAM',
      'THRISSUR',
      'WAYANAD',
    ],
    'KARNATAKA': ['BANGALORE', 'MYSORE', 'HUBLI', 'DHARWAD', 'MANGALORE'],
    'TAMIL NADU': ['CHENNAI', 'COIMBATORE', 'MADURAI', 'TRICHY', 'SALEM'],
    'PUDUCHERRY': ['PUDUCHERRY', 'KARAIKAL', 'MAHE', 'YANAM'],
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _verifiedDateCtrl.text =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    // Restores and starts listening to changes for persistence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<FormPersistenceState>(context, listen: false);
      final data = state.franchiseData;

      if (data.isNotEmpty) {
        _fullNameCtrl.text = data['full_name'] ?? '';
        _spouseNameCtrl.text = data['spouse_name'] ?? '';
        _dobCtrl.text = data['dob'] ?? '';
        _ageCtrl.text = data['age'] ?? '';
        _companyNameCtrl.text = data['company_name'] ?? '';
        _ownershipType = data['ownership_type'];
        _mobile1Ctrl.text = data['mobile1'] ?? '';
        _mobile2Ctrl.text = data['mobile2'] ?? '';
        _emailCtrl.text = data['email'] ?? '';
        _panCtrl.text = data['pan'] ?? '';
        _aadhaarCtrl.text = data['aadhaar'] ?? '';
        _selectedState = data['state'];
        _selectedDistrict = data['district'];
        _townCtrl.text = data['town'] ?? '';
        _addressCtrl.text = data['address'] ?? '';
        _pinCtrl.text = data['pin'] ?? '';
        _avgPopulationCtrl.text = data['avg_population'] ?? '';
        _policeStationCtrl.text = data['police_station'] ?? '';
        _policeContactCtrl.text = data['police_contact'] ?? '';
        _railwayStationNameCtrl.text = data['railway_station_name'] ?? '';
        _railwayStationKmCtrl.text = data['railway_station_km'] ?? '';
        _airportNameCtrl.text = data['airport_name'] ?? '';
        _airportKmCtrl.text = data['airport_km'] ?? '';
        _seaportNameCtrl.text = data['seaport_name'] ?? '';
        _seaportKmCtrl.text = data['seaport_km'] ?? '';
        _metroStationNameCtrl.text = data['metro_station_name'] ?? '';
        _metroStationKmCtrl.text = data['metro_station_km'] ?? '';
        _expresswayNameCtrl.text = data['expressway_name'] ?? '';
        _expresswayKmCtrl.text = data['expressway_km'] ?? '';
        _nationalHwyNameCtrl.text = data['national_hwy_name'] ?? '';
        _nationalHwyKmCtrl.text = data['national_hwy_km'] ?? '';
        _stateHwyNameCtrl.text = data['state_hwy_name'] ?? '';
        _stateHwyKmCtrl.text = data['state_hwy_km'] ?? '';
        _mainRoadNameCtrl.text = data['main_road_name'] ?? '';
        _mainRoadKmCtrl.text = data['main_road_km'] ?? '';
        _townRoadNameCtrl.text = data['town_road_name'] ?? '';
        _townRoadKmCtrl.text = data['town_road_km'] ?? '';
        _corpRoadNameCtrl.text = data['corp_road_name'] ?? '';
        _corpRoadKmCtrl.text = data['corp_road_km'] ?? '';
        _taxiDriverCountCtrl.text = data['taxi_driver_count'] ?? '';
        _evChargerDetailsCtrl.text = data['ev_charger_details'] ?? '';
        _locationOverviewCtrl.text = data['location_overview'] ?? '';
        _landDetailsCtrl.text = data['land_details'] ?? '';
        _officeDetailsCtrl.text = data['office_details'] ?? '';
        _taxiExpCtrl.text = data['taxi_exp'] ?? '';
        _evSolarExpCtrl.text = data['ev_solar_exp'] ?? '';
        _verifiedCityCtrl.text = data['verified_city'] ?? '';
        // Note: verified date is intentionally reset to 'now' in initState

        _hasTaxiDatabase = data['has_taxi_database'] == 'true';
        _hasEvCharger = data['has_ev_charger'] == 'true';
        _hasLand = data['has_land'] == 'true';
        _hasOffice = data['has_office'] == 'true';
        _declarationAccepted = data['declaration_accepted'] == 'true';
        _verifiedDateCtrl.text =
            data['verified_date'] ??
            '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';

        setState(() {});
      }

      // Add listeners to all controllers
      _addListener(_fullNameCtrl, 'full_name');
      _addListener(_spouseNameCtrl, 'spouse_name');
      _addListener(_dobCtrl, 'dob');
      _addListener(_ageCtrl, 'age');
      _addListener(_companyNameCtrl, 'company_name');
      _addListener(_mobile1Ctrl, 'mobile1');
      _addListener(_mobile2Ctrl, 'mobile2');
      _addListener(_emailCtrl, 'email');
      _addListener(_panCtrl, 'pan');
      _addListener(_aadhaarCtrl, 'aadhaar');
      _addListener(_townCtrl, 'town');
      _addListener(_addressCtrl, 'address');
      _addListener(_pinCtrl, 'pin');
      _addListener(_avgPopulationCtrl, 'avg_population');
      _addListener(_policeStationCtrl, 'police_station');
      _addListener(_policeContactCtrl, 'police_contact');
      _addListener(_railwayStationNameCtrl, 'railway_station_name');
      _addListener(_railwayStationKmCtrl, 'railway_station_km');
      _addListener(_airportNameCtrl, 'airport_name');
      _addListener(_airportKmCtrl, 'airport_km');
      _addListener(_seaportNameCtrl, 'seaport_name');
      _addListener(_seaportKmCtrl, 'seaport_km');
      _addListener(_metroStationNameCtrl, 'metro_station_name');
      _addListener(_metroStationKmCtrl, 'metro_station_km');
      _addListener(_expresswayNameCtrl, 'expressway_name');
      _addListener(_expresswayKmCtrl, 'expressway_km');
      _addListener(_nationalHwyNameCtrl, 'national_hwy_name');
      _addListener(_nationalHwyKmCtrl, 'national_hwy_km');
      _addListener(_stateHwyNameCtrl, 'state_hwy_name');
      _addListener(_stateHwyKmCtrl, 'state_hwy_km');
      _addListener(_mainRoadNameCtrl, 'main_road_name');
      _addListener(_mainRoadKmCtrl, 'main_road_km');
      _addListener(_townRoadNameCtrl, 'town_road_name');
      _addListener(_townRoadKmCtrl, 'town_road_km');
      _addListener(_corpRoadNameCtrl, 'corp_road_name');
      _addListener(_corpRoadKmCtrl, 'corp_road_km');
      _addListener(_taxiDriverCountCtrl, 'taxi_driver_count');
      _addListener(_evChargerDetailsCtrl, 'ev_charger_details');
      _addListener(_locationOverviewCtrl, 'location_overview');
      _addListener(_landDetailsCtrl, 'land_details');
      _addListener(_officeDetailsCtrl, 'office_details');
      _addListener(_taxiExpCtrl, 'taxi_exp');
      _addListener(_evSolarExpCtrl, 'ev_solar_exp');
      _addListener(_verifiedCityCtrl, 'verified_city');
      _addListener(_verifiedDateCtrl, 'verified_date');
    });
  }

  void _addListener(TextEditingController ctrl, String key) {
    ctrl.addListener(() {
      if (!mounted) return;
      Provider.of<FormPersistenceState>(
        context,
        listen: false,
      ).updateFranchiseField(key, ctrl.text);
    });
  }

  void _updatePersistedField(String key, String value) {
    Provider.of<FormPersistenceState>(
      context,
      listen: false,
    ).updateFranchiseField(key, value);
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
      _townCtrl,
      _addressCtrl,
      _pinCtrl,
      _avgPopulationCtrl,
      _policeStationCtrl,
      _policeContactCtrl,
      _railwayStationNameCtrl,
      _railwayStationKmCtrl,
      _airportNameCtrl,
      _airportKmCtrl,
      _seaportNameCtrl,
      _seaportKmCtrl,
      _metroStationNameCtrl,
      _metroStationKmCtrl,
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
      lastDate: lastDate ?? now,
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
        'aadhaar': _aadhaarCtrl.text.replaceAll(' ', ''),
        'state': _selectedState,
        'district': _selectedDistrict,
        'town': _townCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'pin': _pinCtrl.text.trim(),
        'avg_population': _avgPopulationCtrl.text.trim(),
        'police_station': _policeStationCtrl.text.trim(),
        'police_contact': _policeContactCtrl.text.trim(),
        'railway_station_name': _railwayStationNameCtrl.text.trim(),
        'railway_station_km': _railwayStationKmCtrl.text.trim(),
        'airport_name': _airportNameCtrl.text.trim(),
        'airport_km': _airportKmCtrl.text.trim(),
        'seaport_name': _seaportNameCtrl.text.trim(),
        'seaport_km': _seaportKmCtrl.text.trim(),
        'metro_station_name': _metroStationNameCtrl.text.trim(),
        'metro_station_km': _metroStationKmCtrl.text.trim(),
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
        'verified_city': _verifiedCityCtrl.text.trim().toUpperCase(),
        'verified_date': _parseDateForDB(
          _verifiedDateCtrl.text.isEmpty
              ? '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}'
              : _verifiedDateCtrl.text.trim(),
        ),
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
      // Success path
      if (!mounted) return;

      // Clear persistence upon successful submission
      Provider.of<FormPersistenceState>(
        context,
        listen: false,
      ).clearFranchise();

      Navigator.pop(context);
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
    TextEditingController controller, {
    String? hint,
    bool required = true,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    int? exactLength,
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
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          textCapitalization: capitalization,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          maxLength: maxLength,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _green, width: 1.5),
            ),
            errorStyle: GoogleFonts.poppins(fontSize: 11),
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

  Widget _fieldDropdown(
    String label,
    String? value,
    List<String> options,
    void Function(String?)? onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: options
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _green, width: 1.5),
            ),
            errorStyle: GoogleFonts.poppins(fontSize: 11),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
      ],
    ),
  );

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
                            '${widget.franchiseType} ${AppLocalizations.of(context)?.application ?? 'Application'}',
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
                    _section('1. ${AppLocalizations.of(context)?.personalInfo ?? 'Personal / Owner Details'}'),
                    _field(
                      'Full Name',
                      _fullNameCtrl,
                      hint: 'e.g. RAJESH KUMAR',
                      capitalization: TextCapitalization.characters,
                      inputFormatters: [_UpperCaseTextFormatter()],
                    ),
                    _field(
                      'Spouse Name',
                      _spouseNameCtrl,
                      hint: 'e.g. SMITA KUMARI',
                      capitalization: TextCapitalization.characters,
                      inputFormatters: [_UpperCaseTextFormatter()],
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
                      inputFormatters: [_UpperCaseTextFormatter()],
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
                              onTap: () => setState(() {
                                _ownershipType = opt;
                                _updatePersistedField('ownership_type', opt);
                              }),
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
                      inputFormatters: [_UpperCaseTextFormatter()],
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
                      hint: '1234 5678 9012',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _AadhaarNumberFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Aadhaar is required';
                        final stripped = v.replaceAll(' ', '');
                        if (stripped.length != 12)
                          return 'Aadhaar must be 12 digits';
                        return null;
                      },
                    ),

                    // ╔═══════════════════════════════════════════╗
                    // ║  SECTION 4 — ADDRESS                      ║
                    // ╚═══════════════════════════════════════════╝
                    _section('4. Address'),
                    _fieldDropdown(
                      'State',
                      _selectedState,
                      _states,
                      (val) => setState(() {
                        _selectedState = val;
                        _selectedDistrict = null;
                        _updatePersistedField('state', val ?? '');
                        _updatePersistedField('district', '');
                      }),
                    ),
                    _fieldDropdown(
                      'District',
                      _selectedDistrict,
                      (_selectedState != null)
                          ? (_stateDistricts[_selectedState] ?? [])
                          : [],
                      (val) => setState(() {
                        _selectedDistrict = val;
                        _updatePersistedField('district', val ?? '');
                      }),
                    ),
                    _field(
                      'Town',
                      _townCtrl,
                      hint: 'e.g. POLLACHI',
                      capitalization: TextCapitalization.characters,
                      inputFormatters: [_UpperCaseTextFormatter()],
                    ),
                    _field(
                      'Full Address',
                      _addressCtrl,
                      hint: 'Door no., Street, Area...',
                      maxLines: 3,
                      capitalization: TextCapitalization.characters,
                      inputFormatters: [_UpperCaseTextFormatter()],
                    ),
                    _field(
                      'PIN Code',
                      _pinCtrl,
                      hint: '6-digit PIN',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 6,
                      exactLength: 6,
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
                      hint: 'e.g. 200000',
                      required: false,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    _highwayRow(
                      'Railway Station',
                      _railwayStationNameCtrl,
                      _railwayStationKmCtrl,
                      capitalization: TextCapitalization.characters,
                    ),
                    _highwayRow(
                      'Airport',
                      _airportNameCtrl,
                      _airportKmCtrl,
                      capitalization: TextCapitalization.characters,
                    ),
                    _highwayRow(
                      'Seaport',
                      _seaportNameCtrl,
                      _seaportKmCtrl,
                      capitalization: TextCapitalization.characters,
                    ),
                    _highwayRow(
                      'Metro Station',
                      _metroStationNameCtrl,
                      _metroStationKmCtrl,
                      capitalization: TextCapitalization.characters,
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
                      (v) => setState(() {
                        _hasTaxiDatabase = v;
                        _updatePersistedField(
                          'has_taxi_database',
                          v.toString(),
                        );
                      }),
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
                      (v) => setState(() {
                        _hasEvCharger = v;
                        _updatePersistedField('has_ev_charger', v.toString());
                      }),
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
                      (v) => setState(() {
                        _hasLand = v;
                        _updatePersistedField('has_land', v.toString());
                      }),
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
                      (v) => setState(() {
                        _hasOffice = v;
                        _updatePersistedField('has_office', v.toString());
                      }),
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

                    // ── Submit Button ──────────────────────────────────
                    const SizedBox(height: 16),
                    // Declaration Checkbox & Signature
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _declarationAccepted
                            ? const Color(0xFFF0FDF4)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _declarationAccepted
                      ? _darkGreen.withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                        ),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (!_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please fill all mandatory fields correctly before accepting the declaration.',
                                    ),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              setState(
                                () => _declarationAccepted =
                                    !_declarationAccepted,
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _declarationAccepted,
                                    onChanged: (v) {
                                      if (!_formKey.currentState!.validate()) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please fill all mandatory fields correctly before accepting the declaration.',
                                            ),
                                            backgroundColor: Colors.orange,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        return;
                                      }
                                      setState(() {
                                        _declarationAccepted = v ?? false;
                                        _updatePersistedField(
                                          'declaration_accepted',
                                          _declarationAccepted.toString(),
                                        );
                                      });
                                    },
                                    activeColor: _green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '" That if any of the information provided above is found to be false or incorrect, I shall be liable for legal action and my application may be rejected "',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.black87,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: _declarationAccepted
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_declarationAccepted) ...[
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'SIGNATURE',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey.shade500,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _fullNameCtrl.text.isEmpty
                                            ? '[ FULL NAME ]'
                                            : _fullNameCtrl.text.toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: _darkGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'DATE',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade500,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _verifiedDateCtrl.text.isEmpty
                                          ? DateTime.now().day
                                                    .toString()
                                                    .padLeft(2, '0') +
                                                '/' +
                                                DateTime.now().month
                                                    .toString()
                                                    .padLeft(2, '0') +
                                                '/' +
                                                DateTime.now().year.toString()
                                          : _verifiedDateCtrl.text,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (!_declarationAccepted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please accept the declaration to proceed',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
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
                                AppLocalizations.of(context)?.submitApplication ?? 'Submit Application',
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

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final uppercased = newValue.text.toUpperCase();
    final selectionOffset = newValue.selection.end.clamp(0, uppercased.length);
    return TextEditingValue(
      text: uppercased,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}

class _AadhaarNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip all non-digit characters to get raw digits only
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limit to 12 digits max
    final limitedDigits = digits.length > 12 ? digits.substring(0, 12) : digits;

    // Re-build with spaces after every 4 digits: XXXX XXXX XXXX
    final buffer = StringBuffer();
    for (int i = 0; i < limitedDigits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limitedDigits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
