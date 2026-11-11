import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/supplier.dart';
import '../models/product.dart';
import '../models/purchase.dart';

class NewPurchaseScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const NewPurchaseScreen({
    super.key,
    required this.state,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<NewPurchaseScreen> createState() => _NewPurchaseScreenState();
}

class _NewPurchaseScreenState extends State<NewPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  Supplier? _selectedSupplier;
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '20');
  final _rateController = TextEditingController();
  final _paidController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.state.suppliers.isNotEmpty) {
      _selectedSupplier = widget.state.suppliers.first;
    }
    if (widget.state.products.isNotEmpty) {
      _selectedProduct = widget.state.products.first;
      _rateController.text = _selectedProduct!.buyPrice.toStringAsFixed(0);
    }
  }

  void _savePurchase() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null || _selectedProduct == null) return;

    final qty = int.tryParse(_quantityController.text) ?? 1;
    final rate = double.tryParse(_rateController.text) ?? _selectedProduct!.buyPrice;
    final paid = double.tryParse(_paidController.text) ?? 0.0;

    final newPurchase = PurchaseOrder(
      purchaseNo: 'PUR-00${88 + widget.state.purchases.length}',
      supplier: _selectedSupplier!,
      date: DateTime.now().toIso8601String().substring(0, 10),
      items: [
        PurchaseItem(product: _selectedProduct!, quantity: qty, buyPrice: rate),
      ],
      paidAmount: paid,
      notes: _notesController.text.trim(),
    );

    widget.state.addPurchase(newPurchase);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryGreen,
        content: Text('Stock inward saved! +$qty ${_selectedProduct!.unit} added to ${_selectedProduct!.name}.'),
      ),
    );

    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onCancel),
        title: const Text('Record Stock Inward (Purchase)'),
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
                onPressed: _savePurchase,
                icon: const Icon(Icons.check),
                label: const Text('Save Stock Inward'),
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
                      const Text('Supplier & Product Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 14),

                      // Supplier Dropdown
                      DropdownButtonFormField<Supplier>(
                        initialValue: _selectedSupplier,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Agrochemical Supplier / Distributor *',
                          prefixIcon: Icon(Icons.local_shipping_outlined),
                        ),
                        items: widget.state.suppliers.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text('${s.name} (${s.city})'),
                          );
                        }).toList(),
                        onChanged: (s) => setState(() => _selectedSupplier = s),
                      ),

                      const SizedBox(height: 14),

                      // Product Dropdown
                      DropdownButtonFormField<Product>(
                        initialValue: _selectedProduct,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Product Received *',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        items: widget.state.products.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text('${p.name} (Current: ${p.stock})'),
                          );
                        }).toList(),
                        onChanged: (p) {
                          if (p != null) {
                            setState(() {
                              _selectedProduct = p;
                              _rateController.text = p.buyPrice.toStringAsFixed(0);
                            });
                          }
                        },
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
                      const Text('Quantity & Inward Costing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Units Received *',
                                suffixText: _selectedProduct?.unit ?? 'units',
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _rateController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Purchase Rate *',
                                prefixText: 'PKR ',
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _paidController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount Paid to Supplier Now',
                          prefixText: 'PKR ',
                          prefixIcon: Icon(Icons.payment),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Bilty / Truck Loader Tracking #',
                          hintText: 'e.g. Bilty # 87123 Daewoo Cargo Multan',
                          prefixIcon: Icon(Icons.notes),
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
