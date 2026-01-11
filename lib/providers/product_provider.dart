import 'dart:async'; 
import 'dart:typed_data'; // ضروري للتعامل مع الصور على الويب (Uint8List)
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  /// دالة رفع الصور المخصصة للويب (تستخدم Uint8List)
  /// هذا يحل مشكلة "Image.file is not supported on Flutter Web"
  Future<String> uploadImageWeb(Uint8List imageData, String fileName) async {
    try {
      // إنشاء اسم فريد باستخدام الوقت الحالي لمنع تداخل الأسماء
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference ref = FirebaseStorage.instance.ref().child('product_images/$uniqueFileName');
      
      // استخدام putData بدلاً من putFile لضمان التوافق مع المتصفح
      UploadTask uploadTask = ref.putData(imageData);
      TaskSnapshot snapshot = await uploadTask;
      
      // الحصول على رابط الصورة النهائي
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

  /// تحديث المنتج
  Future<void> updateProduct(String id, String description, int quantity, double price) async {
    try {
      await _firestoreService.updateProduct(id, {
        'description': description,
        'quantity': quantity,
        'price': price,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  // ================== FILTER & SEARCH LOGIC ==================

  List<Product> get filteredProducts {
    List<Product> list = [..._products];

    if (_searchQuery.isNotEmpty) {
      list = list.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase())
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