import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final String imageUrl;
  
  // 1.2 Metadata: تاريخ الإنشاء وتاريخ آخر تعديل
  final DateTime createdAt;
  final DateTime updatedAt;

  // 1.2 Attributes: حقل مرن لإضافة خصائص إضافية (مثل التصنيف، التقييم، إلخ)
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

  // ================== JSON Serialization (Deserialization) ==================
  // تحويل البيانات القادمة من Firebase إلى كائن Product
  factory Product.fromJson(Map<String, dynamic> json, String documentId) {
    
    // دالة مساعدة للتعامل مع التواريخ سواء كانت نص (String) أو Timestamp من Firebase
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.parse(date);
      return DateTime.now();
    }

    return Product(
      id: documentId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      attributes: json['attributes'] ?? {'category': 'General', 'rating': 5.0},
    );
  }

  // ================== JSON Serialization (Serialization) ==================
  // تحويل الكائن إلى Map لإرساله إلى Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      // نرسلها كـ ISO8601 لسهولة القراءة أو نترك Firebase يحول الـ DateTime لـ Timestamp
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'attributes': attributes,
    };
  }

  // ================== المساعدة في التحديث (Copy With) ==================
  // تسمح لك بتحديث حقول معينة دون الحاجة لإعادة إنشاء الكائن بالكامل
  Product copyWith({
    String? name,
    String? description,
    int? quantity,
    double? price,
    String? imageUrl,
    DateTime? updatedAt,
    Map<String, dynamic>? attributes,
  }) {
    return Product(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: this.createdAt, // تاريخ الإنشاء لا يتغير أبداً
      updatedAt: updatedAt ?? DateTime.now(), // نحدث تاريخ التعديل تلقائياً
      attributes: attributes ?? this.attributes,
    );
  }
}