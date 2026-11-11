import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/custom_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final AppState state;
  final Function(String) onNavigate;
  final Function(String) onViewInvoice;
  final Function(String) onViewCustomer;

  const DashboardScreen({
    super.key,
    required this.state,
    required this.onNavigate,
    required this.onViewInvoice,
    required this.onViewCustomer,
  });

  @override
  Widget build(BuildContext context) {
    final lowStock = state.lowStockProducts;
    final overdueList = state.overdueInvoices;
    final recentInvoices = state.invoices.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Welcome, ${state.ownerName} · ${AppTheme.formatDate(DateTime.now().toIso8601String().substring(0, 10))}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => onNavigate('notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => onNavigate('settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => onNavigate('pos'),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('New Sale (POS)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 6 KPI Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900 ? 6 : (constraints.maxWidth > 550 ? 3 : 2);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: constraints.maxWidth > 550 ? 1.35 : 1.05,
                  children: [
                    KpiCard(
                      title: 'Total Sales',
                      value: AppTheme.formatCurrency(state.totalSales),
                      icon: Icons.trending_up,
                      color: AppTheme.secondaryBlue,
                      bgTint: AppTheme.secondaryBlueLight,
                      onTap: () => onNavigate('invoices'),
                    ),
                    KpiCard(
                      title: 'Total Purchases',
                      value: AppTheme.formatCurrency(state.totalPurchases),
                      icon: Icons.inventory,
                      color: AppTheme.primaryGreen,
                      bgTint: AppTheme.primaryGreenLight,
                      onTap: () => onNavigate('purchases'),
                    ),
                    KpiCard(
                      title: 'Total Farmers',
                      value: '${state.customers.length}',
                      icon: Icons.people_outline,
                      color: AppTheme.secondaryBlue,
                      bgTint: AppTheme.secondaryBlueLight,
                      onTap: () => onNavigate('customers'),
                    ),
                    KpiCard(
                      title: 'Total Products',
                      value: '${state.products.length}',
                      icon: Icons.grass,
                      color: AppTheme.primaryGreen,
                      bgTint: AppTheme.primaryGreenLight,
                      onTap: () => onNavigate('products'),
                    ),
                    KpiCard(
                      title: 'Outstanding Khata',
                      value: AppTheme.formatCurrency(state.totalOutstandingKhata),
                      icon: Icons.credit_score,
                      color: AppTheme.accentAmber,
                      bgTint: AppTheme.accentAmberLight,
                      onTap: () => onNavigate('installments'),
                    ),
                    KpiCard(
                      title: 'Low Stock Alerts',
                      value: '${lowStock.length}',
                      icon: Icons.warning_amber_rounded,
                      color: AppTheme.alertRed,
                      bgTint: AppTheme.alertRedLight,
                      subtitle: 'Needs Order',
                      onTap: () => onNavigate('notifications'),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Sales Chart & Low Stock Alerts
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;

                final chartCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Sales Performance',
                                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => onNavigate('reports'),
                              icon: const Icon(Icons.analytics_outlined, size: 15),
                              label: const Text('Reports', style: TextStyle(fontSize: 11.5)),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const SalesBarChart(),
                      ],
                    ),
                  ),
                );

                final lowStockCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Low Stock Warnings',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () => onNavigate('products'),
                              child: const Text('View All', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const Divider(),
                        if (lowStock.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: Text('All products are well-stocked!')),
                          )
                        else
                          ...lowStock.take(4).map(
                                (p) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.name,
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Min Threshold: ${p.minStock} ${p.unit}',
                                              style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      StatusBadge(
                                        text: '${p.stock} left',
                                        type: 'r',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: chartCard),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: lowStockCard),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      chartCard,
                      const SizedBox(height: 12),
                      lowStockCard,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Recent Invoices & Pending Payments
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;

                final recentInvoicesCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Sales Invoices',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () => onNavigate('invoices'),
                              child: const Text('View All Invoices', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const Divider(),
                        ...recentInvoices.map(
                          (inv) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            onTap: () => onViewInvoice(inv.invoiceNo),
                            leading: const CircleAvatar(
                              backgroundColor: AppTheme.primaryGreenLight,
                              foregroundColor: AppTheme.primaryGreenDark,
                              child: Icon(Icons.receipt, size: 18),
                            ),
                            title: Text(
                              '${inv.invoiceNo} · ${inv.customer.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            subtitle: Text(
                              '${AppTheme.formatDate(inv.date)} · ${inv.paymentMethod}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppTheme.formatCurrency(inv.grandTotal),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                StatusBadge(text: inv.status),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                final pendingKhataCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pending Khata / Dues',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () => onNavigate('installments'),
                              child: const Text('Khata Ledger', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const Divider(),
                        if (overdueList.isEmpty && state.pendingInvoices.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: Text('No pending payments!')),
                          )
                        else
                          ...[...overdueList, ...state.pendingInvoices].take(5).map(
                                (inv) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  onTap: () => onViewCustomer(inv.customer.id),
                                  leading: CircleAvatar(
                                    backgroundColor: inv.status == 'Overdue'
                                        ? AppTheme.alertRedLight
                                        : AppTheme.accentAmberLight,
                                    foregroundColor: inv.status == 'Overdue'
                                        ? AppTheme.alertRed
                                        : AppTheme.accentAmber,
                                    child: Icon(
                                      inv.status == 'Overdue' ? Icons.priority_high : Icons.hourglass_top,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    inv.customer.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  subtitle: Text(
                                    'Due: ${AppTheme.formatDate(inv.dueDate)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        AppTheme.formatCurrency(inv.remainingBalance),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppTheme.alertRed,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      StatusBadge(text: inv.status),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: recentInvoicesCard),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: pendingKhataCard),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      recentInvoicesCard,
                      const SizedBox(height: 12),
                      pendingKhataCard,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 60), // Space for FAB
          ],
        ),
      ),
    );
  }
}
