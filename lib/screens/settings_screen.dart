import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  final AppState state;

  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _shopNameCtrl;
  late final TextEditingController _ownerCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _ntnCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _footerCtrl;

  @override
  void initState() {
    super.initState();
    _shopNameCtrl = TextEditingController(text: widget.state.shopName);
    _ownerCtrl = TextEditingController(text: widget.state.ownerName);
    _phoneCtrl = TextEditingController(text: widget.state.phone);
    _ntnCtrl = TextEditingController(text: widget.state.ntn);
    _addressCtrl = TextEditingController(text: widget.state.address);
    _footerCtrl = TextEditingController(text: widget.state.invoiceFooter);
  }

  void _saveSettings() {
    widget.state.updateShopSettings(
      name: _shopNameCtrl.text.trim(),
      owner: _ownerCtrl.text.trim(),
      shopPhone: _phoneCtrl.text.trim(),
      shopNtn: _ntnCtrl.text.trim(),
      shopAddress: _addressCtrl.text.trim(),
      footer: _footerCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.primaryGreen,
        content: Text('Shop profile & preferences updated!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Profile & Settings'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.lightLine)),
        ),
        child: ElevatedButton.icon(
          onPressed: _saveSettings,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save Settings'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Business & Shop Identification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _shopNameCtrl,
                      decoration: const InputDecoration(labelText: 'Shop / Business Name', prefixIcon: Icon(Icons.storefront_outlined)),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _ownerCtrl,
                      decoration: const InputDecoration(labelText: 'Owner / Proprietor Name', prefixIcon: Icon(Icons.person_outline)),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneCtrl,
                            decoration: const InputDecoration(labelText: 'Shop Phone / WhatsApp', prefixIcon: Icon(Icons.phone_outlined)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _ntnCtrl,
                            decoration: const InputDecoration(labelText: 'Tax NTN / Registration', prefixIcon: Icon(Icons.badge_outlined)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(labelText: 'Full Address / Location', prefixIcon: Icon(Icons.location_on_outlined)),
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
                    const Text('Invoice & Receipt Customization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _footerCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Receipt Footer Disclaimer',
                        prefixIcon: Icon(Icons.receipt_long_outlined),
                      ),
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
                    const Text('Display & System Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Dark Mode Appearance', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('High-contrast dark theme for night usage'),
                      trailing: Switch.adaptive(
                        value: widget.state.themeMode == ThemeMode.dark,
                        activeTrackColor: AppTheme.primaryGreen,
                        onChanged: (_) => widget.state.toggleTheme(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
