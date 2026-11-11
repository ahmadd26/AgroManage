import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/product.dart';
import '../widgets/custom_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final AppState state;
  final VoidCallback onBack;
  final Function(String) onEditProduct;
  final VoidCallback onSellProduct;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.state,
    required this.onBack,
    required this.onEditProduct,
    required this.onSellProduct,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  void _showAdjustStockDialog(Product product) {
    final controller = TextEditingController(text: '${product.stock}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Physical Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current inventory in shop: ${product.stock} ${product.unit}'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'New Stock Count',
                suffixText: 'units',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(controller.text) ?? product.stock;
              widget.state.adjustProductStock(product.id, newStock);
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stock count updated successfully!')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.state.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => widget.state.products.first,
    );

    final double stockRatio = (product.stock / (product.minStock * 2)).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => widget.onEditProduct(product.id),
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
                onPressed: () => _showAdjustStockDialog(product),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Adjust Stock'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.state.addCartLine(product);
                  widget.onSellProduct();
                },
                icon: const Icon(Icons.point_of_sale),
                label: const Text('Add to POS Sale'),
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
            // Top Product Badge Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryBlueLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              color: AppTheme.secondaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        StatusBadge(text: product.stockStatus),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unit / Packaging: ${product.unit} · SKU: AGRO-PR-${product.id.toUpperCase()}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Stock Level Gauge
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Inventory Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.stock} ${product.unit} Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: product.isLowStock ? AppTheme.alertRed : AppTheme.primaryGreenDark,
                          ),
                        ),
                        Text(
                          'Alert Level: ${product.minStock} ${product.unit}',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: stockRatio,
                        minHeight: 10,
                        backgroundColor: AppTheme.lightLine,
                        valueColor: AlwaysStoppedAnimation(
                          product.isLowStock ? AppTheme.alertRed : AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pricing & Profit Margin Analysis
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Commercial & Profit Margins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Divider(),
                    _infoRow('Retail Sale Price', AppTheme.formatCurrency(product.salePrice), isBold: true),
                    _infoRow('Purchase / Wholesale Cost', AppTheme.formatCurrency(product.buyPrice)),
                    _infoRow(
                      'Estimated Profit Margin',
                      '${AppTheme.formatCurrency(product.margin)} (${product.marginPercent.toStringAsFixed(1)}%)',
                      valueColor: AppTheme.primaryGreenDark,
                      isBold: true,
                    ),
                    _infoRow('Total Inventory Valuation', AppTheme.formatCurrency(product.stock * product.buyPrice)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Batch & Expiry Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quality & Expiry Compliance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Divider(),
                    _infoRow('Expiry Date', AppTheme.formatDate(product.expiryDate)),
                    _infoRow('Pesticide / Seed Registration', 'Punjab Agriculture Dept Compliant'),
                    _infoRow('Storage Recommendation', 'Keep in dry, cool warehouse godown'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13.5)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
