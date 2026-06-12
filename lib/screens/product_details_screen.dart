import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/store_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    final isFav = product.isFavorite;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(product.image, height: 200, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Container(height: 200, decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.image, size: 80, color: Colors.deepPurple))),
            ),
            const SizedBox(height: 20),
            Text(product.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(20)), child: Text(product.category, style: TextStyle(color: Colors.deepPurple.shade700))),
            const SizedBox(height: 15),
            Text(product.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 20),
            Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      provider.toggleFavorite(product.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 20), const SizedBox(width: 8), Text(isFav ? 'تمت إزالة من المفضلة' : 'تمت إضافة إلى المفضلة')])));
                    },
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.grey),
                    label: Text(isFav ? 'إزالة' : 'مفضلة'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.addToCart(product.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.shopping_cart, color: Colors.white, size: 20), const SizedBox(width: 8), Text('${product.title} أُضيف إلى السلة')])));
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('إضافة للسلة'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}