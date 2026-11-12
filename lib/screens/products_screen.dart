import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/custom_widgets.dart';

class ProductsScreen extends StatefulWidget {
  final AppState state;
  final Function(String) onSelectProduct;
  final VoidCallback onAddProduct;

  const ProductsScreen({
    super.key,
    required this.state,
    required this.onSelectProduct,
    required this.onAddProduct,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Seeds',
    'Fertilizers',
    'Pesticides',
    'Herbicides',
    'Fungicides',
    'Tools',
  ];

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    final filtered = state.products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products & Inventory'),
        actions: [
          ElevatedButton.icon(
            onPressed: widget.onAddProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Product', style: TextStyle(fontSize: 12.5)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Toolbar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products by name, formula, or brand...',
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

          // Categories Horizontal List
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isSelected ? Colors.white : null)),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryGreen,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // Product Count & Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Showing ${filtered.length} products',
                    style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Stock Value: ${AppTheme.formatCurrency(state.totalStockValue)}',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark),
                ),
              ],
            ),
          ),

          const Divider(height: 12),

          // Product List
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No products found matching your search.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final p = filtered[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => widget.onSelectProduct(p.id),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                // Category Icon
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: p.isLowStock
                                        ? AppTheme.alertRedLight
                                        : AppTheme.primaryGreenLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    p.category == 'Seeds'
                                        ? Icons.grain
                                        : (p.category == 'Fertilizers'
                                            ? Icons.science_outlined
                                            : Icons.bug_report_outlined),
                                    color: p.isLowStock
                                        ? AppTheme.alertRed
                                        : AppTheme.primaryGreenDark,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Product info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          StatusBadge(text: p.stockStatus),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              p.category,
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Stock: ${p.stock} ${p.unit} (Min ${p.minStock})',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: p.isLowStock ? AppTheme.alertRed : AppTheme.textMuted,
                                              fontWeight: p.isLowStock ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 2,
                                        alignment: WrapAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Sale: ${AppTheme.formatCurrency(p.salePrice)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12.5,
                                              color: AppTheme.primaryGreenDark,
                                            ),
                                          ),
                                          Text(
                                            'Cost: ${AppTheme.formatCurrency(p.buyPrice)}',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                          if (p.expiryDate.isNotEmpty)
                                            Text(
                                              'Exp: ${AppTheme.formatDate(p.expiryDate)}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: p.isExpiringSoon ? AppTheme.accentAmber : AppTheme.textMuted,
                                                fontWeight: p.isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
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
