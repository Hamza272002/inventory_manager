import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/widgets/stock_badge.dart'; 
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // جلب المنتجات عند التشغيل
    Future.microtask(() => context.read<ProductProvider>().fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة الـ Provider للحصول على البيانات وحالة الثيم
    final productProvider = context.watch<ProductProvider>();
    
    // تحديد الأيقونة بناءً على وضع الثيم الحالي
    final bool isDarkMode = productProvider.themeMode == ThemeMode.dark || 
                           (productProvider.themeMode == ThemeMode.system && 
                            Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Manager'),
        centerTitle: true,
        // إضافة زر تبديل الثيم في الـ AppBar
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              // عكس الحالة الحالية
              productProvider.toggleTheme(!isDarkMode);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 شريط البحث
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search product...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onChanged: (value) => productProvider.setSearchQuery(value),
            ),
          ),

          // 🎯 أزرار الفلترة
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: StockFilter.values.map((filter) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(filter.name.toUpperCase()),
                    selected: productProvider.currentFilter == filter,
                    onSelected: (_) => productProvider.setFilter(filter),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 📦 قائمة المنتجات
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: productProvider.filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = productProvider.filteredProducts[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProductScreen(product: product),
                                ),
                              ),
                              title: Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Qty: ${product.quantity} - Price: \$${product.price}'),
                                  const SizedBox(height: 8),
                                  StockBadge(quantity: product.quantity),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(context, productProvider, product.id),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  // واجهة الحالة الفارغة
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 10),
          const Text('No products found', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  // حوار تأكيد الحذف
  void _confirmDelete(BuildContext context, ProductProvider provider, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteProduct(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}