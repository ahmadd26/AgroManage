import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/supplier.dart';

class SuppliersScreen extends StatefulWidget {
  final AppState state;
  final Function(String) onSelectSupplier;

  const SuppliersScreen({
    super.key,
    required this.state,
    required this.onSelectSupplier,
  });

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  void _showAddSupplierDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final repCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Agrochemical Supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Company / Distributor Name *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone / Office Tel *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: 'City (e.g. Lahore, Multan) *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: repCtrl,
                decoration: const InputDecoration(labelText: 'Sales Representative Name'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final newSupplier = Supplier(
                id: 's${widget.state.suppliers.length + 1}',
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                city: cityCtrl.text.trim(),
                representative: repCtrl.text.trim(),
              );
              widget.state.addSupplier(newSupplier);
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Supplier registered successfully!')),
              );
            },
            child: const Text('Add Supplier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agro Suppliers & Distributors'),
        actions: [
          ElevatedButton.icon(
            onPressed: _showAddSupplierDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.add_business_outlined, size: 18),
            label: const Text('Add Supplier', style: TextStyle(fontSize: 12.5)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.suppliers.length,
        itemBuilder: (context, index) {
          final s = state.suppliers[index];
          final purchased = state.getSupplierPurchased(s.id);
          final paid = state.getSupplierPaid(s.id);
          final balance = state.getSupplierBalance(s.id);
          final ordersCount = state.purchases.where((p) => p.supplier.id == s.id).length;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryBlueLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.business, color: AppTheme.secondaryBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${s.city} · Tel: ${s.phone}${s.representative.isNotEmpty ? " (Rep: ${s.representative})" : ""}',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _statMini('Orders', '$ordersCount Inwards')),
                      const SizedBox(width: 8),
                      Expanded(child: _statMini('Total Volume', AppTheme.formatCurrency(purchased))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _statMini('Paid', AppTheme.formatCurrency(paid))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statMini(
                          'Payable Due',
                          AppTheme.formatCurrency(balance),
                          color: balance > 0 ? AppTheme.alertRed : AppTheme.primaryGreenDark,
                          isBold: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statMini(String label, String value, {Color? color, bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
