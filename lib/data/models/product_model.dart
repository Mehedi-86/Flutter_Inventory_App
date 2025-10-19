class Product {
  final String id;
  final String name;
  final String sku;
  final String categoryId;
  final int quantity;
  final double unitPrice;
  final int reorderLevel; // For low-stock alerts

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.categoryId,
    required this.quantity,
    required this.unitPrice,
    required this.reorderLevel,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? '',
      sku: data['sku'] ?? '',
      categoryId: data['categoryId'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice: (data['unitPrice'] ?? 0.0).toDouble(),
      reorderLevel: data['reorderLevel'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'categoryId': categoryId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'reorderLevel': reorderLevel,
    };
  }
}