import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/custom_widgets.dart';

class ReportsScreen extends StatefulWidget {
  final AppState state;

  const ReportsScreen({super.key, required this.state});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedTabIndex = 2; // Default to Profit & Loss

  final List<String> _tabs = [
    'Sales Report',
    'Purchase Report',
    'Profit / Loss',
    'Stock Valuation',
    'Khata Receivables',
    'Installments',
  ];

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    final double sales = state.totalSales;
    final double cogs = sales * 0.84; // 84% COGS
    final double grossProfit = sales - cogs;
    final double expenses = state.totalExpenses;
    final double netProfit = grossProfit - expenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Reports & Analytics'),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report generated and exported to PDF format!')),
              );
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export PDF', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final isSelected = _selectedTabIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_tabs[i], style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : null)),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryGreen,
                      onSelected: (_) => setState(() => _selectedTabIndex = i),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // Tab Content
            if (_selectedTabIndex == 2) ...[
              // Profit / Loss Statement
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 550) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: KpiCard(
                                title: 'Total Revenue',
                                value: AppTheme.formatCurrency(sales),
                                icon: Icons.trending_up,
                                color: AppTheme.secondaryBlue,
                                bgTint: AppTheme.secondaryBlueLight,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: KpiCard(
                                title: 'Gross Margin',
                                value: AppTheme.formatCurrency(grossProfit),
                                icon: Icons.pie_chart_outline,
                                color: AppTheme.primaryGreen,
                                bgTint: AppTheme.primaryGreenLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        KpiCard(
                          title: 'Net Profit',
                          value: AppTheme.formatCurrency(netProfit),
                          icon: Icons.account_balance,
                          color: AppTheme.primaryGreenDark,
                          bgTint: AppTheme.primaryGreenLight,
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          title: 'Total Revenue',
                          value: AppTheme.formatCurrency(sales),
                          icon: Icons.trending_up,
                          color: AppTheme.secondaryBlue,
                          bgTint: AppTheme.secondaryBlueLight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KpiCard(
                          title: 'Gross Margin',
                          value: AppTheme.formatCurrency(grossProfit),
                          icon: Icons.pie_chart_outline,
                          color: AppTheme.primaryGreen,
                          bgTint: AppTheme.primaryGreenLight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KpiCard(
                          title: 'Net Profit',
                          value: AppTheme.formatCurrency(netProfit),
                          icon: Icons.account_balance,
                          color: AppTheme.primaryGreenDark,
                          bgTint: AppTheme.primaryGreenLight,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly Profit & Loss Breakdown (PKR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      _reportRow('Gross Sales Revenue', AppTheme.formatCurrency(sales), isBold: true),
                      _reportRow('Cost of Goods Sold (COGS)', '- ${AppTheme.formatCurrency(cogs)}', color: AppTheme.textMuted),
                      const Divider(),
                      _reportRow('Gross Profit', AppTheme.formatCurrency(grossProfit), isBold: true, color: AppTheme.primaryGreenDark),
                      const SizedBox(height: 10),
                      const Text('Operating Expenses:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textMuted)),
                      ...state.expenses.map((e) => _reportRow('  ${e.title} (${e.category})', '- ${AppTheme.formatCurrency(e.amount)}', color: AppTheme.alertRed)),
                      const Divider(),
                      _reportRow('Total Operational Expenses', '- ${AppTheme.formatCurrency(expenses)}', color: AppTheme.alertRed, isBold: true),
                      const Divider(thickness: 1.5),
                      _reportRow('Net Shop Profit (Cleared)', AppTheme.formatCurrency(netProfit), isBold: true, fontSize: 17, color: AppTheme.primaryGreenDark),
                    ],
                  ),
                ),
              ),
            ] else if (_selectedTabIndex == 0) ...[
              // Sales Report
              Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      title: 'Total Sales Volume',
                      value: AppTheme.formatCurrency(state.totalSales),
                      icon: Icons.receipt,
                      color: AppTheme.secondaryBlue,
                      bgTint: AppTheme.secondaryBlueLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: KpiCard(
                      title: 'Total Bills Issued',
                      value: '${state.invoices.length}',
                      icon: Icons.numbers,
                      color: AppTheme.primaryGreen,
                      bgTint: AppTheme.primaryGreenLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.invoices.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final inv = state.invoices[i];
                    return ListTile(
                      title: Text(
                        '${inv.invoiceNo} · ${inv.customer.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${AppTheme.formatDate(inv.date)} · ${inv.paymentMethod}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(AppTheme.formatCurrency(inv.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    );
                  },
                ),
              ),
            ] else if (_selectedTabIndex == 3) ...[
              // Stock Valuation Report
              Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      title: 'Inventory Value',
                      value: AppTheme.formatCurrency(state.totalStockValue),
                      icon: Icons.warehouse_outlined,
                      color: AppTheme.primaryGreen,
                      bgTint: AppTheme.primaryGreenLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: KpiCard(
                      title: 'Catalog SKUs',
                      value: '${state.products.length}',
                      icon: Icons.category_outlined,
                      color: AppTheme.secondaryBlue,
                      bgTint: AppTheme.secondaryBlueLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = state.products[i];
                    return ListTile(
                      title: Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'In Stock: ${p.stock} ${p.unit} · Unit Cost: ${AppTheme.formatCurrency(p.buyPrice)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(AppTheme.formatCurrency(p.stock * p.buyPrice), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    );
                  },
                ),
              ),
            ] else ...[
              // Default Fallback table
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text('Report: ${_tabs[_selectedTabIndex]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      Text('Active records: ${state.customers.length} farmers with total outstanding balance ${AppTheme.formatCurrency(state.totalOutstandingKhata)}.'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _reportRow(String label, String value, {bool isBold = false, Color? color, double fontSize = 13.5}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
