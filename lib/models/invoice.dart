import 'customer.dart';
import 'product.dart';

class InvoiceItem {
  final Product product;
  int quantity;
  double unitPrice;

  InvoiceItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  double get lineTotal => quantity * unitPrice;
}

class SaleInvoice {
  final String invoiceNo;
  final Customer customer;
  final String date;
  final List<InvoiceItem> items;
  final double discount;
  double paidAmount;
  final String paymentMethod;
  final double? installmentAmount;
  final String? dueDate;
  final String notes;

  SaleInvoice({
    required this.invoiceNo,
    required this.customer,
    required this.date,
    required this.items,
    this.discount = 0.0,
    required this.paidAmount,
    this.paymentMethod = 'Cash',
    this.installmentAmount,
    this.dueDate,
    this.notes = '',
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get grandTotal => (subtotal - discount).clamp(0.0, double.infinity);
  double get remainingBalance => (grandTotal - paidAmount).clamp(0.0, double.infinity);
  bool get isFullyPaid => remainingBalance <= 0;

  String get status {
    if (isFullyPaid) return 'Paid';
    if (dueDate != null && dueDate!.isNotEmpty) {
      try {
        final due = DateTime.parse(dueDate!);
        final now = DateTime.now();
        if (now.isAfter(due)) return 'Overdue';
      } catch (_) {}
    }
    return 'Pending';
  }
}
