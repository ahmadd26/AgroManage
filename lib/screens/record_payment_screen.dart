import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/invoice.dart';

class RecordPaymentScreen extends StatefulWidget {
  final AppState state;
  final String? initialInvoiceNo;
  final VoidCallback onPaymentRecorded;
  final VoidCallback onCancel;

  const RecordPaymentScreen({
    super.key,
    required this.state,
    this.initialInvoiceNo,
    required this.onPaymentRecorded,
    required this.onCancel,
  });

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  SaleInvoice? _selectedInvoice;
  String _selectedMethod = 'Cash';

  final List<String> _methods = ['Cash', 'Bank Transfer', 'JazzCash', 'Easypaisa', 'Cheque'];

  @override
  void initState() {
    super.initState();
    final withBalance = widget.state.invoices.where((inv) => inv.remainingBalance > 0).toList();
    if (widget.initialInvoiceNo != null) {
      _selectedInvoice = widget.state.invoices.firstWhere(
        (inv) => inv.invoiceNo == widget.initialInvoiceNo,
        orElse: () => withBalance.isNotEmpty ? withBalance.first : widget.state.invoices.first,
      );
    } else if (withBalance.isNotEmpty) {
      _selectedInvoice = withBalance.first;
    }

    if (_selectedInvoice != null) {
      _amountController.text = _selectedInvoice!.remainingBalance.toStringAsFixed(0);
    }
  }

  void _savePayment() {
    if (_selectedInvoice == null) return;

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid payment amount.')),
      );
      return;
    }

    widget.state.recordPayment(
      invoiceNo: _selectedInvoice!.invoiceNo,
      amount: amount,
      method: _selectedMethod,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryGreen,
        content: Text('Payment of ${AppTheme.formatCurrency(amount)} recorded! Khata ledger updated.'),
      ),
    );

    widget.onPaymentRecorded();
  }

  @override
  Widget build(BuildContext context) {
    final withBalance = widget.state.invoices.where((inv) => inv.remainingBalance > 0).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onCancel),
        title: const Text('Record Customer Payment'),
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
                onPressed: _savePayment,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm Payment'),
              ),
            ),
          ],
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
                    const Text('Select Farmer & Invoice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 14),

                    // Invoice Dropdown
                    DropdownButtonFormField<SaleInvoice>(
                      initialValue: _selectedInvoice,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Invoice / Account with Pending Dues',
                        prefixIcon: Icon(Icons.receipt_outlined),
                      ),
                      items: (withBalance.isNotEmpty ? withBalance : widget.state.invoices).map((inv) {
                        return DropdownMenuItem(
                          value: inv,
                          child: Text(
                            '${inv.invoiceNo} · ${inv.customer.name} (Due: ${AppTheme.formatCurrency(inv.remainingBalance)})',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (inv) {
                        if (inv != null) {
                          setState(() {
                            _selectedInvoice = inv;
                            _amountController.text = inv.remainingBalance.toStringAsFixed(0);
                          });
                        }
                      },
                    ),

                    if (_selectedInvoice != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryBlueLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_selectedInvoice!.customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                Text('Total Billed: ${AppTheme.formatCurrency(_selectedInvoice!.grandTotal)}', style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Total Due', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                Text(
                                  AppTheme.formatCurrency(_selectedInvoice!.remainingBalance),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.alertRed),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    const Text('Payment Transaction Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 14),

                    // Amount Received
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount Received *',
                        prefixText: 'PKR ',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Payment Method
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Channel',
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      ),
                      items: _methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (m) {
                        if (m != null) setState(() => _selectedMethod = m);
                      },
                    ),

                    const SizedBox(height: 14),

                    // Cheque / Reference Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Transaction / Cheque Reference (Optional)',
                        hintText: 'e.g. JazzCash TID # 982181 or Cheque # 45112',
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
    );
  }
}
