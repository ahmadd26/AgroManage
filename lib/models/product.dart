class Product {
  final String id;
  String name;
  String category;
  double buyPrice;
  double salePrice;
  int stock;
  int minStock;
  String expiryDate;
  String unit;
  String? description;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.buyPrice,
    required this.salePrice,
    required this.stock,
    required this.minStock,
    this.expiryDate = '',
    this.unit = 'units',
    this.description,
  });

  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= minStock;
  
  bool get isExpiringSoon {
    if (expiryDate.isEmpty) return false;
    try {
      final exp = DateTime.parse(expiryDate);
      final now = DateTime.now();
      final diff = exp.difference(now).inDays;
      return diff >= 0 && diff <= 90;
    } catch (_) {
      return false;
    }
  }

  double get margin => salePrice - buyPrice;
  double get marginPercent => buyPrice > 0 ? ((margin / buyPrice) * 100) : 0.0;

  String get stockStatus {
    if (isOutOfStock) return 'Out of stock';
    if (isLowStock) return 'Low stock';
    if (isExpiringSoon) return 'Expiring soon';
    return 'In stock';
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? buyPrice,
    double? salePrice,
    int? stock,
    int? minStock,
    String? expiryDate,
    String? unit,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      buyPrice: buyPrice ?? this.buyPrice,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      expiryDate: expiryDate ?? this.expiryDate,
      unit: unit ?? this.unit,
      description: description ?? this.description,
    );
  }
}
