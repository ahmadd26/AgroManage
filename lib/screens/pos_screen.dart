import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/customer.dart';
import '../models/product.dart';

class PosScreen extends StatefulWidget {
  final AppState state;
  final Function(String) onInvoiceGenerated;
  final VoidCallback onAddCustomer;

  const PosScreen({
    super.key,
    required this.state,
    required this.onInvoiceGenerated,
    required this.onAddCustomer,
  });

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _discountController = TextEditingController(text: '0');
  final _paidController = TextEditingController(text: '0');
  Customer? _selectedCustomer;
  String _selectedPaymentMethod = 'Cash';

  @override
  void initState() {
    super.initState();
    if (widget.state.customers.isNotEmpty) {
      _selectedCustomer = widget.state.customers.first;
    }
    // Update paid amount when cart loads
    _paidController.text = widget.state.cartGrandTotal.toStringAsFixed(0);
  }

  void _recalc() {
    setState(() {});
  }

  void _onDiscountChanged(String val) {
    widget.state.discount = double.tryParse(val) ?? 0.0;
    if (_selectedPaymentMethod != 'Credit') {
      _paidController.text = widget.state.cartGrandTotal.toStringAsFixed(0);
      widget.state.paidAmount = widget.state.cartGrandTotal;
    }
    _recalc();
  }

  void _onPaidChanged(String val) {
    widget.state.paidAmount = double.tryParse(val) ?? 0.0;
    _recalc();
  }

  void _onPaymentMethodSelected(String method) {
    setState(() {
      _selectedPaymentMethod = method;
      if (method == 'Credit') {
        _paidController.text = '0';
        widget.state.paidAmount = 0.0;
      } else {
        _paidController.text = widget.state.cartGrandTotal.toStringAsFixed(0);
        widget.state.paidAmount = widget.state.cartGrandTotal;
      }
    });
  }

  void _handleCheckout() {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a farmer/customer.')),
      );
      return;
    }
    if (widget.state.cartLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product to the sale.')),
      );
      return;
    }

    final double discount = double.tryParse(_discountController.text) ?? 0.0;
    final double total = widget.state.cartGrandTotal;
    double paid = double.tryParse(_paidController.text) ?? 0.0;

    if (_selectedPaymentMethod != 'Credit' && paid <= 0) {
      paid = total;
    }

    String? dueDate;
    double? installment;

    if (total > paid) {
      final now = DateTime.now();
      dueDate = now.add(const Duration(days: 30)).toIso8601String().substring(0, 10);
      installment = ((total - paid) / 3).roundToDouble();
    }

    final invoice = widget.state.createSale(
      customer: _selectedCustomer!,
      disc: discount,
      paid: paid.clamp(0.0, total),
      method: _selectedPaymentMethod,
      dueDate: dueDate,
      installment: installment,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryGreen,
        content: Text('Sale Completed! Invoice #${invoice.invoiceNo} generated.'),
      ),
    );

    widget.onInvoiceGenerated(invoice.invoiceNo);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale (POS)'),
        actions: [
          IconButton(
            tooltip: 'Clear Cart',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () {
              state.resetCart();
              _discountController.text = '0';
              _paidController.text = '0';
              _recalc();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 850;

          final cartSection = Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Selection Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Customer / Farmer',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<Customer>(
                              initialValue: _selectedCustomer,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_outline, size: 20),
                              ),
                              items: state.customers.map((c) {
                                final bal = state.getCustomerBalance(c.id);
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    '${c.name} (${c.address}) ${bal > 0 ? "· Bal: ${AppTheme.formatCurrency(bal)}" : ""}',
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (c) => setState(() => _selectedCustomer = c),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: widget.onAddCustomer,
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: const Text('Add Farmer', style: TextStyle(fontSize: 12.5)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Cart Items Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Items in Sale',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (state.products.isNotEmpty) {
                            state.addCartLine(state.products.first);
                            _recalc();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Product', style: TextStyle(fontSize: 12.5)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Cart Items List
                  if (state.cartLines.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: const Text('No products in cart. Click "Add Product" above.'),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.cartLines.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final line = state.cartLines[index];

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product dropdown
                            Expanded(
                              flex: 4,
                              child: DropdownButtonFormField<Product>(
                                initialValue: line.product,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: state.products.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      '${p.name} (Stk: ${p.stock})',
                                      style: const TextStyle(fontSize: 12.5),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (p) {
                                  if (p != null) {
                                    setState(() {
                                      line.product = p;
                                      line.price = p.salePrice;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Quantity Stepper
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () {
                                    state.updateCartLineQuantity(index, line.quantity - 1);
                                    _recalc();
                                  },
                                ),
                                Text(
                                  '${line.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () {
                                    state.updateCartLineQuantity(index, line.quantity + 1);
                                    _recalc();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),

                            // Line Total
                            Expanded(
                              flex: 2,
                              child: Text(
                                AppTheme.formatCurrency(line.lineTotal),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.close, color: AppTheme.alertRed, size: 18),
                              onPressed: () {
                                state.removeCartLine(index);
                                _recalc();
                              },
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          );

          final summarySection = Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(),

                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(color: AppTheme.textMuted)),
                      Text(
                        AppTheme.formatCurrency(state.cartSubtotal),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Discount
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Discount (PKR)', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          onChanged: _onDiscountChanged,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  // Grand Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Text(
                        AppTheme.formatCurrency(state.cartGrandTotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppTheme.primaryGreenDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Payment Method Selector
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Cash', 'Bank', 'JazzCash', 'Easypaisa', 'Credit'].map((m) {
                      final isSelected = m == _selectedPaymentMethod;
                      return ChoiceChip(
                        label: Text(m, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : null)),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryGreen,
                        onSelected: (_) => _onPaymentMethodSelected(m),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Amount Paid
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Paid Amount (PKR)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: _paidController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          onChanged: _onPaidChanged,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Remaining Balance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Remaining (Khata)', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        AppTheme.formatCurrency(state.cartRemaining),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: state.cartRemaining > 0 ? AppTheme.alertRed : AppTheme.primaryGreenDark,
                        ),
                      ),
                    ],
                  ),

                  // Installment Plan alert if remaining
                  if (state.cartRemaining > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAmberLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.accentAmber, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Installment Plan generated: ~${AppTheme.formatCurrency(state.cartRemaining / 3)} / month for 3 months.',
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF78350F), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _handleCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.receipt_long, color: Colors.white),
                      label: const Text(
                        'Save Sale & Print Bill',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: cartSection),
                      const SizedBox(width: 14),
                      Expanded(flex: 2, child: summarySection),
                    ],
                  )
                : Column(
                    children: [
                      cartSection,
                      const SizedBox(height: 14),
                      summarySection,
                    ],
                  ),
          );
        },
      ),
    );
  }
}
