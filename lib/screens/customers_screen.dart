import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/custom_widgets.dart';

class CustomersScreen extends StatefulWidget {
  final AppState state;
  final Function(String) onSelectCustomer;
  final VoidCallback onAddCustomer;

  const CustomersScreen({
    super.key,
    required this.state,
    required this.onSelectCustomer,
    required this.onAddCustomer,
  });

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _searchQuery = '';
  String _filterStatus = 'All'; // 'All', 'Dues Only', 'Clear'

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    final filtered = state.customers.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.phone.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.address.toLowerCase().contains(_searchQuery.toLowerCase());

      final bal = state.getCustomerBalance(c.id);
      if (_filterStatus == 'Dues Only') {
        return matchesSearch && bal > 0;
      } else if (_filterStatus == 'Clear') {
        return matchesSearch && bal <= 0;
      }
      return matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers / Farmers'),
        actions: [
          ElevatedButton.icon(
            onPressed: widget.onAddCustomer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.person_add_alt_1, size: 18),
            label: const Text('Add Farmer', style: TextStyle(fontSize: 12.5)),
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
                hintText: 'Search farmer by name, phone, village (chak)...',
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

          // Filters (Horizontally scrollable to prevent overflow)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Farmers'),
                    selected: _filterStatus == 'All',
                    onSelected: (_) => setState(() => _filterStatus = 'All'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('With Dues (Khata)'),
                    selected: _filterStatus == 'Dues Only',
                    selectedColor: AppTheme.accentAmber,
                    onSelected: (_) => setState(() => _filterStatus = 'Dues Only'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Cleared'),
                    selected: _filterStatus == 'Clear',
                    selectedColor: AppTheme.primaryGreen,
                    onSelected: (_) => setState(() => _filterStatus = 'Clear'),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 12),

          // Customer list
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No farmers found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      final billed = state.getCustomerBilled(c.id);
                      final paid = state.getCustomerPaid(c.id);
                      final balance = state.getCustomerBalance(c.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => widget.onSelectCustomer(c.id),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppTheme.secondaryBlueLight,
                                      foregroundColor: AppTheme.secondaryBlue,
                                      child: Text(
                                        c.name.substring(0, c.name.length >= 2 ? 2 : 1).toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${c.phone} · ${c.address}',
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(
                                      text: balance > 0 ? 'Balance due' : 'Clear',
                                      type: balance > 0 ? 'a' : 'g',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 8),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(child: _statMini('Total Billed', AppTheme.formatCurrency(billed))),
                                    const SizedBox(width: 6),
                                    Expanded(child: _statMini('Total Paid', AppTheme.formatCurrency(paid))),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _statMini(
                                        'Current Balance',
                                        AppTheme.formatCurrency(balance),
                                        color: balance > 0 ? AppTheme.alertRed : AppTheme.primaryGreenDark,
                                        isBold: true,
                                      ),
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

  Widget _statMini(String label, String value, {Color? color, bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
