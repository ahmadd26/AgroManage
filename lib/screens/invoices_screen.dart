import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/custom_widgets.dart';

class InvoicesScreen extends StatefulWidget {
  final AppState state;
  final Function(String) onViewInvoice;
  final VoidCallback onNewSale;

  const InvoicesScreen({
    super.key,
    required this.state,
    required this.onViewInvoice,
    required this.onNewSale,
  });

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  String _searchQuery = '';
  String _filter = 'All'; // 'All', 'Paid', 'Pending', 'Overdue'

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    final filtered = state.invoices.where((inv) {
      final matchesSearch = inv.invoiceNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          inv.customer.name.toLowerCase().contains(_searchQuery.toLowerCase());

      if (_filter == 'Paid') {
        return matchesSearch && inv.status == 'Paid';
      } else if (_filter == 'Pending') {
        return matchesSearch && inv.status == 'Pending';
      } else if (_filter == 'Overdue') {
        return matchesSearch && inv.status == 'Overdue';
      }
      return matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices & Bills'),
        actions: [
          ElevatedButton.icon(
            onPressed: widget.onNewSale,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            label: const Text('New Sale', style: TextStyle(fontSize: 12.5)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search invoice # or customer name...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),

          // Status Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Paid', 'Pending', 'Overdue'].map((f) {
                  final isSelected = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(f, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : null)),
                      selected: isSelected,
                      selectedColor: f == 'Overdue' ? AppTheme.alertRed : (f == 'Paid' ? AppTheme.primaryGreen : AppTheme.secondaryBlue),
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const Divider(height: 12),

          // Invoices List
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No invoices found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final inv = filtered[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => widget.onViewInvoice(inv.invoiceNo),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.secondaryBlueLight,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            inv.invoiceNo,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: AppTheme.secondaryBlue,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppTheme.formatDate(inv.date),
                                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                    StatusBadge(text: inv.status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            inv.customer.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${inv.items.length} items · Payment: ${inv.paymentMethod}',
                                            style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          AppTheme.formatCurrency(inv.grandTotal),
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                        ),
                                        if (inv.remainingBalance > 0)
                                          Text(
                                            'Due: ${AppTheme.formatCurrency(inv.remainingBalance)}',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: AppTheme.alertRed,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        else
                                          const Text(
                                            'Fully Settled',
                                            style: TextStyle(fontSize: 11, color: AppTheme.primaryGreenDark),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
