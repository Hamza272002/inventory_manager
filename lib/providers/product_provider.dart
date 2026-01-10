import 'package:flutter/material.dart';
import '../models/product.dart';

/// 🔹 Stock Filter Enum (خارج الكلاس)
enum StockFilter { all, low, out, inStock }

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [];

  // 🔍 Search
  String _searchQuery = '';

  // 🎯 Filter
  StockFilter _filter = StockFilter.all;

  // ================== GETTERS ==================

  List<Product> get products => _products;

  bool get isEmpty => _products.isEmpty;

  StockFilter get currentFilter => _filter;

  /// 🔍 + 🎯 Search & Filter (Combined)
  List<Product> get filteredProducts {
    List<Product> list = _products;

    // Search
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filter
    switch (_filter) {
      case StockFilter.low:
        list =
            list.where((p) => p.quantity > 0 && p.quantity < 5).toList();
        break;
      case StockFilter.out:
        list = list.where((p) => p.quantity == 0).toList();
        break;
      case StockFilter.inStock:
        list = list.where((p) => p.quantity >= 5).toList();
        break;
      case StockFilter.all:
      default:
        break;
    }

    return list;
  }

  // ================== ACTIONS ==================

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void updateProduct(String id, int quantity, double price) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index].quantity = quantity;
      _products[index].price = price;
      _products[index].updatedAt = DateTime.now();
      notifyListeners();
    }
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
