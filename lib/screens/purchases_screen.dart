import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/custom_widgets.dart';

class PurchasesScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onNewPurchase;
  final Function(String) onSelectSupplier;

  const PurchasesScreen({
    super.key,
    required this.state,
    required this.onNewPurchase,
    required this.onSelectSupplier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases & Stock Inward'),
        actions: [
          ElevatedButton.icon(
            onPressed: onNewPurchase,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Purchase', style: TextStyle(fontSize: 12.5)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Row
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Total Stock Inward',
                    value: AppTheme.formatCurrency(state.totalPurchases),
                    icon: Icons.inventory_2_outlined,
                    color: AppTheme.primaryGreen,
                    bgTint: AppTheme.primaryGreenLight,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: KpiCard(
                    title: 'Supplier Paid',
                    value: AppTheme.formatCurrency(state.totalPurchasesPaid),
                    icon: Icons.check_circle_outline,
                    color: AppTheme.secondaryBlue,
                    bgTint: AppTheme.secondaryBlueLight,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: KpiCard(
                    title: 'Payables (Due)',
                    value: AppTheme.formatCurrency(state.totalPurchases - state.totalPurchasesPaid),
                    icon: Icons.pending_actions_outlined,
                    color: AppTheme.alertRed,
                    bgTint: AppTheme.alertRedLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Purchase Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${state.purchases.length} Inward Deliveries', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),

            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.purchases.length,
              itemBuilder: (context, index) {
                final po = state.purchases[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreenLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    po.purchaseNo,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppTheme.primaryGreenDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppTheme.formatDate(po.date),
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                            StatusBadge(
                              text: po.isFullyPaid ? 'Settled' : 'Payment Due',
                              type: po.isFullyPaid ? 'g' : 'r',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          po.supplier.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Items Received: ${po.items.map((it) => '${it.product.name.split(" ").take(2).join(" ")} x${it.quantity}').join(", ")}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Cost: ${AppTheme.formatCurrency(po.grandTotal)}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              'Paid: ${AppTheme.formatCurrency(po.paidAmount)}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                            Text(
                              'Balance: ${AppTheme.formatCurrency(po.remainingBalance)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: po.remainingBalance > 0 ? AppTheme.alertRed : AppTheme.primaryGreenDark,
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
          ],
        ),
      ),
    );
  }
}
