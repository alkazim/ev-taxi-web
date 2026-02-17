import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FranchiseApplicationDialog extends StatefulWidget {
  final String franchiseType; // Mega, Master, Super
  const FranchiseApplicationDialog({super.key, required this.franchiseType});

  @override
  State<FranchiseApplicationDialog> createState() =>
      _FranchiseApplicationDialogState();
}

class _FranchiseApplicationDialogState extends State<FranchiseApplicationDialog> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  bool _hasInfrastructure = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Apply for ${widget.franchiseType} Franchise',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _businessNameController,
                  decoration: const InputDecoration(labelText: 'Business/Entity Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _contactPersonController,
                  decoration: const InputDecoration(labelText: 'Contact Person Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Proposed Location (City/District)'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Do you have existing office space?'),
                  value: _hasInfrastructure,
                  onChanged: (v) => setState(() => _hasInfrastructure = v),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Franchise Enquiry Submitted!')),
                        );
                      }
                    },
                    child: const Text('SUBMIT ENQUIRY'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
