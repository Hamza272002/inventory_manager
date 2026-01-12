import 'dart:async'; 
import 'dart:typed_data'; // ضروري للتعامل مع الصور على الويب (Uint8List)
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum StockFilter { all, low, out, inStock }

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  final FirestoreService _firestoreService = FirestoreService();
  
  StreamSubscription<List<Product>>? _productsSubscription;

  String _searchQuery = '';
  StockFilter _filter = StockFilter.all;
  bool _isLoading = false; 
  bool _isListening = false; 

  ThemeMode _themeMode = ThemeMode.system; 
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); 
  }

  // ================== GETTERS ==================
  List<Product> get products => filteredProducts;
  bool get isLoading => _isLoading;
  StockFilter get currentFilter => _filter;

  // ================== FIREBASE REAL-TIME ACTIONS ==================

  void startListeningToProducts() {
    if (_isListening) return; 

    _isListening = true;
    _isLoading = true;

    _productsSubscription?.cancel();

    _productsSubscription = _firestoreService.getProductsStream().listen(
      (data) {
        _products = data;
        _isLoading = false;
        notifyListeners(); 
      },
      onError: (error) {
        debugPrint("Stream Error: $error");
        _isLoading = false;
        _isListening = false; 
        notifyListeners();
      },
    );
  }

  void shareProduct(Product product) {
    final String message = '''
Check out this product: ${product.name}
Description: ${product.description}
Price: \$${product.price}
Quantity available: ${product.quantity}
${product.imageUrl.isNotEmpty ? 'Image: ${product.imageUrl}' : ''}
    ''';

    // استدعاء واجهة المشاركة الخاصة بالنظام
    Share.share(message, subject: 'Product Details: ${product.name}');
  }

  void stopListening() {
    _productsSubscription?.cancel();
    _isListening = false;
    _products = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  // ================== CRUD OPERATIONS ==================

  /// إضافة منتج مع رابط الصورة
  Future<void> addProduct(String name, String desc, int qty, double price, String imageUrl) async {
    try {
      final now = DateTime.now();
      final newProduct = Product(
        id: '', 
        name: name,
        description: desc,
        quantity: qty,
        price: price,
        imageUrl: imageUrl, 
        createdAt: now,
        updatedAt: now,
      );

      await _firestoreService.addProduct(newProduct);
    } catch (e) {
      debugPrint("Add Error: $e");
      rethrow;
    }
  }

  /// دالة رفع الصور المخصصة للويب
  Future<String> uploadImageWeb(Uint8List imageData, String fileName) async {
    try {
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference ref = FirebaseStorage.instance.ref().child('product_images/$uniqueFileName');
      
      UploadTask uploadTask = ref.putData(imageData);
      TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Upload Error: $e");
      return '';
    }
  }

  /// حذف منتج
  Future<void> deleteProduct(String id) async {
    try {
      await _firestoreService.deleteProduct(id);
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  /// تحديث المنتج (تم التعديل لإضافة الاسم)
  Future<void> updateProduct(String id, String name, String description, int quantity, double price) async {
    try {
      await _firestoreService.updateProduct(id, {
        'name': name, // <--- إضافة الاسم هنا ليتم تحديثه في Firestore
        'description': description,
        'quantity': quantity,
        'price': price,
        // FieldValue.serverTimestamp() يضمن دقة الوقت من الخادم مباشرة
        'updatedAt': FieldValue.serverTimestamp(), 
      });
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  // ================== FILTER & SEARCH LOGIC ==================

  List<Product> get filteredProducts {
    List<Product> list = [..._products];

    // الترتيب التلقائي: الأحدث تعديلاً يظهر في الأعلى
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (_searchQuery.isNotEmpty) {
      list = list.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    switch (_filter) {
      case StockFilter.low:
        list = list.where((p) => p.quantity > 0 && p.quantity < 10).toList();
        break;
      case StockFilter.out:
        list = list.where((p) => p.quantity == 0).toList();
        break;
      case StockFilter.inStock:
        list = list.where((p) => p.quantity >= 10).toList();
        break;
      default:
        break;
    }
    return list;
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setFilter(StockFilter value) {
    _filter = value;
    notifyListeners();
  }
}