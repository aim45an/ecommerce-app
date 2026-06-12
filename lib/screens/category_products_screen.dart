import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import 'product_details_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String category;
  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    final products = provider.getProductsByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.folder_open, color: Colors.white), const SizedBox(width: 8), Text(category)]),
        backgroundColor: Colors.deepPurple,
      ),
      body: products.isEmpty
          ? const Center(child: Text('لا توجد منتجات', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(product.image, width: 55, height: 55, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 55, height: 55, decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.image, color: Colors.deepPurple)))),
                    title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))),
                  ),
                );
              },
            ),
    );
  }
}