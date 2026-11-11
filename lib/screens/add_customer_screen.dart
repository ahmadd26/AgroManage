import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/customer.dart';

class AddCustomerScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const AddCustomerScreen({
    super.key,
    required this.state,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cnicController = TextEditingController();
  final _creditLimitController = TextEditingController(text: '150000');
  final _notesController = TextEditingController();

  void _saveCustomer() {
    if (!_formKey.currentState!.validate()) return;

    final double creditLimit = double.tryParse(_creditLimitController.text) ?? 150000.0;

    final newCustomer = Customer(
      id: 'c${widget.state.customers.length + 1}',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      cnic: _cnicController.text.trim(),
      creditLimit: creditLimit,
      notes: _notesController.text.trim(),
    );

    widget.state.addCustomer(newCustomer);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryGreen,
        content: Text('Farmer "${newCustomer.name}" registered successfully!'),
      ),
    );

    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onCancel),
        title: const Text('Add Farmer / Customer'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.lightLine)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _saveCustomer,
                icon: const Icon(Icons.check),
                label: const Text('Save Farmer Account'),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Farmer Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 14),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          hintText: 'e.g. Chaudhry Tariq Mehmood',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter farmer name' : null,
                      ),

                      const SizedBox(height: 14),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Mobile / WhatsApp Number *',
                          hintText: '03xx-xxxxxxx',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter phone number' : null,
                      ),

                      const SizedBox(height: 14),

                      // Address / Village
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Village / Chak / Tehsil *',
                          hintText: 'e.g. Chak 45 GB, Sahiwal, Okara',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter village address' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Credit & Khata Parameters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 14),

                      // CNIC
                      TextFormField(
                        controller: _cnicController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'National CNIC Number',
                          hintText: 'xxxxx-xxxxxxx-x',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Credit Limit
                      TextFormField(
                        controller: _creditLimitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Approved Credit Limit (Khata)',
                          prefixText: 'PKR ',
                          prefixIcon: Icon(Icons.account_balance_outlined),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Acreage / Crop Notes',
                          hintText: 'e.g. 25 Acres Cotton & Maize, Tube-well owner',
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
