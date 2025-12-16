class Product {
  final String id;
  final String name;
  final double mrp;
  final double salesRate;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.mrp,
    required this.salesRate,
    this.imageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mrp': mrp,
      'salesRate': salesRate,
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      mrp: (map['mrp'] ?? 0.0).toDouble(),
      salesRate: (map['salesRate'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
