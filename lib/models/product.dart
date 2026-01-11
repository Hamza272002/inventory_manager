class Product {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> attributes;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    this.imageUrl = '',
    required this.createdAt,
    required this.updatedAt,
    this.attributes = const {'category': 'General', 'rating': 5.0},
  });

  factory Product.fromJson(Map<String, dynamic> json, String documentId) {
    return Product(
      id: documentId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      attributes: json['attributes'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'attributes': attributes,
    };
  }
}