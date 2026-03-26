import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxi_demo/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'form_persistence_state.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverApplicationDialog extends StatefulWidget {
  final String? continuationId; // Pass this if opening specifically to continue
  const DriverApplicationDialog({super.key, this.continuationId});

  @override
  State<DriverApplicationDialog> createState() =>
      _DriverApplicationDialogState();
}

class _DriverApplicationDialogState extends State<DriverApplicationDialog> {
  int _currentStep = 0;
  bool _isLoading = false;
  String? _statusMessage; // shown under the spinner during long operations
  Timer? _loadingTimer;
  String? _driverId;
  bool _isContinuation = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkExistingApplication();

    // Restores and starts listening to changes for persistence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<FormPersistenceState>(context, listen: false);
      final data = state.driverData;

      if (data.isNotEmpty) {
        _firstNameController.text = data['first_name'] ?? '';
        _middleNameController.text = data['middle_name'] ?? '';
        _lastNameController.text = data['last_name'] ?? '';
        _selectedState = data['state'];
        _selectedDistrict = data['district'];
        _villageController.text = data['village'] ?? '';
        _addressController.text = data['address'] ?? '';
        _pinController.text = data['pin'] ?? '';
        _landmarkController.text = data['landmark'] ?? '';
        _mobile1Controller.text = data['mobile1'] ?? '';
        _dobController.text = data['dob'] ?? '';
        _ageController.text = data['age'] ?? '';
        _bloodGroup = data['blood_group'];
        _emailController.text = data['email'] ?? '';
        _licenseNoController.text = data['license_no'] ?? '';
        _licenseIssueDateController.text = data['license_issue_date'] ?? '';
        _licenseExpiryDateController.text = data['license_expiry_date'] ?? '';
        _mobile2Controller.text = data['mobile2'] ?? '';
        _panController.text = data['pan'] ?? '';
        _aadhaarController.text = data['aadhaar'] ?? '';
        _bank1NameController.text = data['bank1_name'] ?? '';
        _bank1AccController.text = data['bank1_acc'] ?? '';
        _bank1IfscController.text = data['bank1_ifsc'] ?? '';
        _bank2NameController.text = data['bank2_name'] ?? '';
        _bank2AccController.text = data['bank2_acc'] ?? '';
        _bank2IfscController.text = data['bank2_ifsc'] ?? '';
        _fatherNameController.text = data['father_name'] ?? '';
        _fatherMobileController.text = data['father_mobile'] ?? '';
        _motherNameController.text = data['mother_name'] ?? '';
        _motherMobileController.text = data['mother_mobile'] ?? '';
        _spouseNameController.text = data['spouse_name'] ?? '';
        _spouseMobileController.text = data['spouse_mobile'] ?? '';
        _insuranceCompanyController.text = data['insurance_company'] ?? '';
        _policyNoController.text = data['policy_no'] ?? '';
        _sumInsuredController.text = data['sum_insured'] ?? '';
        _policyEndDateController.text = data['policy_end_date'] ?? '';
        _caseDetailsController.text = data['case_details'] ?? '';

        _sslcStatus = data['sslc_status'];
        _plusTwoStatus = data['plus_two_status'];
        _degreeStatus = data['degree_status'];
        _postGradStatus = data['post_grad_status'];
        _diplomaStatus = data['diploma_status'];
        _techCourseStatus = data['tech_course_status'];

        _sslcYear = data['sslc_year'];
        _plusTwoYear = data['plus_two_year'];
        _degreeYear = data['degree_year'];
        _postGradYear = data['post_grad_year'];
        _diplomaYear = data['diploma_year'];
        _techCourseYear = data['tech_course_year'];

        _engSpeak = data['eng_speak'] == 'true';
        _engRead = data['eng_read'] == 'true';
        _engWrite = data['eng_write'] == 'true';
        _hinSpeak = data['hin_speak'] == 'true';
        _hinRead = data['hin_read'] == 'true';
        _hinWrite = data['hin_write'] == 'true';
        _malSpeak = data['mal_speak'] == 'true';
        _malRead = data['mal_read'] == 'true';
        _malWrite = data['mal_write'] == 'true';
        _kanSpeak = data['kan_speak'] == 'true';
        _kanRead = data['kan_read'] == 'true';
        _kanWrite = data['kan_write'] == 'true';
        _tamSpeak = data['tam_speak'] == 'true';
        _tamRead = data['tam_read'] == 'true';
        _tamWrite = data['tam_write'] == 'true';

        _hasInsurance = data['has_insurance'] == 'true';
        _hasPoliceCase = data['has_police_case'] == 'true';
        _declarationAccepted = data['declaration_accepted'] == 'true';
        _verifiedCityController.text = data['verified_city'] ?? '';
        _verifiedDateController.text = data['verified_date'] ?? '';

        // Restore experiences
        final expJson = data['experiences'];
        if (expJson != null && expJson.isNotEmpty) {
          try {
            final List<dynamic> decoded = jsonDecode(expJson);
            final restored = decoded.map((e) {
              final entry = _ExperienceEntry();
              entry.companyController.text = e['company'] ?? '';
              entry.joinDateController.text = e['join_date'] ?? '';
              entry.leaveDateController.text = e['leave_date'] ?? '';
              entry.reasonController.text = e['reason'] ?? '';
              _addExperienceListeners(entry);
              return entry;
            }).toList();
            _experiences.clear();
            _experiences.addAll(restored);
          } catch (e) {
            debugPrint('Error restoring experiences: $e');
          }
        }

        _currentStep = state.driverCurrentStep;

        setState(() {});
      }

      // Add listeners to all controllers
      _addListener(_firstNameController, 'first_name');
      _addListener(_middleNameController, 'middle_name');
      _addListener(_lastNameController, 'last_name');
      _addListener(_villageController, 'village');
      _addListener(_addressController, 'address');
      _addListener(_pinController, 'pin');
      _addListener(_landmarkController, 'landmark');
      _addListener(_mobile1Controller, 'mobile1');
      _addListener(_dobController, 'dob');
      _addListener(_ageController, 'age');
      _addListener(_emailController, 'email');
      _addListener(_licenseNoController, 'license_no');
      _addListener(_licenseIssueDateController, 'license_issue_date');
      _addListener(_licenseExpiryDateController, 'license_expiry_date');
      _addListener(_mobile2Controller, 'mobile2');
      _addListener(_panController, 'pan');
      _addListener(_aadhaarController, 'aadhaar');
      _addListener(_bank1NameController, 'bank1_name');
      _addListener(_bank1AccController, 'bank1_acc');
      _addListener(_bank1IfscController, 'bank1_ifsc');
      _addListener(_bank2NameController, 'bank2_name');
      _addListener(_bank2AccController, 'bank2_acc');
      _addListener(_bank2IfscController, 'bank2_ifsc');
      _addListener(_fatherNameController, 'father_name');
      _addListener(_fatherMobileController, 'father_mobile');
      _addListener(_motherNameController, 'mother_name');
      _addListener(_motherMobileController, 'mother_mobile');
      _addListener(_spouseNameController, 'spouse_name');
      _addListener(_spouseMobileController, 'spouse_mobile');
      _addListener(_insuranceCompanyController, 'insurance_company');
      _addListener(_policyNoController, 'policy_no');
      _addListener(_sumInsuredController, 'sum_insured');
      _addListener(_policyEndDateController, 'policy_end_date');
      _addListener(_caseDetailsController, 'case_details');
      _addListener(_verifiedCityController, 'verified_city');
      _addListener(_verifiedDateController, 'verified_date');
    });
  }

  void _addListener(TextEditingController ctrl, String key) {
    ctrl.addListener(() {
      if (!mounted) return;
      Provider.of<FormPersistenceState>(
        context,
        listen: false,
      ).updateDriverField(key, ctrl.text);
    });
  }

  void _updatePersistedField(String key, String value) {
    Provider.of<FormPersistenceState>(
      context,
      listen: false,
    ).updateDriverField(key, value);
  }

  void _updatePersistedStep(int step) {
    Provider.of<FormPersistenceState>(
      context,
      listen: false,
    ).setDriverStep(step);
  }

  void _saveExperiences() {
    final List<Map<String, String>> data = _experiences.map((e) {
      return {
        'company': e.companyController.text,
        'join_date': e.joinDateController.text,
        'leave_date': e.leaveDateController.text,
        'reason': e.reasonController.text,
      };
    }).toList();
    _updatePersistedField('experiences', jsonEncode(data));
  }

  void _addExperienceListeners(_ExperienceEntry entry) {
    entry.companyController.addListener(_saveExperiences);
    entry.joinDateController.addListener(_saveExperiences);
    entry.leaveDateController.addListener(_saveExperiences);
    entry.reasonController.addListener(_saveExperiences);
  }

  Future<void> _checkExistingApplication() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = widget.continuationId ?? prefs.getString('driver_id');

    if (savedId != null) {
      setState(() => _isLoading = true);
      try {
        final data = await FirebaseService().getDriverByCode(savedId);
        if (data != null) {
          setState(() {
            _driverId = savedId;
            _isContinuation = true;
            _currentStep = 1;

            _firstNameController.text = data['first_name'] ?? '';
            _middleNameController.text = data['middle_name'] ?? '';
            _lastNameController.text = data['last_name'] ?? '';
            _selectedState = data['state'];
            _selectedDistrict = data['district'];
            _villageController.text = data['village'] ?? '';
            _addressController.text = data['address'] ?? '';
            _pinController.text = data['pin'] ?? '';
            _landmarkController.text = data['landmark'] ?? '';
            _mobile1Controller.text = data['mobile1'] ?? '';
            _dobController.text = data['dob'] ?? '';
            _bloodGroup = data['blood_group'];
            _emailController.text = data['email'] ?? '';
            _licenseNoController.text = data['license_no'] ?? '';
            _licenseIssueDateController.text = data['license_issue_date'] ?? '';
            _licenseExpiryDateController.text =
                data['license_expiry_date'] ?? '';
          });
        }
      } catch (e) {
        // Silently ignore errors when loading existing draft — user can
        // still fill in the form manually.
        debugPrint('Could not load existing application: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // ─── Loading timer helpers ──────────────────────────────────────────────────

  /// Starts a timer that updates [_statusMessage] so the user knows the
  /// request is still running (instead of seeing a frozen spinner).
  void _startLoadingTimer() {
    _statusMessage = null;
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() => _statusMessage = 'Still connecting, please wait…');
      }
      // After 12 s warn about slow connection
      _loadingTimer = Timer(const Duration(seconds: 7), () {
        if (mounted && _isLoading) {
          setState(
            () => _statusMessage =
                'This is taking longer than expected.\nCheck your internet connection.',
          );
        }
      });
    });
  }

  void _stopLoadingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
    _statusMessage = null;
  }

  // ─── Error dialog ──────────────────────────────────────────────────────────

  /// Shows a clean, user-friendly error dialog. If [onRetry] is provided, a
  /// "Try Again" button will appear.
  void _showErrorDialog({
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.red,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Try Again'),
            ),
        ],
      ),
    );
  }

  // Controllers - Personal
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _selectedState;
  String? _selectedDistrict;
  final _villageController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinController = TextEditingController();
  final _landmarkController = TextEditingController();

  // Controllers - ID & Contact
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();
  final _mobile1Controller = TextEditingController();
  final _mobile2Controller = TextEditingController();
  final _emailController = TextEditingController();

  // Controllers - Bank (2 Accounts)
  final _bank1NameController = TextEditingController();
  final _bank1AccController = TextEditingController();
  final _bank1IfscController = TextEditingController();
  final _bank2NameController = TextEditingController();
  final _bank2AccController = TextEditingController();
  final _bank2IfscController = TextEditingController();

  // Controllers - Family
  final _fatherNameController = TextEditingController();
  final _fatherMobileController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _motherMobileController = TextEditingController();
  final _spouseNameController = TextEditingController();
  final _spouseMobileController = TextEditingController();

  // Controllers - Qualification
  String? _sslcStatus,
      _plusTwoStatus,
      _degreeStatus,
      _postGradStatus,
      _diplomaStatus,
      _techCourseStatus;
  String? _sslcYear,
      _plusTwoYear,
      _degreeYear,
      _postGradYear,
      _diplomaYear,
      _techCourseYear;

  final List<String> _years = List.generate(
    (DateTime.now().year - 1970) + 1,
    (index) => (1970 + index).toString(),
  ).reversed.toList();
  final List<String> _passFail = ['Pass', 'Fail'];

  // Language Proficiency
  bool _engSpeak = false, _engRead = false, _engWrite = false;
  bool _hinSpeak = false, _hinRead = false, _hinWrite = false;
  bool _malSpeak = false, _malRead = false, _malWrite = false;
  bool _kanSpeak = false, _kanRead = false, _kanWrite = false;
  bool _tamSpeak = false, _tamRead = false, _tamWrite = false;

  // Personal 2
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  String? _bloodGroup;
  final _licenseNoController = TextEditingController();
  final _licenseIssueDateController = TextEditingController();
  final _licenseExpiryDateController = TextEditingController();

  // Experience entries
  List<_ExperienceEntry> _experiences = [];

  // Insurance & Legal
  bool _hasInsurance = false;
  final _insuranceCompanyController = TextEditingController();
  final _policyNoController = TextEditingController();
  final _sumInsuredController = TextEditingController();
  final _policyEndDateController = TextEditingController();

  bool _hasPoliceCase = false;
  final _caseDetailsController = TextEditingController();
  final _verifiedCityController = TextEditingController();
  final _verifiedDateController = TextEditingController();
  bool _declarationAccepted = false;

  final List<String> _states = [
    'Kerala',
    'Karnataka',
    'Tamil Nadu',
    'Puducherry',
  ];
  final Map<String, List<String>> _stateDistricts = {
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
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Dharwad', 'Mangalore'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Trichy', 'Salem'],
    'Puducherry': ['Puducherry', 'Karaikal', 'Mahe', 'Yanam'],
  };
  final List<String> _bloodGroups = [
    'O+',
    'B+',
    'A+',
    'AB+',
    'O−',
    'B−',
    'A−',
    'AB−',
    'hh',
    'Oh',
    'Rh',
    'K−k−',
    'Di-a−b−',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    // On mobile, go near-fullscreen; on desktop, use a capped-width dialog
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : (isTablet ? 40 : 80),
        vertical: isMobile ? 16 : 40,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Scaffold(
            backgroundColor: AppTheme.cardFillColor,
            appBar: _buildAppBar(isMobile),
            body: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Step progress indicator
                  _buildProgressBar(),
                  // Form content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 16 : 28),
                      child: _buildCurrentStepContent(isMobile),
                    ),
                  ),
                  // Bottom navigation
                  _buildBottomNav(isMobile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isMobile) {
    return AppBar(
      backgroundColor: AppTheme.cardFillColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: isMobile ? 56 : 64,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Driver Application',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1} of 6',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 20,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: List.generate(6, (index) {
          final isCompleted = index < _currentStep;
          final isActive = index == _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isCompleted
                    ? AppTheme.primaryColor
                    : isActive
                    ? AppTheme.primaryColor.withValues(alpha: 0.4)
                    : AppTheme.primaryColor.withValues(alpha: 0.08),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent(bool isMobile) {
    final stepTitles = [
      'Personal Details',
      'IDs & Contact',
      'Bank & Family',
      'Qualifications & Language',
      'Professional Info',
      'Legal & Insurance',
    ];
    final stepIcons = [
      Icons.person_rounded,
      Icons.badge_rounded,
      Icons.account_balance_rounded,
      Icons.school_rounded,
      Icons.work_rounded,
      Icons.shield_rounded,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step title
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                stepIcons[_currentStep],
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                stepTitles[_currentStep],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Step content
        _buildStepContent(_currentStep, isMobile),
      ],
    );
  }

  Widget _buildStepContent(int step, bool isMobile) {
    switch (step) {
      case 0:
        return _buildPersonalStep(isMobile);
      case 1:
        return _buildIdContactStep(isMobile);
      case 2:
        return _buildBankFamilyStep(isMobile);
      case 3:
        return _buildQualificationStep(isMobile);
      case 4:
        return _buildProfessionalStep(isMobile);
      case 5:
        return _buildLegalStep(isMobile);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── STEP 1: Personal Details ─────────────────────
  Widget _buildPersonalStep(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Basic Details'),
        _responsiveRow(isMobile, [
          _buildTextField(
            _firstNameController,
            'First Name',
            icon: Icons.person_outline,
            capitalization: TextCapitalization.characters,
            inputFormatters: [_LicenseNumberFormatter()],
          ),
          _buildTextField(
            _middleNameController,
            'Middle Name',
            isRequired: false,
            capitalization: TextCapitalization.characters,
            inputFormatters: [_LicenseNumberFormatter()],
          ),
          _buildTextField(
            _lastNameController,
            'Last Name',
            isRequired: false,
            capitalization: TextCapitalization.characters,
            inputFormatters: [_LicenseNumberFormatter()],
          ),
        ]),
        _responsiveRow(isMobile, [
          _buildDropdown('State', _selectedState, _states, (v) {
            setState(() {
              _selectedState = v;
              _selectedDistrict = null; // Reset district when state changes
              _updatePersistedField('state', v ?? '');
              _updatePersistedField('district', '');
            });
          }),
          _buildDropdown(
            'District',
            _selectedDistrict,
            _selectedState != null
                ? (_stateDistricts[_selectedState] ?? [])
                : [],
            (v) {
              setState(() => _selectedDistrict = v);
              _updatePersistedField('district', v ?? '');
            },
          ),
        ]),
        _buildTextField(
          _villageController,
          'Village',
          icon: Icons.location_on_outlined,
          capitalization: TextCapitalization.characters,
          inputFormatters: [_LicenseNumberFormatter()],
        ),
        _buildTextField(
          _addressController,
          'Full Address',
          maxLines: 2,
          icon: Icons.home_outlined,
          capitalization: TextCapitalization.characters,
          inputFormatters: [_LicenseNumberFormatter()],
        ),
        _responsiveRow(isMobile, [
          _buildTextField(
            _pinController,
            'PIN Code',
            keyboardType: TextInputType.number,
            icon: Icons.pin_drop_outlined,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            exactLength: 6,
          ),
          _buildTextField(
            _landmarkController,
            'Landmark',
            isRequired: false,
            capitalization: TextCapitalization.characters,
            inputFormatters: [_LicenseNumberFormatter()],
          ),
        ]),
        _responsiveRow(isMobile, [
          _buildTextField(
            _mobile1Controller,
            'Mobile Number',
            keyboardType: TextInputType.phone,
            icon: Icons.phone_rounded,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            exactLength: 10,
          ),
        ]),
        _responsiveRow(isMobile, [
          _buildTextField(
            _dobController,
            'Date of Birth',
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: () async {
              final picked = await _selectDateReturn(
                context,
                firstDate: DateTime(1970),
                lastDate: DateTime.now(),
              );
              if (picked != null) _onDobSelected(picked);
            },
          ),
          _buildTextField(
            _ageController,
            'Age',
            icon: Icons.cake_outlined,
            readOnly: true,
            hint: '--',
          ),
          _buildDropdown('Blood Group', _bloodGroup, _bloodGroups, (v) {
            setState(() => _bloodGroup = v);
            _updatePersistedField('blood_group', v ?? '');
          }),
        ]),
        _buildTextField(
          _emailController,
          'Email Address',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(),
        ),
        _buildSectionLabel('Driving License Details'),
        _buildTextField(
          _licenseNoController,
          'License Number',
          icon: Icons.drive_eta_rounded,
          capitalization: TextCapitalization.characters,
          inputFormatters: [_LicenseNumberFormatter()],
        ),
        _responsiveRow(isMobile, [
          _buildTextField(
            _licenseIssueDateController,
            'Issue Date',
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: () async {
              final picked = await _selectDateReturn(
                context,
                firstDate: DateTime(1988),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  final d = picked.day.toString().padLeft(2, '0');
                  final m = picked.month.toString().padLeft(2, '0');
                  _licenseIssueDateController.text = '$d/$m/${picked.year}';

                  // If expiry date exists, check if it's still valid (at least 5 years after issue)
                  if (_licenseExpiryDateController.text.isNotEmpty) {
                    final currentExpiry = _parseDate(
                      _licenseExpiryDateController.text,
                    );
                    if (currentExpiry != null) {
                      final minExpiry = DateTime(
                        picked.year + 5,
                        picked.month,
                        picked.day,
                      );
                      if (currentExpiry.isBefore(minExpiry)) {
                        _licenseExpiryDateController.clear();
                      }
                    }
                  }
                });
              }
            },
          ),
          _buildTextField(
            _licenseExpiryDateController,
            'Expiry Date',
            icon: Icons.event_outlined,
            readOnly: true,
            onTap: () async {
              if (_licenseIssueDateController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select Issue Date first'),
                  ),
                );
                return;
              }
              final issueDate = _parseDate(_licenseIssueDateController.text);
              if (issueDate == null) return;

              final minExpiry = DateTime(
                issueDate.year + 5,
                issueDate.month,
                issueDate.day,
              );
              final picked = await _selectDateReturn(
                context,
                firstDate: minExpiry,
                lastDate: DateTime(DateTime.now().year + 50),
              );
              if (picked != null) {
                setState(() {
                  final d = picked.day.toString().padLeft(2, '0');
                  final m = picked.month.toString().padLeft(2, '0');
                  _licenseExpiryDateController.text = '$d/$m/${picked.year}';
                });
              }
            },
          ),
        ]),
      ],
    );
  }

  // ─── STEP 2: IDs & Contact ─────────────────────
  Widget _buildIdContactStep(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Identity Documents'),
        _responsiveRow(isMobile, [
          _buildTextField(
            _aadhaarController,
            'Aadhaar Number',
            keyboardType: TextInputType.number,
            icon: Icons.credit_card_rounded,
            maxLength: 14,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _AadhaarNumberFormatter(),
            ],
          ),
          _buildTextField(
            _panController,
            'PAN Number',
            icon: Icons.badge_outlined,
            hint: 'e.g. ABCDE1234F',
            capitalization: TextCapitalization.characters,
            inputFormatters: [_LicenseNumberFormatter()],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              final pan = v.trim().toUpperCase();
              if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan)) {
                return 'Invalid PAN format';
              }
              return null;
            },
          ),
        ]),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(),
        ),
        _buildSectionLabel('Additional Contact'),
        _responsiveRow(isMobile, [
          _buildTextField(
            _mobile2Controller,
            'Secondary Mobile',
            keyboardType: TextInputType.phone,
            isRequired: false,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            exactLength: 10,
          ),
        ]),
      ],
    );
  }

  // ─── STEP 3: Bank & Family ─────────────────────
  Widget _buildBankFamilyStep(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Primary Bank Account'),
        _buildTextField(
          _bank1NameController,
          'Bank Name',
          icon: Icons.account_balance_outlined,
        ),
        _responsiveRow(isMobile, [
          _buildTextField(
            _bank1AccController,
            'Account Number',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          _buildTextField(_bank1IfscController, 'IFSC Code'),
        ]),
        const SizedBox(height: 12),
        _buildSectionLabel('Secondary Bank Account', isOptional: true),
        _buildTextField(
          _bank2NameController,
          'Bank Name',
          isRequired: false,
          icon: Icons.account_balance_outlined,
        ),
        _responsiveRow(isMobile, [
          _buildTextField(
            _bank2AccController,
            'Account Number',
            isRequired: false,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          _buildTextField(_bank2IfscController, 'IFSC Code', isRequired: false),
        ]),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(),
        ),
        _buildSectionLabel('Family Details'),
        _responsiveRow(isMobile, [
          _buildTextField(
            _fatherNameController,
            "Father's Name",
            icon: Icons.person_outline,
          ),
          _buildTextField(
            _fatherMobileController,
            "Father's Mobile",
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            exactLength: 10,
          ),
        ]),
        _responsiveRow(isMobile, [
          _buildTextField(
            _motherNameController,
            "Mother's Name",
            icon: Icons.person_outline,
          ),
          _buildTextField(
            _motherMobileController,
            "Mother's Mobile",
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            exactLength: 10,
          ),
        ]),
        _responsiveRow(isMobile, [
          _buildTextField(
            _spouseNameController,
            "Spouse's Name",
            isRequired: false,
            icon: Icons.favorite_outline,
          ),
          _buildTextField(
            _spouseMobileController,
            "Spouse's Mobile",
            isRequired: false,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            exactLength: 10,
          ),
        ]),
      ],
    );
  }

  // ─── STEP 4: Qualifications & Language ─────────────────────
  Widget _buildQualificationStep(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Education'),
        _buildEducationLevel(
          'SSLC',
          _sslcStatus,
          _sslcYear,
          (s) => setState(() {
            _sslcStatus = s;
            _updatePersistedField('sslc_status', s ?? '');
            if (s == 'Fail') {
              _plusTwoStatus = _degreeStatus = _postGradStatus =
                  _diplomaStatus = _techCourseStatus = null;
              _plusTwoYear = _degreeYear = _postGradYear = _diplomaYear =
                  _techCourseYear = null;
              // Clear dependent fields in persistence
              _updatePersistedField('plus_two_status', '');
              _updatePersistedField('degree_status', '');
              _updatePersistedField('post_grad_status', '');
              _updatePersistedField('diploma_status', '');
              _updatePersistedField('tech_course_status', '');
            }
          }),
          (y) => setState(() {
            _sslcYear = y;
            _updatePersistedField('sslc_year', y ?? '');
          }),
          isMobile,
        ),
        if (_sslcStatus == 'Pass') ...[
          _buildEducationLevel(
            '+2',
            _plusTwoStatus,
            _plusTwoYear,
            (s) => setState(() {
              _plusTwoStatus = s;
              _updatePersistedField('plus_two_status', s ?? '');
            }),
            (y) => setState(() {
              _plusTwoYear = y;
              _updatePersistedField('plus_two_year', y ?? '');
            }),
            isMobile,
          ),
          _buildEducationLevel(
            'Graduation',
            _degreeStatus,
            _degreeYear,
            (s) => setState(() {
              _degreeStatus = s;
              _updatePersistedField('degree_status', s ?? '');
            }),
            (y) => setState(() {
              _degreeYear = y;
              _updatePersistedField('degree_year', y ?? '');
            }),
            isMobile,
          ),
          _buildEducationLevel(
            'Post Graduation',
            _postGradStatus,
            _postGradYear,
            (s) => setState(() {
              _postGradStatus = s;
              _updatePersistedField('post_grad_status', s ?? '');
            }),
            (y) => setState(() {
              _postGradYear = y;
              _updatePersistedField('post_grad_year', y ?? '');
            }),
            isMobile,
          ),
          _buildEducationLevel(
            'Diploma',
            _diplomaStatus,
            _diplomaYear,
            (s) => setState(() {
              _diplomaStatus = s;
              _updatePersistedField('diploma_status', s ?? '');
            }),
            (y) => setState(() {
              _diplomaYear = y;
              _updatePersistedField('diploma_year', y ?? '');
            }),
            isMobile,
          ),
          _buildEducationLevel(
            'Technical Course',
            _techCourseStatus,
            _techCourseYear,
            (s) => setState(() {
              _techCourseStatus = s;
              _updatePersistedField('tech_course_status', s ?? '');
            }),
            (y) => setState(() {
              _techCourseYear = y;
              _updatePersistedField('tech_course_year', y ?? '');
            }),
            isMobile,
          ),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(),
        ),
        _buildSectionLabel('Language Proficiency'),
        const SizedBox(height: 8),
        // Language header
        _buildLanguageHeader(isMobile),
        const SizedBox(height: 4),
        _buildLanguageRow(
          'English',
          _engSpeak,
          _engRead,
          _engWrite,
          (s, r, w) => setState(() {
            _engSpeak = s;
            _engRead = r;
            _engWrite = w;
            _updatePersistedField('eng_speak', s.toString());
            _updatePersistedField('eng_read', r.toString());
            _updatePersistedField('eng_write', w.toString());
          }),
          isMobile,
        ),
        _buildLanguageRow(
          'Hindi',
          _hinSpeak,
          _hinRead,
          _hinWrite,
          (s, r, w) => setState(() {
            _hinSpeak = s;
            _hinRead = r;
            _hinWrite = w;
            _updatePersistedField('hin_speak', s.toString());
            _updatePersistedField('hin_read', r.toString());
            _updatePersistedField('hin_write', w.toString());
          }),
          isMobile,
        ),
        _buildLanguageRow(
          'Malayalam',
          _malSpeak,
          _malRead,
          _malWrite,
          (s, r, w) => setState(() {
            _malSpeak = s;
            _malRead = r;
            _malWrite = w;
            _updatePersistedField('mal_speak', s.toString());
            _updatePersistedField('mal_read', r.toString());
            _updatePersistedField('mal_write', w.toString());
          }),
          isMobile,
        ),
        _buildLanguageRow(
          'Kannada',
          _kanSpeak,
          _kanRead,
          _kanWrite,
          (s, r, w) => setState(() {
            _kanSpeak = s;
            _kanRead = r;
            _kanWrite = w;
            _updatePersistedField('kan_speak', s.toString());
            _updatePersistedField('kan_read', r.toString());
            _updatePersistedField('kan_write', w.toString());
          }),
          isMobile,
        ),
        _buildLanguageRow(
          'Tamil',
          _tamSpeak,
          _tamRead,
          _tamWrite,
          (s, r, w) => setState(() {
            _tamSpeak = s;
            _tamRead = r;
            _tamWrite = w;
            _updatePersistedField('tam_speak', s.toString());
            _updatePersistedField('tam_read', r.toString());
            _updatePersistedField('tam_write', w.toString());
          }),
          isMobile,
        ),
      ],
    );
  }

  // ─── STEP 5: Previous Experience ─────────────────────
  Widget _buildProfessionalStep(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel('Previous Experience', isOptional: true),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  final entry = _ExperienceEntry();
                  _experiences.add(entry);
                  _addExperienceListeners(entry);
                  _saveExperiences();
                });
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Experience'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        if (_experiences.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.work_history_outlined,
                    size: 48,
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No experience added yet',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          _buildExperienceTable(isMobile),
      ],
    );
  }

  // ─── STEP 6: Legal & Insurance ─────────────────────
  Widget _buildLegalStep(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Medical Insurance'),
        _buildSwitchCard(
          'Do you have Medical Insurance?',
          _hasInsurance,
          Icons.health_and_safety_rounded,
          (v) => setState(() {
            _hasInsurance = v;
            _updatePersistedField('has_insurance', v.toString());
          }),
        ),
        if (_hasInsurance) ...[
          const SizedBox(height: 8),
          _buildTextField(
            _insuranceCompanyController,
            'Insurance Company',
            icon: Icons.business_outlined,
          ),
          _buildTextField(_policyNoController, 'Policy Number'),
          _responsiveRow(isMobile, [
            _buildTextField(
              _sumInsuredController,
              'Sum Insured (₹)',
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              _policyEndDateController,
              'Policy End Date',
              icon: Icons.event_outlined,
              readOnly: true,
              onTap: () => _selectDate(context, _policyEndDateController),
            ),
          ]),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(),
        ),
        _buildSectionLabel('Legal Declaration'),
        _buildSwitchCard(
          'Any Police/Judicial Cases?',
          _hasPoliceCase,
          Icons.gavel_rounded,
          (v) => setState(() {
            _hasPoliceCase = v;
            _updatePersistedField('has_police_case', v.toString());
          }),
        ),
        if (_hasPoliceCase) ...[
          const SizedBox(height: 8),
          _buildTextField(
            _caseDetailsController,
            'Case Details',
            maxLines: 3,
            icon: Icons.description_outlined,
          ),
        ],
        const SizedBox(height: 20),
        const SizedBox(height: 16),
        _buildTextField(
          _verifiedCityController,
          'City / Place of Verification',
          icon: Icons.location_on_outlined,
        ),
        _buildTextField(
          _verifiedDateController,
          'Date',
          icon: Icons.calendar_today_outlined,
          readOnly: true,
          onTap: () async {
            await _selectDate(context, _verifiedDateController);
            _updatePersistedField(
              'verified_date',
              _verifiedDateController.text,
            );
          },
        ),
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
                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                    : Colors.grey.shade200,
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
                  setState(() => _declarationAccepted = !_declarationAccepted);
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
                          setState(() {
                            _declarationAccepted = v ?? false;
                            _updatePersistedField(
                              'declaration_accepted',
                              _declarationAccepted.toString(),
                            );
                          });
                        },
                        activeColor: AppTheme.primaryColor,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.signature ?? 'SIGNATURE',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade500,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (_firstNameController.text.isEmpty &&
                                    _lastNameController.text.isEmpty)
                                ? '[ FULL NAME ]'
                                : '${_firstNameController.text} ${_lastNameController.text}'
                                      .toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.dateLabel ?? 'DATE',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade500,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _verifiedDateController.text.isEmpty
                              ? '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}'
                              : _verifiedDateController.text,
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
      ],
    );
  }

  // ─── BOTTOM NAV ─────────────────────
  Widget _buildBottomNav(bool isMobile) {
    final isLastStep = _currentStep == 5;
    final isFirstStep = _currentStep == 0;

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: AppTheme.cardFillColor,
            border: Border(
              top: BorderSide(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              if (!isFirstStep)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                        _updatePersistedStep(_currentStep);
                      });
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text(isMobile ? (AppLocalizations.of(context)?.back ?? 'Back') : (AppLocalizations.of(context)?.previousStep ?? 'Previous Step')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.secondaryTextColor,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 14 : 16,
                      ),
                      side: BorderSide(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (!isFirstStep) const SizedBox(width: 12),
              Expanded(
                flex: isFirstStep ? 1 : 1,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_currentStep == 5 && !_declarationAccepted) {
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
                      if (_currentStep < 5) {
                        if (_currentStep == 0 && !_isContinuation) {
                          _submitInitialApplication();
                        } else {
                          setState(() {
                            _currentStep++;
                            _updatePersistedStep(_currentStep);
                          });
                        }
                      } else {
                        _submitApplication();
                      }
                    }
                  },
                  icon: Icon(
                    isLastStep
                        ? Icons.check_circle_rounded
                        : (_currentStep == 0 && !_isContinuation
                              ? Icons.save_rounded
                              : Icons.arrow_forward_rounded),
                    size: 18,
                  ),
                  label: Text(
                    isLastStep
                        ? (AppLocalizations.of(context)?.submit ?? 'Submit')
                        : (_currentStep == 0 && !_isContinuation
                              ? (AppLocalizations.of(context)?.submitAndContinue ?? 'Submit & Continue')
                              : (AppLocalizations.of(context)?.continueLabel ?? 'Continue')),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastStep
                        ? AppTheme.primaryDark
                        : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                    if (_statusMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _statusMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _submitInitialApplication() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });
    _startLoadingTimer();

    try {
      final Map<String, dynamic> driverData = {
        'first_name': _firstNameController.text.trim(),
        'middle_name': _middleNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'state': _selectedState,
        'district': _selectedDistrict,
        'village': _villageController.text.trim(),
        'address': _addressController.text.trim(),
        'pin': _pinController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'dob': _dobController.text.trim(),
        'blood_group': _bloodGroup,
        'mobile1': _mobile1Controller.text.trim(),
        'email': _emailController.text.trim(),
        'license_no': _licenseNoController.text.trim().toUpperCase(),
        'license_issue_date': _licenseIssueDateController.text.trim(),
        'license_expiry_date': _licenseExpiryDateController.text.trim(),
      };

      final id = await FirebaseService().registerDriver(driverData);

      // Persist driver ID locally so user can continue later.
      SharedPreferences.getInstance().then(
        (prefs) => prefs.setString('driver_id', id),
      );

      if (!mounted) return;
      setState(() {
        _driverId = id;
        _isContinuation = true;
      });
      _showPhase1SuccessDialog(id);
    } catch (e) {
      if (!mounted) return;
      final isAppEx = e is FirebaseAppException;
      _showErrorDialog(
        title: 'Submission Failed',
        message: isAppEx
            ? e.userMessage
            : 'Unable to save your information.\n\nPlease check your internet connection and try again.',
        onRetry: _submitInitialApplication,
      );
    } finally {
      _stopLoadingTimer();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPhase1SuccessDialog(String id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 28),
            SizedBox(width: 12),
            Text('Step 1 Completed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your basic information has been saved successfully. Your unique Driver ID is:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      id,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: id));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('ID copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please save this ID. You can use it to complete your application at any time.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue to Next Step'),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) setState(() => _currentStep = 1);
    });
  }

  Future<void> _submitApplication() async {
    if (_driverId == null) return;
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });
    _startLoadingTimer();

    try {
      final Map<String, dynamic> driverData = {
        // Driving License
        'license_no': _licenseNoController.text.trim().toUpperCase(),
        'license_issue_date': _licenseIssueDateController.text.trim(),
        'license_expiry_date': _licenseExpiryDateController.text.trim(),

        // Identity Documents
        'aadhaar': _aadhaarController.text.replaceAll(' ', ''),
        'pan': _panController.text.trim().toUpperCase(),

        // Contact
        'mobile2': _mobile2Controller.text.trim(),
        'dob': _dobController.text.trim(),
        'age': _ageController.text.trim(),

        // Bank Details
        'bank1_name': _bank1NameController.text.trim(),
        'bank1_acc': _bank1AccController.text.trim(),
        'bank1_ifsc': _bank1IfscController.text.trim().toUpperCase(),
        'bank2_name': _bank2NameController.text.trim(),
        'bank2_acc': _bank2AccController.text.trim(),
        'bank2_ifsc': _bank2IfscController.text.trim().toUpperCase(),

        // Family Details
        'father_name': _fatherNameController.text.trim(),
        'father_mobile': _fatherMobileController.text.trim(),
        'mother_name': _motherNameController.text.trim(),
        'mother_mobile': _motherMobileController.text.trim(),
        'spouse_name': _spouseNameController.text.trim(),
        'spouse_mobile': _spouseMobileController.text.trim(),

        // JSON Data
        'education_json': {
          'sslc': {'status': _sslcStatus, 'year': _sslcYear},
          'plus_two': {'status': _plusTwoStatus, 'year': _plusTwoYear},
          'degree': {'status': _degreeStatus, 'year': _degreeYear},
          'post_grad': {'status': _postGradStatus, 'year': _postGradYear},
          'diploma': {'status': _diplomaStatus, 'year': _diplomaYear},
          'tech_course': {'status': _techCourseStatus, 'year': _techCourseYear},
        },
        'languages_json': {
          'english': {'speak': _engSpeak, 'read': _engRead, 'write': _engWrite},
          'hindi': {'speak': _hinSpeak, 'read': _hinRead, 'write': _hinWrite},
          'malayalam': {
            'speak': _malSpeak,
            'read': _malRead,
            'write': _malWrite,
          },
          'kannada': {'speak': _kanSpeak, 'read': _kanRead, 'write': _kanWrite},
          'tamil': {'speak': _tamSpeak, 'read': _tamRead, 'write': _tamWrite},
        },
        'experience_json': _experiences
            .map(
              (e) => {
                'company': e.companyController.text.trim(),
                'join_date': e.joinDateController.text.trim(),
                'leave_date': e.leaveDateController.text.trim(),
                'reason': e.reasonController.text.trim(),
              },
            )
            .toList(),

        // Legal & Insurance
        'has_insurance': _hasInsurance,
        'insurance_company': _insuranceCompanyController.text.trim(),
        'policy_no': _policyNoController.text.trim(),
        'sum_insured': _sumInsuredController.text.trim(),
        'policy_end_date': _policyEndDateController.text.trim(),
        'has_police_case': _hasPoliceCase,
        'case_details': _caseDetailsController.text.trim(),
        'verified_city': _verifiedCityController.text.trim().toUpperCase(),
        'verified_date': _verifiedDateController.text.trim(),
        'declaration_accepted': _declarationAccepted,
      };

      // Run DB update and local prefs removal in parallel for speed.
      await Future.wait([
        FirebaseService().updateDriverByCode(_driverId!, driverData),
        SharedPreferences.getInstance().then(
          (prefs) => prefs.remove('driver_id'),
        ),
      ]);

      if (!mounted) return;
      Provider.of<FormPersistenceState>(context, listen: false).clearDriver();

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Full Application Submitted Successfully!'),
            ],
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final isAppEx = e is FirebaseAppException;
      _showErrorDialog(
        title: 'Submission Failed',
        message: isAppEx
            ? e.userMessage
            : 'Unable to submit your application.\n\nPlease check your internet connection and try again.',
        onRetry: _submitApplication,
      );
    } finally {
      _stopLoadingTimer();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── REUSABLE WIDGETS ─────────────────────
  Future<DateTime?> _selectDateReturn(
    BuildContext context, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime initial = (lastDate != null && now.isAfter(lastDate))
        ? lastDate
        : now;

    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate ?? DateTime(1970),
      lastDate: lastDate ?? now,
      useRootNavigator: true,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
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

  void _onDobSelected(DateTime picked) {
    final now = DateTime.now();
    int age = now.year - picked.year;
    if (now.month < picked.month ||
        (now.month == picked.month && now.day < picked.day)) {
      age--;
    }
    setState(() {
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      _ageController.text = age.toString();
    });
  }

  /// Helper to parse "DD/MM/YYYY" string back to DateTime
  DateTime? _parseDate(String text) {
    if (text.isEmpty) return null;
    final parts = text.split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }

  /// Lays children out in a Row on desktop, stacked Column on mobile
  Widget _responsiveRow(bool isMobile, List<Widget> children) {
    if (isMobile) {
      return Column(children: children);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          children
              .expand(
                (child) => [Expanded(child: child), const SizedBox(width: 12)],
              )
              .toList()
            ..removeLast(), // remove trailing SizedBox
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? icon,
    int? maxLength,
    int? exactLength, // enforce exact digit count
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    TextCapitalization capitalization = TextCapitalization.none,
    String? hint,
    String? Function(String?)? validator,
  }) {
    // Append * to label for mandatory fields
    final displayLabel = isRequired ? '$label *' : label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        readOnly: readOnly,
        onTap: onTap,
        textCapitalization: capitalization,
        decoration: InputDecoration(
          counterText: '', // Hide character counter
          labelText: displayLabel,
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(icon, size: 20, color: AppTheme.secondaryTextColor)
              : null,
          filled: true,
          fillColor: AppTheme.surfaceColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 1.5,
            ),
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator:
            validator ??
            (v) {
              if (isRequired && (v == null || v.trim().isEmpty)) {
                return 'Required';
              }
              if (exactLength != null && v != null && v.isNotEmpty) {
                // Strip spaces (e.g. Aadhaar formatted) before checking length
                final stripped = v.replaceAll(' ', '');
                if (stripped.length < exactLength) {
                  return 'Must be exactly $exactLength digits';
                }
              }
              return null;
            },
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppTheme.surfaceColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          if (isOptional) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Optional',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationLevel(
    String label,
    String? status,
    String? year,
    ValueChanged<String?> onStatusChanged,
    ValueChanged<String?> onYearChanged,
    bool isMobile,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildDropdown(label, status, _passFail, onStatusChanged),
          ),
          if (status == 'Pass') ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildDropdown('Year', year, _years, onYearChanged),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExperienceTable(bool isMobile) {
    return Column(
      children: List.generate(_experiences.length, (index) {
        final entry = _experiences[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Experience ${index + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      entry.dispose();
                      _experiences.removeAt(index);
                    }),
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    color: Colors.red.withValues(alpha: 0.7),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                entry.companyController,
                'Taxi Car Company Name',
                isRequired: false,
                icon: Icons.business_outlined,
              ),
              _responsiveRow(isMobile, [
                _buildTextField(
                  entry.joinDateController,
                  'Joining Date',
                  isRequired: false,
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: () => _selectDate(context, entry.joinDateController),
                ),
                _buildTextField(
                  entry.leaveDateController,
                  'Leaving Date',
                  isRequired: false,
                  icon: Icons.event_outlined,
                  readOnly: true,
                  onTap: () => _selectDate(context, entry.leaveDateController),
                ),
              ]),
              _buildTextField(
                entry.reasonController,
                'Reasons',
                isRequired: false,
                icon: Icons.description_outlined,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSwitchCard(
    String title,
    bool value,
    IconData icon,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: value
            ? AppTheme.primaryColor.withValues(alpha: 0.05)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppTheme.primaryColor.withValues(alpha: 0.3)
              : AppTheme.primaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageHeader(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          SizedBox(width: isMobile ? 80 : 100),
          const Expanded(
            child: Text(
              'Speak',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Read',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Write',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageRow(
    String lang,
    bool s,
    bool r,
    bool w,
    Function(bool, bool, bool) onChanged,
    bool isMobile,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: (s || r || w)
            ? AppTheme.primaryColor.withValues(alpha: 0.04)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: isMobile ? 80 : 100,
            child: Text(
              lang,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textColor,
              ),
            ),
          ),
          Expanded(
            child: Checkbox(
              value: s,
              onChanged: (v) => onChanged(v!, r, w),
              activeColor: AppTheme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          Expanded(
            child: Checkbox(
              value: r,
              onChanged: (v) => onChanged(s, v!, w),
              activeColor: AppTheme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          Expanded(
            child: Checkbox(
              value: w,
              onChanged: (v) => onChanged(s, r, v!),
              activeColor: AppTheme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceEntry {
  final companyController = TextEditingController();
  final joinDateController = TextEditingController();
  final leaveDateController = TextEditingController();
  final reasonController = TextEditingController();

  void dispose() {
    companyController.dispose();
    joinDateController.dispose();
    leaveDateController.dispose();
    reasonController.dispose();
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

/// Uppercases only the alphabetic characters in the license number.
/// Digits, hyphens, and spaces are passed through unchanged.
class _LicenseNumberFormatter extends TextInputFormatter {
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
