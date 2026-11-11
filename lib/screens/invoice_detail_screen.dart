import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/custom_widgets.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceNo;
  final AppState state;
  final VoidCallback onBack;
  final Function(String) onRecordPayment;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceNo,
    required this.state,
    required this.onBack,
    required this.onRecordPayment,
  });

  void _showPrintSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.primaryGreen,
        content: Text('Sent to thermal receipt / A4 printer!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoice = state.invoices.firstWhere(
      (inv) => inv.invoiceNo == invoiceNo,
      orElse: () => state.invoices.first,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: Text('Invoice ${invoice.invoiceNo}'),
        actions: [
          IconButton(
            tooltip: 'Print Thermal Receipt',
            icon: const Icon(Icons.print_outlined),
            onPressed: () => _showPrintSuccess(context),
          ),
          IconButton(
            tooltip: 'Share Bill',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _showPrintSuccess(context),
          ),
          const SizedBox(width: 8),
        ],
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
              child: OutlinedButton.icon(
                onPressed: () => _showPrintSuccess(context),
                icon: const Icon(Icons.print),
                label: const Text('Print Receipt'),
              ),
            ),
            if (invoice.remainingBalance > 0) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onRecordPayment(invoice.invoiceNo),
                  icon: const Icon(Icons.payment),
                  label: const Text('Record Payment'),
                ),
              ),
            ],
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Official Letterhead
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.secondaryBlue, AppTheme.primaryGreen],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.eco, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.shopName,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                              ),
                              Text(
                                '${state.address} · Phone: ${state.phone}',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                              ),
                              Text(
                                'NTN: ${state.ntn} · Govt. Seed & Fertilizer License # 4521/SWL',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'SALES INVOICE',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: AppTheme.primaryGreenDark,
                              ),
                            ),
                            Text(
                              invoice.invoiceNo,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'Date: ${AppTheme.formatDate(invoice.date)}',
                              style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 10),

                    // Bill To & Payment Method Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Billed To (Farmer):', style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 3),
                            Text(invoice.customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('${invoice.customer.address}\nPhone: ${invoice.customer.phone}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Payment Channel:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 3),
                            Text(invoice.paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            StatusBadge(text: invoice.status),
                            if (invoice.dueDate != null && invoice.dueDate!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Due Date: ${AppTheme.formatDate(invoice.dueDate)}', style: const TextStyle(fontSize: 11, color: AppTheme.alertRed, fontWeight: FontWeight.w600)),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Items Table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.lightLine),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: AppTheme.lightBg,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: const Row(
                              children: [
                                SizedBox(width: 24, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppTheme.textMuted))),
                                Expanded(child: Text('Item Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppTheme.textMuted))),
                                SizedBox(width: 50, child: Text('Qty', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppTheme.textMuted))),
                                SizedBox(width: 80, child: Text('Rate', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppTheme.textMuted))),
                                SizedBox(width: 90, child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppTheme.textMuted))),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          ...List.generate(invoice.items.length, (i) {
                            final item = invoice.items[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  SizedBox(width: 24, child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                        Text(item.product.category, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 50, child: Text('${item.quantity}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12.5))),
                                  SizedBox(width: 80, child: Text(AppTheme.formatCurrency(item.unitPrice), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                                  SizedBox(width: 90, child: Text(AppTheme.formatCurrency(item.lineTotal), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Financial Totals
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 280,
                        child: Column(
                          children: [
                            _calcRow('Subtotal', AppTheme.formatCurrency(invoice.subtotal)),
                            if (invoice.discount > 0)
                              _calcRow('Discount', '- ${AppTheme.formatCurrency(invoice.discount)}'),
                            const Divider(),
                            _calcRow('Grand Total', AppTheme.formatCurrency(invoice.grandTotal), isBold: true, fontSize: 15),
                            _calcRow('Amount Paid', AppTheme.formatCurrency(invoice.paidAmount), color: AppTheme.primaryGreenDark),
                            _calcRow(
                              'Balance Remaining',
                              AppTheme.formatCurrency(invoice.remainingBalance),
                              color: invoice.remainingBalance > 0 ? AppTheme.alertRed : AppTheme.primaryGreenDark,
                              isBold: true,
                              fontSize: 15,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(),

                    // Footer Disclaimers
                    Center(
                      child: Text(
                        state.invoiceFooter,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _calcRow(String label, String value, {bool isBold = false, Color? color, double fontSize = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: AppTheme.textMuted)),
          Text(value, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
