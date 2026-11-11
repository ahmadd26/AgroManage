import 'product.dart';
import 'supplier.dart';

class PurchaseItem {
  final Product product;
  final int quantity;
  final double buyPrice;

  PurchaseItem({
    required this.product,
    required this.quantity,
    required this.buyPrice,
  });

  double get lineTotal => quantity * buyPrice;
}

class PurchaseOrder {
  final String purchaseNo;
  final Supplier supplier;
  final String date;
  final List<PurchaseItem> items;
  double paidAmount;
  final String notes;

  PurchaseOrder({
    required this.purchaseNo,
    required this.supplier,
    required this.date,
    required this.items,
    required this.paidAmount,
    this.notes = '',
  });

  double get grandTotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get remainingBalance => (grandTotal - paidAmount).clamp(0.0, double.infinity);
  bool get isFullyPaid => remainingBalance <= 0;
}
