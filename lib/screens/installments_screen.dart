import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/custom_widgets.dart';

class InstallmentsScreen extends StatefulWidget {
  final AppState state;
  final Function(String) onRecordPayment;
  final Function(String) onViewInvoice;

  const InstallmentsScreen({
    super.key,
    required this.state,
    required this.onRecordPayment,
    required this.onViewInvoice,
  });

  @override
  State<InstallmentsScreen> createState() => _InstallmentsScreenState();
}

class _InstallmentsScreenState extends State<InstallmentsScreen> {
  String _filter = 'All'; // 'All', 'Overdue', 'Pending'

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    // Plans with installments or credit
    final creditInvoices = state.invoices.where((inv) => inv.installmentAmount != null || inv.remainingBalance > 0).toList();

    final filtered = creditInvoices.where((inv) {
      if (_filter == 'Overdue') return inv.status == 'Overdue';
      if (_filter == 'Pending') return inv.status == 'Pending';
      return true;
    }).toList();

    final overdueCount = creditInvoices.where((inv) => inv.status == 'Overdue').length;
    final pendingCount = creditInvoices.where((inv) => inv.status == 'Pending').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Installments & Khata Credit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Overview Banner (Responsive Layout)
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 550) {
                  return Column(
                    children: [
                      KpiCard(
                        title: 'Total Outstanding Khata',
                        value: AppTheme.formatCurrency(state.totalOutstandingKhata),
                        icon: Icons.account_balance_wallet,
                        color: AppTheme.accentAmber,
                        bgTint: AppTheme.accentAmberLight,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: KpiCard(
                              title: 'Overdue Plans',
                              value: '$overdueCount',
                              icon: Icons.error_outline,
                              color: AppTheme.alertRed,
                              bgTint: AppTheme.alertRedLight,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: KpiCard(
                              title: 'Active Plans',
                              value: '$pendingCount',
                              icon: Icons.schedule,
                              color: AppTheme.secondaryBlue,
                              bgTint: AppTheme.secondaryBlueLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        title: 'Total Outstanding',
                        value: AppTheme.formatCurrency(state.totalOutstandingKhata),
                        icon: Icons.account_balance_wallet,
                        color: AppTheme.accentAmber,
                        bgTint: AppTheme.accentAmberLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: KpiCard(
                        title: 'Overdue Plans',
                        value: '$overdueCount',
                        icon: Icons.error_outline,
                        color: AppTheme.alertRed,
                        bgTint: AppTheme.alertRedLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: KpiCard(
                        title: 'Active Plans',
                        value: '$pendingCount',
                        icon: Icons.schedule,
                        color: AppTheme.secondaryBlue,
                        bgTint: AppTheme.secondaryBlueLight,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Filters
            Row(
              children: ['All', 'Overdue', 'Pending'].map((f) {
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(f, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : null)),
                    selected: isSelected,
                    selectedColor: f == 'Overdue' ? AppTheme.alertRed : (f == 'Pending' ? AppTheme.accentAmber : AppTheme.secondaryBlue),
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Credit & Installment Plans List
            if (filtered.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No installment accounts found in this filter.')),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final inv = filtered[index];

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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inv.customer.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${inv.customer.phone} · ${inv.customer.address}',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge(text: inv.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _infoItem('Invoice #', inv.invoiceNo),
                              _infoItem('Total Billed', AppTheme.formatCurrency(inv.grandTotal)),
                              _infoItem('Paid', AppTheme.formatCurrency(inv.paidAmount)),
                              _infoItem('Remaining', AppTheme.formatCurrency(inv.remainingBalance), isBold: true, color: AppTheme.alertRed),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Monthly: ${AppTheme.formatCurrency(inv.installmentAmount ?? (inv.remainingBalance / 3))} · Due: ${AppTheme.formatDate(inv.dueDate)}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: inv.status == 'Overdue' ? AppTheme.alertRed : AppTheme.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (inv.remainingBalance > 0) ...[
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => widget.onRecordPayment(inv.invoiceNo),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  icon: const Icon(Icons.payment, size: 14),
                                  label: const Text('Pay', style: TextStyle(fontSize: 12)),
                                ),
                              ],
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

  Widget _infoItem(String label, String value, {bool isBold = false, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color),
          ),
        ),
      ],
    );
  }
}
