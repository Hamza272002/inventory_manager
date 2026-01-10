import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  // جلب البيانات مع دعم JSON Deserialization [cite: 23]
  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _productsCollection.get();
      return snapshot.docs.map((doc) {
        // نستخدم factory constructor المحدث
        return Product.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // إضافة منتج مع دعم JSON Serialization [cite: 23]
  Future<String> addProduct(Product product) async {
    // نستخدم toJson لتحويل الكائن قبل الإرسال لـ Firestore
    DocumentReference doc = await _productsCollection.add(product.toJson());
    return doc.id;
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _productsCollection.doc(id).update(data);
  }

  Future<void> deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }
}