import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
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
  String? _driverId;
  bool _isContinuation = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkExistingApplication();
  }

  Future<void> _checkExistingApplication() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = widget.continuationId ?? prefs.getString('driver_id');

    if (savedId != null) {
      setState(() => _isLoading = true);
      try {
        final data = await SupabaseService().getDriverById(savedId);
        if (data != null) {
          setState(() {
            _driverId = savedId;
            _isContinuation = true;
            _currentStep = 1; // Start from Step 2 (Index 1)

            // Populate basic info
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
        debugPrint('Error loading existing application: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
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
  String? _bloodGroup;
  final _licenseNoController = TextEditingController();
  final _licenseIssueDateController = TextEditingController();
  final _licenseExpiryDateController = TextEditingController();

  // Experience entries
  final List<_ExperienceEntry> _experiences = [];

  // Insurance & Legal
  bool _hasInsurance = false;
  final _insuranceCompanyController = TextEditingController();
  final _policyNoController = TextEditingController();
  final _sumInsuredController = TextEditingController();
  final _policyEndDateController = TextEditingController();

  bool _hasPoliceCase = false;
  final _caseDetailsController = TextEditingController();

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
          ),
          _buildTextField(
            _middleNameController,
            'Middle Name',
            isRequired: false,
          ),
          _buildTextField(_lastNameController, 'Last Name', isRequired: false),
        ]),
        _responsiveRow(isMobile, [
          _buildDropdown('State', _selectedState, _states, (v) {
            setState(() {
              _selectedState = v;
              _selectedDistrict = null; // Reset district when state changes
            });
          }),
          _buildDropdown(
            'District',
            _selectedDistrict,
            _selectedState != null
                ? (_stateDistricts[_selectedState] ?? [])
                : [],
            (v) => setState(() => _selectedDistrict = v),
          ),
        ]),
        _buildTextField(
          _villageController,
          'Village',
          icon: Icons.location_on_outlined,
        ),
        _buildTextField(
          _addressController,
          'Full Address',
          maxLines: 2,
          icon: Icons.home_outlined,
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
          _buildTextField(_landmarkController, 'Landmark', isRequired: false),
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
            onTap: () => _selectDate(context, _dobController),
          ),
          _buildDropdown(
            'Blood Group',
            _bloodGroup,
            _bloodGroups,
            (v) => setState(() => _bloodGroup = v),
          ),
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
        ),
        _responsiveRow(isMobile, [
          _buildTextField(
            _licenseIssueDateController,
            'Issue Date',
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: () => _selectDate(context, _licenseIssueDateController),
          ),
          _buildTextField(
            _licenseExpiryDateController,
            'Expiry Date',
            icon: Icons.event_outlined,
            readOnly: true,
            onTap: () => _selectDate(context, _licenseExpiryDateController),
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
            if (s == 'Fail') {
              _plusTwoStatus = _degreeStatus = _postGradStatus =
                  _diplomaStatus = _techCourseStatus = null;
              _plusTwoYear = _degreeYear = _postGradYear = _diplomaYear =
                  _techCourseYear = null;
            }
          }),
          (y) => setState(() => _sslcYear = y),
          isMobile,
        ),
        if (_sslcStatus == 'Pass') ...[
          _buildEducationLevel(
            '+2',
            _plusTwoStatus,
            _plusTwoYear,
            (s) => setState(() => _plusTwoStatus = s),
            (y) => setState(() => _plusTwoYear = y),
            isMobile,
          ),
          _buildEducationLevel(
            'Graduation',
            _degreeStatus,
            _degreeYear,
            (s) => setState(() => _degreeStatus = s),
            (y) => setState(() => _degreeYear = y),
            isMobile,
          ),
          _buildEducationLevel(
            'Post Graduation',
            _postGradStatus,
            _postGradYear,
            (s) => setState(() => _postGradStatus = s),
            (y) => setState(() => _postGradYear = y),
            isMobile,
          ),
          _buildEducationLevel(
            'Diploma',
            _diplomaStatus,
            _diplomaYear,
            (s) => setState(() => _diplomaStatus = s),
            (y) => setState(() => _diplomaYear = y),
            isMobile,
          ),
          _buildEducationLevel(
            'Technical Course',
            _techCourseStatus,
            _techCourseYear,
            (s) => setState(() => _techCourseStatus = s),
            (y) => setState(() => _techCourseYear = y),
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
              onPressed: () =>
                  setState(() => _experiences.add(_ExperienceEntry())),
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
          (v) => setState(() => _hasInsurance = v),
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
          (v) => setState(() => _hasPoliceCase = v),
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
                    onPressed: () => setState(() => _currentStep--),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text(isMobile ? 'Back' : 'Previous Step'),
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
                      if (_currentStep < 5) {
                        if (_currentStep == 0 && !_isContinuation) {
                          _submitInitialApplication();
                        } else {
                          setState(() => _currentStep++);
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
                        ? 'Submit'
                        : (_currentStep == 0 && !_isContinuation
                              ? 'Submit & Continue'
                              : 'Continue'),
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
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _submitInitialApplication() async {
    setState(() => _isLoading = true);

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
        // Driving License — mandatory in Phase 1
        'license_no': _licenseNoController.text.trim().toUpperCase(),
        'license_issue_date': _licenseIssueDateController.text.trim(),
        'license_expiry_date': _licenseExpiryDateController.text.trim(),
      };

      final id = await SupabaseService().registerDriver(driverData);
      // Persist driver ID locally in parallel — no need to await before showing dialog.
      SharedPreferences.getInstance().then(
        (prefs) => prefs.setString('driver_id', id),
      );

      setState(() {
        _driverId = id;
        _isContinuation = true;
      });

      if (!mounted) return;
      _showPhase1SuccessDialog(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Initial submission failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
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
    setState(() => _isLoading = true);

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
      };

      // Run DB update and local prefs removal in parallel for speed.
      await Future.wait([
        SupabaseService().updateDriver(_driverId!, driverData),
        SharedPreferences.getInstance().then(
          (prefs) => prefs.remove('driver_id'),
        ),
      ]);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Final submission failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── REUSABLE WIDGETS ─────────────────────
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
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
    if (picked != null) {
      setState(() {
        final d = picked.day.toString().padLeft(2, '0');
        final m = picked.month.toString().padLeft(2, '0');
        controller.text = '$d/$m/${picked.year}';
      });
    }
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
        decoration: InputDecoration(
          counterText: '', // Hide character counter
          labelText: displayLabel,
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
        validator: (v) {
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
