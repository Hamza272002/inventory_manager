import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

enum StockFilter { all, low, out, inStock }

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [];
  final FirestoreService _firestoreService = FirestoreService();
  
  String _searchQuery = '';
  StockFilter _filter = StockFilter.all;
  bool _isLoading = false;

  // ================== إعدادات الثيم (Material 3 Support) ==================
  
  ThemeMode _themeMode = ThemeMode.system; 
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); 
  }

  // ================== GETTERS ==================
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  StockFilter get currentFilter => _filter;

  // ================== FIREBASE ACTIONS ==================

  /// جلب البيانات باستخدام factory constructor (JSON Deserialization)
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _firestoreService.getProducts();
      _products.clear();
      _products.addAll(data);
    } catch (e) {
      debugPrint("Error fetching: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  /// الفلترة والبحث المتقدم
  List<Product> get filteredProducts {
    List<Product> list = _products;

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

  /// إضافة منتج مع دعم Metadata و Attributes المطلوبة في الأسبوع الأول
  Future<void> addProduct(String name, String desc, int qty, double price) async {
    try {
      final now = DateTime.now();
      final newProduct = Product(
        id: '', // سيتم تعيينه من قبل Firestore
        name: name,
        description: desc,
        quantity: qty,
        price: price,
        createdAt: now,
        updatedAt: now,
        attributes: {'category': 'Default', 'rating': 5.0}, // إحصائيات إضافية
      );

      // تحويل الكائن إلى JSON قبل الإرسال (Serialization)
      final id = await _firestoreService.addProduct(newProduct);
      
      // إضافة المنتج للقائمة المحلية مع الـ ID الحقيقي
      _products.add(Product(
        id: id,
        name: name,
        description: desc,
        quantity: qty,
        price: price,
        createdAt: now,
        updatedAt: now,
        attributes: newProduct.attributes,
      ));
      
      notifyListeners();
    } catch (e) {
      debugPrint("Add Error: $e");
      rethrow;
    }
  }

  /// حذف منتج
  Future<void> deleteProduct(String id) async {
    try {
      await _firestoreService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  /// تحديث المنتج مع تحديث التوقيت (Last Modified Metadata)
  Future<void> updateProduct(String id, int quantity, double price) async {
    final now = DateTime.now();
    try {
      await _firestoreService.updateProduct(id, {
        'quantity': quantity,
        'price': price,
        'updatedAt': now.toIso8601String(), // تحديث الـ Metadata
      });

      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = Product(
          id: _products[index].id,
          name: _products[index].name,
          description: _products[index].description,
          quantity: quantity,
          price: price,
          createdAt: _products[index].createdAt,
          updatedAt: now, // تحديث الوقت محلياً أيضاً
          attributes: _products[index].attributes,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  // ================== UI SETTERS ==================

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setFilter(StockFilter value) {
    _filter = value;
    notifyListeners();
  }
}