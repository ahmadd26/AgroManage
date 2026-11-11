import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/custom_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  final AppState state;
  final Function(String) onSelectProduct;
  final Function(String) onViewInvoice;
  final VoidCallback onNewPurchase;

  const NotificationsScreen({
    super.key,
    required this.state,
    required this.onSelectProduct,
    required this.onViewInvoice,
    required this.onNewPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final lowStock = state.lowStockProducts;
    final expiring = state.expiringProducts;
    final overdue = state.overdueInvoices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Reminders'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Low Stock Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppTheme.alertRed, size: 22),
                    SizedBox(width: 8),
                    Text('Low Stock Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                TextButton(
                  onPressed: onNewPurchase,
                  child: const Text('Reorder Stock', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (lowStock.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('All stock levels are adequate.'),
                ),
              )
            else
              ...lowStock.map((p) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => onSelectProduct(p.id),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      subtitle: Text('Current Stock: ${p.stock} ${p.unit} · Min Threshold: ${p.minStock}'),
                      trailing: StatusBadge(text: '${p.stock} left', type: 'r'),
                    ),
                  )),

            const SizedBox(height: 20),

            // Expiry Section
            const Row(
              children: [
                Icon(Icons.timer_outlined, color: AppTheme.accentAmber, size: 22),
                SizedBox(width: 8),
                Text('Expiring Chemicals & Seeds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 6),
            if (expiring.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No items expiring within the next 90 days.'),
                ),
              )
            else
              ...expiring.map((p) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => onSelectProduct(p.id),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      subtitle: Text('Category: ${p.category} · Expiry Date: ${AppTheme.formatDate(p.expiryDate)}'),
                      trailing: const StatusBadge(text: 'Expiring soon', type: 'a'),
                    ),
                  )),

            const SizedBox(height: 20),

            // Overdue Installments Section
            const Row(
              children: [
                Icon(Icons.event_busy, color: AppTheme.alertRed, size: 22),
                SizedBox(width: 8),
                Text('Overdue Khata Plans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 6),
            if (overdue.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No overdue installments! All collections on track.'),
                ),
              )
            else
              ...overdue.map((inv) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => onViewInvoice(inv.invoiceNo),
                      title: Text('${inv.customer.name} · ${inv.invoiceNo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      subtitle: Text('Due: ${AppTheme.formatDate(inv.dueDate)} · Overdue Amount: ${AppTheme.formatCurrency(inv.remainingBalance)}'),
                      trailing: const StatusBadge(text: 'Overdue', type: 'r'),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
