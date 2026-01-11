import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../core/theme/widgets/stock_badge.dart'; 
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // الكنترولر هو مفتاح الحل لثبات النص
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // بدء الاستماع للمنتجات عند فتح الشاشة
    Future.microtask(() => 
      context.read<ProductProvider>().startListeningToProducts()
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نعرّف الـ Provider هنا باستخدام read لمنع إعادة بناء الحقل عند كل تغيير
    final productProvider = context.read<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Manager'),
        centerTitle: true,
        actions: [
          Consumer<ProductProvider>(
            builder: (context, provider, _) {
              final isDark = provider.themeMode == ThemeMode.dark || 
                            (provider.themeMode == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => provider.toggleTheme(!isDark),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 شريط البحث - الزر X موجود دائماً الآن
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              key: const ValueKey('PersistentSearchField'), // يحافظ على حالة الحقل
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or description...',
                prefixIcon: const Icon(Icons.search),
                // زر X يظهر دائماً كما طلبت
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear(); // مسح النص من الحقل
                    productProvider.setSearchQuery(''); // إعادة تصفير البحث في القائمة
                  },
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // تحديث البحث في الخلفية دون التأثير على استقرار الحقل
                productProvider.setSearchQuery(value);
              },
            ),
          ),

          // 🎯 أزرار الفلترة
          Consumer<ProductProvider>(
            builder: (context, provider, _) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: StockFilter.values.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(filter.name.toUpperCase()),
                        selected: provider.currentFilter == filter,
                        onSelected: (_) => provider.setFilter(filter),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // 📦 قائمة المنتجات (الستايل الجمالي الكامل)
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                
                final products = provider.filteredProducts;
                if (products.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  itemCount: products.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isDark = Theme.of(context).brightness == Brightness.dark;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                product.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.monetization_on_outlined, size: 18, color: Colors.green),
                                const SizedBox(width: 4),
                                Text('\$${product.price}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 16),
                                const Icon(Icons.layers_outlined, size: 18, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text('Qty: ${product.quantity}'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            StockBadge(quantity: product.quantity),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, provider, product.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add Product'),
      ),
    );
  }

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