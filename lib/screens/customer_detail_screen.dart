import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/customer.dart';
import '../widgets/custom_widgets.dart';

class CustomerDetailScreen extends StatelessWidget {
  final String customerId;
  final AppState state;
  final VoidCallback onBack;
  final Function(String) onViewInvoice;
  final Function(String) onRecordPayment;
  final Function(Customer) onNewSaleForCustomer;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
    required this.state,
    required this.onBack,
    required this.onViewInvoice,
    required this.onRecordPayment,
    required this.onNewSaleForCustomer,
  });

  void _showWhatsAppReminderDialog(BuildContext context, Customer customer, double balance) {
    final message = 'Assalam-o-Alaikum ${customer.name} Sahab, your outstanding khata balance at ${state.shopName} is ${AppTheme.formatCurrency(balance)}. Kindly clear the pending dues at your earliest convenience. Shukriya! - ${state.ownerName} (${state.phone})';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('WhatsApp Ledger Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Generated message for farmer:'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreenLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(message, style: const TextStyle(fontSize: 12.5)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder copied! Ready to send via WhatsApp.')),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Send / Copy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = state.customers.firstWhere(
      (c) => c.id == customerId,
      orElse: () => state.customers.first,
    );

    final billed = state.getCustomerBilled(customer.id);
    final paid = state.getCustomerPaid(customer.id);
    final balance = state.getCustomerBalance(customer.id);
    final history = state.getCustomerInvoices(customer.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: Text('${customer.name} · Ledger', overflow: TextOverflow.ellipsis),
        actions: [
          if (balance > 0)
            IconButton(
              tooltip: 'Send WhatsApp Reminder',
              icon: const Icon(Icons.chat_outlined, color: AppTheme.primaryGreen),
              onPressed: () => _showWhatsAppReminderDialog(context, customer, balance),
            ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.lightLine)),
        ),
        child: Row(
          children: [
            if (balance > 0) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onRecordPayment(history.isNotEmpty ? history.first.invoiceNo : ''),
                  icon: const Icon(Icons.payment, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Record Payment'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => onNewSaleForCustomer(customer),
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('New Sale'),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farmer Identity Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: AppTheme.primaryGreenLight,
                          foregroundColor: AppTheme.primaryGreenDark,
                          child: Icon(Icons.person, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${customer.phone} · ${customer.address}',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          text: balance > 0 ? 'Khata Active' : 'All Clear',
                          type: balance > 0 ? 'a' : 'g',
                        ),
                      ],
                    ),
                    if (customer.cnic.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 8),
                      const SizedBox(height: 6),
                      Text('CNIC: ${customer.cnic} · Credit Limit: ${AppTheme.formatCurrency(customer.creditLimit)}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Financial Balance Overview (Responsive KPI Grid)
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 550) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: KpiCard(
                              title: 'Total Billed',
                              value: AppTheme.formatCurrency(billed),
                              icon: Icons.receipt_long,
                              color: AppTheme.secondaryBlue,
                              bgTint: AppTheme.secondaryBlueLight,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: KpiCard(
                              title: 'Total Recovered',
                              value: AppTheme.formatCurrency(paid),
                              icon: Icons.check_circle_outline,
                              color: AppTheme.primaryGreen,
                              bgTint: AppTheme.primaryGreenLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      KpiCard(
                        title: 'Khata Due',
                        value: AppTheme.formatCurrency(balance),
                        icon: Icons.account_balance_wallet_outlined,
                        color: balance > 0 ? AppTheme.alertRed : AppTheme.primaryGreen,
                        bgTint: balance > 0 ? AppTheme.alertRedLight : AppTheme.primaryGreenLight,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        title: 'Total Billed',
                        value: AppTheme.formatCurrency(billed),
                        icon: Icons.receipt_long,
                        color: AppTheme.secondaryBlue,
                        bgTint: AppTheme.secondaryBlueLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: KpiCard(
                        title: 'Total Recovered',
                        value: AppTheme.formatCurrency(paid),
                        icon: Icons.check_circle_outline,
                        color: AppTheme.primaryGreen,
                        bgTint: AppTheme.primaryGreenLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: KpiCard(
                        title: 'Khata Due',
                        value: AppTheme.formatCurrency(balance),
                        icon: Icons.account_balance_wallet_outlined,
                        color: balance > 0 ? AppTheme.alertRed : AppTheme.primaryGreen,
                        bgTint: balance > 0 ? AppTheme.alertRedLight : AppTheme.primaryGreenLight,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Transaction History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Purchase & Invoice History',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${history.length} Transactions',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (history.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No previous purchases found for this farmer.')),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, i) {
                  final inv = history[i];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () => onViewInvoice(inv.invoiceNo),
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.secondaryBlueLight,
                        child: Icon(Icons.receipt, color: AppTheme.secondaryBlue, size: 20),
                      ),
                      title: Text(
                        '${inv.invoiceNo} · ${AppTheme.formatDate(inv.date)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        'Items: ${inv.items.map((it) => '${it.product.name.split(" ").take(2).join(" ")} x${it.quantity}').join(", ")}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppTheme.formatCurrency(inv.grandTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                          StatusBadge(text: inv.status),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
