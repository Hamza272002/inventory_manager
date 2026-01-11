import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // 📅 استيراد مكتبة التنسيق
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
          // 🔍 شريط البحث
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              key: const ValueKey('PersistentSearchField'),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or description...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    productProvider.setSearchQuery('');
                  },
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => productProvider.setSearchQuery(value),
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

          // 📦 قائمة المنتجات
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
                        
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: product.imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                  ),
                                )
                              : const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                        ),

                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.description.isNotEmpty) ...[
                              Text(
                                product.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('\$${product.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                const SizedBox(width: 10),
                                Text('Qty: ${product.quantity}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            StockBadge(quantity: product.quantity),
                            
                            // 🕒 عرض تاريخ آخر تعديل (Metadata) الجديد
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.history, size: 12, color: isDark ? Colors.white38 : Colors.black38),
                                const SizedBox(width: 4),
                                Text(
                                  'Last modified: ${DateFormat('MMM d, yyyy • HH:mm').format(product.updatedAt)}',
                                  style: TextStyle(
                                    fontSize: 10, 
                                    color: isDark ? Colors.white38 : Colors.black38,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.blue, size: 22),
                              tooltip: 'Share Product',
                              onPressed: () => provider.shareProduct(product),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 22),
                              onPressed: () => _confirmDelete(context, provider, product.id),
                            ),
                          ],
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

  // ... (بقية الدوال _buildEmptyState و _confirmDelete تبقى كما هي)
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