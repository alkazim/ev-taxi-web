import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DriverApplicationDialog extends StatefulWidget {
  const DriverApplicationDialog({super.key});

  @override
  State<DriverApplicationDialog> createState() =>
      _DriverApplicationDialogState();
}

class _DriverApplicationDialogState extends State<DriverApplicationDialog> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

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
  final _sslcYearController = TextEditingController();
  final _plusTwoYearController = TextEditingController();
  final _degreeYearController = TextEditingController();
  final _diplomaYearController = TextEditingController();

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

  // Experience
  final _exp1Controller = TextEditingController();

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
    'Puducherry'
  ];
  final List<String> _districts = [
    'Thiruvananthapuram',
    'Kochi',
    'Kozhikode',
    'Bangalore',
    'Chennai',
    'Other'
  ];
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
    'Oh'
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
            child: const Icon(Icons.close_rounded, size: 20, color: AppTheme.secondaryTextColor),
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
              child: Icon(stepIcons[_currentStep],
                  color: AppTheme.primaryColor, size: 22),
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
      children: [
        _responsiveRow(isMobile, [
          _buildTextField(_firstNameController, 'First Name',
              icon: Icons.person_outline),
          _buildTextField(_middleNameController, 'Middle Name',
              isRequired: false),
          _buildTextField(_lastNameController, 'Last Name'),
        ]),
        _responsiveRow(isMobile, [
          _buildDropdown('State', _selectedState, _states,
              (v) => setState(() => _selectedState = v)),
          _buildDropdown('District', _selectedDistrict, _districts,
              (v) => setState(() => _selectedDistrict = v)),
        ]),
        _buildTextField(_villageController, 'Village',
            icon: Icons.location_on_outlined),
        _buildTextField(_addressController, 'Full Address',
            maxLines: 2, icon: Icons.home_outlined),
        _responsiveRow(isMobile, [
          _buildTextField(_pinController, 'PIN Code',
              keyboardType: TextInputType.number, icon: Icons.pin_drop_outlined),
          _buildTextField(_landmarkController, 'Landmark'),
        ]),
        _responsiveRow(isMobile, [
          _buildTextField(_dobController, 'Date of Birth',
              icon: Icons.calendar_today_outlined),
          _buildDropdown('Blood Group', _bloodGroup, _bloodGroups,
              (v) => setState(() => _bloodGroup = v)),
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
          _buildTextField(_aadhaarController, 'Aadhaar Number',
              keyboardType: TextInputType.number,
              icon: Icons.credit_card_rounded),
          _buildTextField(_panController, 'PAN Number',
              icon: Icons.badge_outlined),
        ]),
        const SizedBox(height: 16),
        _buildSectionLabel('Contact Information'),
        _responsiveRow(isMobile, [
          _buildTextField(_mobile1Controller, 'Primary Mobile',
              keyboardType: TextInputType.phone, icon: Icons.phone_rounded),
          _buildTextField(_mobile2Controller, 'Secondary Mobile',
              keyboardType: TextInputType.phone, isRequired: false),
        ]),
        _buildTextField(_emailController, 'Email Address',
            keyboardType: TextInputType.emailAddress,
            icon: Icons.email_outlined),
      ],
    );
  }

  // ─── STEP 3: Bank & Family ─────────────────────
  Widget _buildBankFamilyStep(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Primary Bank Account'),
        _buildTextField(_bank1NameController, 'Bank Name',
            icon: Icons.account_balance_outlined),
        _responsiveRow(isMobile, [
          _buildTextField(_bank1AccController, 'Account Number',
              keyboardType: TextInputType.number),
          _buildTextField(_bank1IfscController, 'IFSC Code'),
        ]),
        const SizedBox(height: 12),
        _buildSectionLabel('Secondary Bank Account', isOptional: true),
        _buildTextField(_bank2NameController, 'Bank Name',
            isRequired: false, icon: Icons.account_balance_outlined),
        _responsiveRow(isMobile, [
          _buildTextField(_bank2AccController, 'Account Number',
              isRequired: false, keyboardType: TextInputType.number),
          _buildTextField(_bank2IfscController, 'IFSC Code',
              isRequired: false),
        ]),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(),
        ),
        _buildSectionLabel('Family Details'),
        _responsiveRow(isMobile, [
          _buildTextField(_fatherNameController, "Father's Name",
              icon: Icons.person_outline),
          _buildTextField(_fatherMobileController, "Father's Mobile",
              keyboardType: TextInputType.phone),
        ]),
        _responsiveRow(isMobile, [
          _buildTextField(_motherNameController, "Mother's Name",
              icon: Icons.person_outline),
          _buildTextField(_motherMobileController, "Mother's Mobile",
              keyboardType: TextInputType.phone),
        ]),
        _responsiveRow(isMobile, [
          _buildTextField(_spouseNameController, "Spouse's Name",
              isRequired: false, icon: Icons.favorite_outline),
          _buildTextField(_spouseMobileController, "Spouse's Mobile",
              isRequired: false, keyboardType: TextInputType.phone),
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
        _responsiveRow(isMobile, [
          _buildTextField(_sslcYearController, 'SSLC Year',
              keyboardType: TextInputType.number),
          _buildTextField(_plusTwoYearController, '+2 Year',
              keyboardType: TextInputType.number),
        ]),
        _responsiveRow(isMobile, [
          _buildTextField(_degreeYearController, 'Degree Year',
              isRequired: false),
          _buildTextField(_diplomaYearController, 'Diploma/Cert Year',
              isRequired: false),
        ]),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(),
        ),
        _buildSectionLabel('Language Proficiency'),
        const SizedBox(height: 8),
        // Language header
        _buildLanguageHeader(isMobile),
        const SizedBox(height: 4),
        _buildLanguageRow('English', _engSpeak, _engRead, _engWrite,
            (s, r, w) => setState(() {
                  _engSpeak = s;
                  _engRead = r;
                  _engWrite = w;
                }), isMobile),
        _buildLanguageRow('Hindi', _hinSpeak, _hinRead, _hinWrite,
            (s, r, w) => setState(() {
                  _hinSpeak = s;
                  _hinRead = r;
                  _hinWrite = w;
                }), isMobile),
        _buildLanguageRow('Malayalam', _malSpeak, _malRead, _malWrite,
            (s, r, w) => setState(() {
                  _malSpeak = s;
                  _malRead = r;
                  _malWrite = w;
                }), isMobile),
        _buildLanguageRow('Kannada', _kanSpeak, _kanRead, _kanWrite,
            (s, r, w) => setState(() {
                  _kanSpeak = s;
                  _kanRead = r;
                  _kanWrite = w;
                }), isMobile),
        _buildLanguageRow('Tamil', _tamSpeak, _tamRead, _tamWrite,
            (s, r, w) => setState(() {
                  _tamSpeak = s;
                  _tamRead = r;
                  _tamWrite = w;
                }), isMobile),
      ],
    );
  }

  // ─── STEP 5: Professional Info ─────────────────────
  Widget _buildProfessionalStep(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Driving License'),
        _buildTextField(_licenseNoController, 'License Number',
            icon: Icons.drive_eta_rounded),
        _responsiveRow(isMobile, [
          _buildTextField(_licenseIssueDateController, 'Issue Date',
              icon: Icons.calendar_today_outlined),
          _buildTextField(_licenseExpiryDateController, 'Expiry Date',
              icon: Icons.event_outlined),
        ]),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(),
        ),
        _buildSectionLabel('Previous Experience', isOptional: true),
        _buildTextField(_exp1Controller, 'Last Company Name',
            icon: Icons.business_outlined),
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
          _buildTextField(_insuranceCompanyController, 'Insurance Company',
              icon: Icons.business_outlined),
          _buildTextField(_policyNoController, 'Policy Number'),
          _responsiveRow(isMobile, [
            _buildTextField(_sumInsuredController, 'Sum Insured (₹)',
                keyboardType: TextInputType.number),
            _buildTextField(_policyEndDateController, 'Policy End Date',
                icon: Icons.event_outlined),
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
          _buildTextField(_caseDetailsController, 'Case Details',
              maxLines: 3, icon: Icons.description_outlined),
        ],
      ],
    );
  }

  // ─── BOTTOM NAV ─────────────────────
  Widget _buildBottomNav(bool isMobile) {
    final isLastStep = _currentStep == 5;
    final isFirstStep = _currentStep == 0;

    return Container(
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
                if (_currentStep < 5) {
                  setState(() => _currentStep++);
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Application Submitted Successfully!'),
                        ],
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              icon: Icon(
                isLastStep
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_rounded,
                size: 18,
              ),
              label: Text(isLastStep ? 'Submit' : 'Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep
                    ? AppTheme.primaryDark
                    : AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── REUSABLE WIDGETS ─────────────────────

  /// Lays children out in a Row on desktop, stacked Column on mobile
  Widget _responsiveRow(bool isMobile, List<Widget> children) {
    if (isMobile) {
      return Column(children: children);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .expand((child) => [
                Expanded(child: child),
                const SizedBox(width: 12),
              ])
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null
              ? Icon(icon, size: 20, color: AppTheme.secondaryTextColor)
              : null,
          filled: true,
          fillColor: AppTheme.surfaceColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            borderSide:
                const BorderSide(color: AppTheme.primaryColor, width: 1.5),
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: isRequired
            ? (v) => (v == null || v.isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            borderSide:
                const BorderSide(color: AppTheme.primaryColor, width: 1.5),
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

  Widget _buildSwitchCard(
      String title, bool value, IconData icon, ValueChanged<bool> onChanged) {
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
            child: Text('Speak',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryTextColor)),
          ),
          const Expanded(
            child: Text('Read',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryTextColor)),
          ),
          const Expanded(
            child: Text('Write',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryTextColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageRow(String lang, bool s, bool r, bool w,
      Function(bool, bool, bool) onChanged, bool isMobile) {
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
