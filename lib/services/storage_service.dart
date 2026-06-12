import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class StorageService {
  static const String _productsKey = 'cached_products';
  static const String _favoritesKey = 'favorites';

  static Future<void> cacheProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(products.map((p) => p.toJson()).toList());
    await prefs.setString(_productsKey, jsonString);
  }

  static Future<List<Product>?> loadCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_productsKey);
    if (jsonString != null) {
      List<dynamic> data = json.decode(jsonString);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    return null;
  }

  static Future<void> saveFavorites(List<int> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoritesKey, json.encode(favoriteIds));
  }

  static Future<List<int>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);
    if (jsonString != null) {
      List<dynamic> data = json.decode(jsonString);
      return data.map((e) => e as int).toList();
    }
    return [];
  }
}