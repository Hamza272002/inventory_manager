import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import '../providers/product_provider.dart';
import '../core/widgets/stock_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Manager'),
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search product...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                productProvider.setSearchQuery(value);
              },
            ),
          ),

          // 🎯 Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected:
                        productProvider.currentFilter == StockFilter.all,
                    onSelected: (_) {
                      productProvider.setFilter(StockFilter.all);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Low Stock'),
                    selected:
                        productProvider.currentFilter == StockFilter.low,
                    onSelected: (_) {
                      productProvider.setFilter(StockFilter.low);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Out of Stock'),
                    selected:
                        productProvider.currentFilter == StockFilter.out,
                    onSelected: (_) {
                      productProvider.setFilter(StockFilter.out);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('In Stock'),
                    selected: productProvider.currentFilter ==
                        StockFilter.inStock,
                    onSelected: (_) {
                      productProvider.setFilter(StockFilter.inStock);
                    },
                  ),
                ],
              ),
            ),
          ),

          // 📦 Product List
          Expanded(
            child: productProvider.filteredProducts.isEmpty
                ? const Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(
        Icons.inventory_2_outlined,
        size: 80,
        color: Colors.grey,
      ),
      SizedBox(height: 12),
      Text(
        'No products found',
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    ],
  ),
)

                : ListView.builder(
                    itemCount: productProvider.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product =
                          productProvider.filteredProducts[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditProductScreen(product: product),
                              ),
                            );
                          },
                          title: Text(
                            product.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Qty: ${product.quantity}'),
                              const SizedBox(height: 4),
                              StockBadge(
                                  quantity: product.quantity),
                            ],
                          ),

                          // 🗑️ Delete with confirmation
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () async {
                              final confirm =
                                  await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title:
                                      const Text('Delete Product'),
                                  content: const Text(
                                      'Are you sure you want to delete this product?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(
                                              context, false),
                                      child:
                                          const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(
                                              context, true),
                                      child:
                                          const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                productProvider
                                    .deleteProduct(product.id);

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Product deleted'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
