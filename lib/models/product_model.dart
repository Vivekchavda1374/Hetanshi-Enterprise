class Product {
  final String id;
  final String name;
  final double mrp;
  final double salesRate;
  final String imageUrl;
  final String category;
  final String description;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.mrp,
    required this.salesRate,
    this.imageUrl = '',
    this.category = '',
    this.description = '',
    this.stock = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mrp': mrp,
      'salesRate': salesRate,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
      'stock': stock,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      mrp: (map['mrp'] ?? 0.0).toDouble(),
      salesRate: (map['salesRate'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      stock: map['stock'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.mrp == mrp &&
        other.salesRate == salesRate &&
        other.imageUrl == imageUrl &&
        other.category == category &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        mrp.hashCode ^
        salesRate.hashCode ^
        imageUrl.hashCode ^
        category.hashCode ^
        description.hashCode;
  }
}
