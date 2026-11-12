import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/supplier.dart';
import '../models/invoice.dart';
import '../models/purchase.dart';
import '../models/expense.dart';

class CartLine {
  Product product;
  int quantity;
  double price;

  CartLine({
    required this.product,
    required this.quantity,
    required this.price,
  });

  double get lineTotal => quantity * price;
}

class AppState extends ChangeNotifier {
  // Theme state
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Shop Profile Information
  String shopName = 'Kisan Agro Center';
  String ownerName = 'Ahmad Khan';
  String phone = '0300-1234567';
  String ntn = '1234567-8';
  String address = 'Main GT Road, Sahiwal, Punjab';
  String invoiceFooter = 'Thank you for your business. Goods once sold are not returnable.';

  void updateShopSettings({
    required String name,
    required String owner,
    required String shopPhone,
    required String shopNtn,
    required String shopAddress,
    required String footer,
  }) {
    shopName = name;
    ownerName = owner;
    phone = shopPhone;
    ntn = shopNtn;
    address = shopAddress;
    invoiceFooter = footer;
    notifyListeners();
  }

  // Lists
  List<Product> products = [];
  List<Customer> customers = [];
  List<Supplier> suppliers = [];
  List<SaleInvoice> invoices = [];
  List<PurchaseOrder> purchases = [];
  List<Expense> expenses = [];

  // Active POS Cart
  Customer? selectedCustomer;
  List<CartLine> cartLines = [];
  double discount = 0.0;
  double paidAmount = 0.0;
  String paymentMethod = 'Cash';

  AppState() {
    _initializeSeedData();
  }

  void _initializeSeedData() {
    // 1. Customers
    customers = [
      Customer(id: 'c1', name: 'Muhammad Aslam', phone: '0300-6621845', address: 'Chak 45 GB, Faisalabad', cnic: '33100-1234567-1'),
      Customer(id: 'c2', name: 'Rana Tariq Mehmood', phone: '0321-4417830', address: 'Okara', cnic: '35302-8876123-3'),
      Customer(id: 'c3', name: 'Ch. Imran Ali', phone: '0333-7120934', address: 'Sahiwal', cnic: '39101-5544332-1'),
      Customer(id: 'c4', name: 'Haji Bashir Ahmad', phone: '0345-8812067', address: 'Vehari', cnic: '36603-9988771-5'),
      Customer(id: 'c5', name: 'Malik Khalid Hussain', phone: '0301-2275519', address: 'Multan', cnic: '36302-1122334-9'),
      Customer(id: 'c6', name: 'Sajid Iqbal', phone: '0312-9034471', address: 'Pakpattan', cnic: '35301-7766554-3'),
      Customer(id: 'c7', name: 'Zafar Iqbal Cheema', phone: '0322-5560183', address: 'Toba Tek Singh', cnic: '33303-4455667-7'),
      Customer(id: 'c8', name: 'Ghulam Rasool', phone: '0307-1148276', address: 'Khanewal', cnic: '36102-9988221-1'),
    ];

    // 2. Products
    products = [
      Product(id: 'p1', name: 'Pioneer 30T60 Hybrid Maize Seed 10kg', category: 'Seeds', buyPrice: 11200, salePrice: 12500, stock: 48, minStock: 20, expiryDate: '2027-03-31', unit: 'Bags'),
      Product(id: 'p2', name: 'Akbar-19 Wheat Seed 40kg', category: 'Seeds', buyPrice: 8600, salePrice: 9200, stock: 120, minStock: 40, expiryDate: '2027-06-30', unit: 'Bags'),
      Product(id: 'p3', name: 'Urea (Sona) 50kg', category: 'Fertilizers', buyPrice: 4350, salePrice: 4600, stock: 210, minStock: 80, unit: 'Bags'),
      Product(id: 'p4', name: 'DAP (Engro) 50kg', category: 'Fertilizers', buyPrice: 11800, salePrice: 12300, stock: 36, minStock: 40, unit: 'Bags'),
      Product(id: 'p5', name: 'Confidor 200SL 250ml', category: 'Pesticides', buyPrice: 1450, salePrice: 1700, stock: 64, minStock: 25, expiryDate: '2028-02-28', unit: 'Bottles'),
      Product(id: 'p6', name: 'Karate 2.5EC 500ml', category: 'Pesticides', buyPrice: 2100, salePrice: 2450, stock: 18, minStock: 20, expiryDate: '2027-11-30', unit: 'Bottles'),
      Product(id: 'p7', name: 'Touchdown Glyphosate 1L', category: 'Herbicides', buyPrice: 1650, salePrice: 1950, stock: 55, minStock: 20, expiryDate: '2028-05-31', unit: 'Bottles'),
      Product(id: 'p8', name: 'Nativo 75WG 100g', category: 'Fungicides', buyPrice: 1900, salePrice: 2250, stock: 9, minStock: 15, expiryDate: '2026-12-15', unit: 'Packs'),
      Product(id: 'p9', name: 'Knapsack Sprayer 16L Manual', category: 'Tools', buyPrice: 3800, salePrice: 4500, stock: 14, minStock: 5, unit: 'Units'),
      Product(id: 'p10', name: 'MNH-886 Cotton Seed 5kg', category: 'Seeds', buyPrice: 4200, salePrice: 4800, stock: 72, minStock: 30, expiryDate: '2027-04-30', unit: 'Bags'),
      Product(id: 'p11', name: 'Topik 15WP 160g', category: 'Herbicides', buyPrice: 1250, salePrice: 1500, stock: 40, minStock: 15, expiryDate: '2027-08-31', unit: 'Packs'),
    ];

    // 3. Suppliers
    suppliers = [
      Supplier(id: 's1', name: 'Engro Fertilizers (Dealer)', phone: '042-111-436-476', city: 'Lahore', representative: 'Malik Tariq'),
      Supplier(id: 's2', name: 'Syngenta Pakistan – Lahore', phone: '042-35761234', city: 'Lahore', representative: 'Hamid Raza'),
      Supplier(id: 's3', name: 'Corteva / Pioneer Seeds – Multan', phone: '061-4586120', city: 'Multan', representative: 'Khurram Shehzad'),
      Supplier(id: 's4', name: 'Jaffer Agro Services', phone: '021-111-523-337', city: 'Karachi', representative: 'M. Ali'),
      Supplier(id: 's5', name: 'Bayer CropScience Pakistan', phone: '042-35712890', city: 'Lahore', representative: 'Salman Yousaf'),
      Supplier(id: 's6', name: 'Agri Tools Traders – Faisalabad', phone: '041-2630455', city: 'Faisalabad', representative: 'Sheikh Usman'),
    ];

    // 4. Invoices
    invoices = [
      SaleInvoice(
        invoiceNo: 'AGR-2026-0142',
        customer: customers[0],
        date: '2026-10-06',
        items: [
          InvoiceItem(product: products[3], quantity: 4, unitPrice: 12300),
          InvoiceItem(product: products[2], quantity: 10, unitPrice: 4600),
        ],
        discount: 0,
        paidAmount: 50000,
        paymentMethod: 'Credit',
        installmentAmount: 15000,
        dueDate: '2026-10-25',
      ),
      SaleInvoice(
        invoiceNo: 'AGR-2026-0141',
        customer: customers[1],
        date: '2026-10-05',
        items: [
          InvoiceItem(product: products[0], quantity: 2, unitPrice: 12500),
          InvoiceItem(product: products[4], quantity: 3, unitPrice: 1700),
        ],
        discount: 500,
        paidAmount: 29600,
        paymentMethod: 'Cash',
      ),
      SaleInvoice(
        invoiceNo: 'AGR-2026-0140',
        customer: customers[2],
        date: '2026-10-03',
        items: [
          InvoiceItem(product: products[1], quantity: 10, unitPrice: 9200),
          InvoiceItem(product: products[2], quantity: 20, unitPrice: 4600),
        ],
        discount: 2000,
        paidAmount: 100000,
        paymentMethod: 'Bank',
        installmentAmount: 20000,
        dueDate: '2026-10-01', // Overdue
      ),
      SaleInvoice(
        invoiceNo: 'AGR-2026-0139',
        customer: customers[3],
        date: '2026-09-29',
        items: [
          InvoiceItem(product: products[8], quantity: 2, unitPrice: 4500),
          InvoiceItem(product: products[5], quantity: 4, unitPrice: 2450),
          InvoiceItem(product: products[6], quantity: 3, unitPrice: 1950),
        ],
        discount: 0,
        paidAmount: 24650,
        paymentMethod: 'JazzCash',
      ),
      SaleInvoice(
        invoiceNo: 'AGR-2026-0138',
        customer: customers[4],
        date: '2026-09-25',
        items: [
          InvoiceItem(product: products[9], quantity: 8, unitPrice: 4800),
          InvoiceItem(product: products[3], quantity: 6, unitPrice: 12300),
        ],
        discount: 1000,
        paidAmount: 70000,
        paymentMethod: 'Credit',
        installmentAmount: 10000,
        dueDate: '2026-10-20',
      ),
      SaleInvoice(
        invoiceNo: 'AGR-2026-0137',
        customer: customers[5],
        date: '2026-09-20',
        items: [
          InvoiceItem(product: products[7], quantity: 6, unitPrice: 2250),
          InvoiceItem(product: products[10], quantity: 4, unitPrice: 1500),
        ],
        discount: 0,
        paidAmount: 19500,
        paymentMethod: 'Easypaisa',
      ),
      SaleInvoice(
        invoiceNo: 'AGR-2026-0136',
        customer: customers[6],
        date: '2026-09-12',
        items: [
          InvoiceItem(product: products[0], quantity: 6, unitPrice: 12500),
          InvoiceItem(product: products[3], quantity: 10, unitPrice: 12300),
        ],
        discount: 3000,
        paidAmount: 95000,
        paymentMethod: 'Credit',
        installmentAmount: 25000,
        dueDate: '2026-09-30', // Overdue
      ),
    ];

    // 5. Purchases
    purchases = [
      PurchaseOrder(
        purchaseNo: 'PUR-0087',
        supplier: suppliers[0],
        date: '2026-10-02',
        items: [
          PurchaseItem(product: products[2], quantity: 200, buyPrice: 4350),
          PurchaseItem(product: products[3], quantity: 60, buyPrice: 11800),
        ],
        paidAmount: 1400000,
      ),
      PurchaseOrder(
        purchaseNo: 'PUR-0086',
        supplier: suppliers[2],
        date: '2026-09-27',
        items: [
          PurchaseItem(product: products[0], quantity: 40, buyPrice: 11200),
          PurchaseItem(product: products[9], quantity: 50, buyPrice: 4200),
        ],
        paidAmount: 500000,
      ),
      PurchaseOrder(
        purchaseNo: 'PUR-0085',
        supplier: suppliers[1],
        date: '2026-09-20',
        items: [
          PurchaseItem(product: products[4], quantity: 60, buyPrice: 1450),
          PurchaseItem(product: products[10], quantity: 40, buyPrice: 1250),
        ],
        paidAmount: 137000,
      ),
      PurchaseOrder(
        purchaseNo: 'PUR-0084',
        supplier: suppliers[4],
        date: '2026-09-14',
        items: [
          PurchaseItem(product: products[5], quantity: 40, buyPrice: 2100),
          PurchaseItem(product: products[7], quantity: 30, buyPrice: 1900),
        ],
        paidAmount: 141000,
      ),
      PurchaseOrder(
        purchaseNo: 'PUR-0083',
        supplier: suppliers[5],
        date: '2026-09-05',
        items: [
          PurchaseItem(product: products[8], quantity: 10, buyPrice: 3800),
        ],
        paidAmount: 38000,
      ),
    ];

    // 6. Expenses
    expenses = [
      Expense(id: 'e1', title: 'Shop Godown Rent', category: 'Rent', amount: 45000, date: '2026-10-01'),
      Expense(id: 'e2', title: 'Solar Inverter & Tube-well Units', category: 'Utilities', amount: 28500, date: '2026-10-03'),
      Expense(id: 'e3', title: 'Staff & Helper Monthly Salaries', category: 'Salaries', amount: 90000, date: '2026-10-04'),
      Expense(id: 'e4', title: 'Truck Freight / Grain Market Loader', category: 'Transport', amount: 32000, date: '2026-10-05'),
    ];

    // Default Cart initialized with 1 item
    cartLines = [
      CartLine(product: products[2], quantity: 10, price: products[2].salePrice),
    ];
  }

  // Analytics & Calculations
  double get totalSales => invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
  double get totalSalesCollected => invoices.fold(0.0, (sum, inv) => sum + inv.paidAmount);
  double get totalPurchases => purchases.fold(0.0, (sum, p) => sum + p.grandTotal);
  double get totalPurchasesPaid => purchases.fold(0.0, (sum, p) => sum + p.paidAmount);
  double get totalOutstandingKhata => invoices.fold(0.0, (sum, inv) => sum + inv.remainingBalance);
  double get totalExpenses => expenses.fold(0.0, (sum, exp) => sum + exp.amount);
  double get totalStockValue => products.fold(0.0, (sum, p) => sum + (p.stock * p.buyPrice));

  List<Product> get lowStockProducts => products.where((p) => p.isLowStock || p.isOutOfStock).toList();
  List<Product> get expiringProducts => products.where((p) => p.isExpiringSoon).toList();
  List<SaleInvoice> get overdueInvoices => invoices.where((inv) => inv.status == 'Overdue').toList();
  List<SaleInvoice> get pendingInvoices => invoices.where((inv) => inv.status == 'Pending').toList();

  // Customer Ledger Calculations
  double getCustomerBilled(String customerId) {
    return invoices
        .where((inv) => inv.customer.id == customerId)
        .fold(0.0, (sum, inv) => sum + inv.grandTotal);
  }

  double getCustomerPaid(String customerId) {
    return invoices
        .where((inv) => inv.customer.id == customerId)
        .fold(0.0, (sum, inv) => sum + inv.paidAmount);
  }

  double getCustomerBalance(String customerId) {
    return (getCustomerBilled(customerId) - getCustomerPaid(customerId)).clamp(0.0, double.infinity);
  }

  List<SaleInvoice> getCustomerInvoices(String customerId) {
    return invoices.where((inv) => inv.customer.id == customerId).toList();
  }

  // Supplier Ledger Calculations
  double getSupplierPurchased(String supplierId) {
    return purchases
        .where((p) => p.supplier.id == supplierId)
        .fold(0.0, (sum, p) => sum + p.grandTotal);
  }

  double getSupplierPaid(String supplierId) {
    return purchases
        .where((p) => p.supplier.id == supplierId)
        .fold(0.0, (sum, p) => sum + p.paidAmount);
  }

  double getSupplierBalance(String supplierId) {
    return (getSupplierPurchased(supplierId) - getSupplierPaid(supplierId)).clamp(0.0, double.infinity);
  }

  // Cart Management
  double get cartSubtotal => cartLines.fold(0.0, (sum, line) => sum + line.lineTotal);
  double get cartGrandTotal => (cartSubtotal - discount).clamp(0.0, double.infinity);
  double get cartRemaining => (cartGrandTotal - paidAmount).clamp(0.0, double.infinity);

  void addCartLine(Product product) {
    final existing = cartLines.indexWhere((l) => l.product.id == product.id);
    if (existing >= 0) {
      cartLines[existing].quantity += 1;
    } else {
      cartLines.add(CartLine(product: product, quantity: 1, price: product.salePrice));
    }
    notifyListeners();
  }

  void addNewCartLine([Product? product]) {
    Product target;
    if (product != null) {
      target = product;
    } else {
      target = products.firstWhere(
        (p) => !cartLines.any((l) => l.product.id == p.id),
        orElse: () => products.first,
      );
    }
    cartLines.add(CartLine(product: target, quantity: 1, price: target.salePrice));
    notifyListeners();
  }

  void updateCartLineQuantity(int index, int quantity) {
    if (quantity <= 0) {
      cartLines.removeAt(index);
    } else {
      cartLines[index].quantity = quantity;
    }
    notifyListeners();
  }

  void updateCartLinePrice(int index, double price) {
    cartLines[index].price = price;
    notifyListeners();
  }

  void removeCartLine(int index) {
    cartLines.removeAt(index);
    notifyListeners();
  }

  void resetCart() {
    cartLines.clear();
    discount = 0.0;
    paidAmount = 0.0;
    paymentMethod = 'Cash';
    selectedCustomer = null;
    notifyListeners();
  }

  // Actions
  SaleInvoice createSale({
    required Customer customer,
    required double disc,
    required double paid,
    required String method,
    String? dueDate,
    double? installment,
  }) {
    final invoiceNo = 'AGR-2026-0${143 + invoices.length}';
    final items = cartLines
        .map((l) => InvoiceItem(product: l.product, quantity: l.quantity, unitPrice: l.price))
        .toList();

    // Deduct stock
    for (final line in cartLines) {
      final pIndex = products.indexWhere((p) => p.id == line.product.id);
      if (pIndex >= 0) {
        products[pIndex].stock = (products[pIndex].stock - line.quantity).clamp(0, 999999);
      }
    }

    final newInvoice = SaleInvoice(
      invoiceNo: invoiceNo,
      customer: customer,
      date: DateTime.now().toIso8601String().substring(0, 10),
      items: items,
      discount: disc,
      paidAmount: paid,
      paymentMethod: method,
      dueDate: dueDate,
      installmentAmount: installment,
    );

    invoices.insert(0, newInvoice);
    resetCart();
    notifyListeners();
    return newInvoice;
  }

  void recordPayment({
    required String invoiceNo,
    required double amount,
    required String method,
  }) {
    final invIndex = invoices.indexWhere((inv) => inv.invoiceNo == invoiceNo);
    if (invIndex >= 0) {
      final inv = invoices[invIndex];
      inv.paidAmount += amount;
      notifyListeners();
    }
  }

  void addProduct(Product product) {
    products.add(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final i = products.indexWhere((p) => p.id == product.id);
    if (i >= 0) {
      products[i] = product;
      notifyListeners();
    }
  }

  void adjustProductStock(String productId, int newStock) {
    final i = products.indexWhere((p) => p.id == productId);
    if (i >= 0) {
      products[i].stock = newStock;
      notifyListeners();
    }
  }

  void addCustomer(Customer customer) {
    customers.add(customer);
    notifyListeners();
  }

  void addSupplier(Supplier supplier) {
    suppliers.add(supplier);
    notifyListeners();
  }

  void addPurchase(PurchaseOrder purchase) {
    purchases.insert(0, purchase);
    // Increase stock
    for (final item in purchase.items) {
      final i = products.indexWhere((p) => p.id == item.product.id);
      if (i >= 0) {
        products[i].stock += item.quantity;
      }
    }
    notifyListeners();
  }

  void addExpense(Expense expense) {
    expenses.insert(0, expense);
    notifyListeners();
  }
}
