import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/product.dart';

class AddProductScreen extends StatefulWidget {
  final AppState state;
  final String? editProductId;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const AddProductScreen({
    super.key,
    required this.state,
    this.editProductId,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController(text: '20');
  final _expiryController = TextEditingController();
  String _selectedCategory = 'Seeds';
  String _selectedUnit = 'Bags';

  final List<String> _categories = [
    'Seeds',
    'Fertilizers',
    'Pesticides',
    'Herbicides',
    'Fungicides',
    'Tools',
  ];

  final List<String> _units = [
    'Bags',
    'Bottles',
    'Packs',
    'Units',
    'Kg',
    'Liters',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editProductId != null) {
      final existing = widget.state.products.firstWhere(
        (p) => p.id == widget.editProductId,
        orElse: () => widget.state.products.first,
      );
      _nameController.text = existing.name;
      _buyPriceController.text = existing.buyPrice.toStringAsFixed(0);
      _salePriceController.text = existing.salePrice.toStringAsFixed(0);
      _stockController.text = existing.stock.toString();
      _minStockController.text = existing.minStock.toString();
      _expiryController.text = existing.expiryDate;
      _selectedCategory = existing.category;
      _selectedUnit = existing.unit;
    }
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final buy = double.tryParse(_buyPriceController.text) ?? 0.0;
    final sale = double.tryParse(_salePriceController.text) ?? 0.0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final min = int.tryParse(_minStockController.text) ?? 10;

    if (widget.editProductId != null) {
      final updated = Product(
        id: widget.editProductId!,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        buyPrice: buy,
        salePrice: sale,
        stock: stock,
        minStock: min,
        expiryDate: _expiryController.text.trim(),
        unit: _selectedUnit,
      );
      widget.state.updateProduct(updated);
    } else {
      final newProd = Product(
        id: 'p${widget.state.products.length + 1}',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        buyPrice: buy,
        salePrice: sale,
        stock: stock,
        minStock: min,
        expiryDate: _expiryController.text.trim(),
        unit: _selectedUnit,
      );
      widget.state.addProduct(newProd);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryGreen,
        content: Text(
          widget.editProductId != null ? 'Product updated successfully' : 'New product registered into inventory',
        ),
      ),
    );

    widget.onSaved();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _expiryController.text = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editProductId != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onCancel),
        title: Text(isEdit ? 'Edit Product' : 'Add New Product'),
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
                onPressed: _saveProduct,
                icon: const Icon(Icons.check),
                label: Text(isEdit ? 'Save Changes' : 'Save Product'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Product Identification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 14),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Full Name *',
                          hintText: 'e.g. Pioneer 30T60 Maize 10kg or Urea Sona 50kg',
                          prefixIcon: Icon(Icons.label_outline),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter product name' : null,
                      ),

                      const SizedBox(height: 14),

                      // Category & Unit
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: const InputDecoration(labelText: 'Category *'),
                              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedCategory = v);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedUnit,
                              decoration: const InputDecoration(labelText: 'Packaging Unit'),
                              items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedUnit = v);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Pricing Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pricing & Margins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _buyPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Purchase Price (Cost) *',
                                prefixText: 'PKR ',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _salePriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Retail Selling Price *',
                                prefixText: 'PKR ',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Inventory & Stock Controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stock Management & Expiry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Initial Stock Qty *',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _minStockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Min Alert Level *',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Expiry Date picker
                      TextFormField(
                        controller: _expiryController,
                        readOnly: true,
                        onTap: _pickExpiryDate,
                        decoration: InputDecoration(
                          labelText: 'Expiry Date (YYYY-MM-DD)',
                          hintText: 'Select date for chemicals/seeds',
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.edit_calendar),
                            onPressed: _pickExpiryDate,
                          ),
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
