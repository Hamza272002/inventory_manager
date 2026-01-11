import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  // المرجع الخاص بمجموعة المنتجات في Firestore
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  // =============================================================
  // 1. جلب البيانات اللحظي (Stream) - التزامن التلقائي
  // =============================================================
  // نستخدم snapshots() لضمان تحديث الواجهة فوراً عند تغيير أي بيانات في السحاب
  Stream<List<Product>> getProductsStream() {
    return _productsCollection
        .orderBy('createdAt', descending: true) // ترتيب المنتجات من الأحدث إلى الأقدم
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // تحويل بيانات الوثيقة إلى كائن Product
        return Product.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // =============================================================
  // 2. إضافة منتج جديد (JSON Serialization)
  // =============================================================
  Future<String> addProduct(Product product) async {
    try {
      // استخدام toJson لتحويل الكائن قبل إرساله لـ Firestore
      DocumentReference doc = await _productsCollection.add(product.toJson());
      return doc.id;
    } catch (e) {
      // معالجة الأخطاء (متطلب الأسبوع الثاني)
      print("خطأ أثناء إضافة المنتج: $e");
      rethrow;
    }
  }

  // =============================================================
  // 3. تحديث بيانات منتج (Partial Update)
  // =============================================================
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      // تحديث الحقول المحددة فقط وتحديث حقل التاريخ تلقائياً
      await _productsCollection.doc(id).update({
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("خطأ أثناء تحديث المنتج: $e");
      rethrow;
    }
  }

  // =============================================================
  // 4. حذف منتج نهائياً
  // =============================================================
  Future<void> deleteProduct(String id) async {
    try {
      await _productsCollection.doc(id).delete();
    } catch (e) {
      print("خطأ أثناء حذف المنتج: $e");
      rethrow;
    }
  }
}