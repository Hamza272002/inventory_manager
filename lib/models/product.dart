class Product {
  final String id;
  final String name;
  final String description;
  int quantity;
  double price;
  final String imageUrl;
  final DateTime createdAt;
  DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}
