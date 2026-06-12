import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import 'product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();

    return Scaffold(
      appBar: AppBar(title: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.favorite, color: Colors.white), SizedBox(width: 8), Text('المفضلة')]), backgroundColor: Colors.deepPurple),
      body: provider.favorites.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.favorite_border, size: 80, color: Colors.grey), SizedBox(height: 20), Text('لا توجد مفضلات', style: TextStyle(fontSize: 20, color: Colors.grey))]))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.favorites.length,
              itemBuilder: (context, index) {
                final product = provider.favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(product.image, width: 55, height: 55, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 55, height: 55, decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.image, color: Colors.red)))),
                    title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    trailing: IconButton(onPressed: () => provider.toggleFavorite(product.id), icon: const Icon(Icons.delete, color: Colors.red)),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))),
                  ),
                );
              },
            ),
    );
  }
}