import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../database/cart_database.dart';

class StoreProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String _errorMessage = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CartDatabase _cartDatabase = CartDatabase();

  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String get errorMessage => _errorMessage;

  List<Product> get favorites => _products.where((p) => p.isFavorite).toList();
  
  List<Product> get cartProducts {
    return _cartItems.map((cartItem) {
      return _products.firstWhere(
        (p) => p.id == cartItem.productId,
        orElse: () => Product(
          id: cartItem.productId,
          title: cartItem.title,
          price: cartItem.price,
          description: '',
          category: '',
          image: cartItem.image,
        ),
      );
    }).toList();
  }

  List<String> get categories {
    return _products.map((p) => p.category).toSet().toList();
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  int get cartItemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }
  
  double get totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  int getQuantity(int productId) {
    final item = _cartItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(productId: -1, title: '', price: 0, image: '', quantity: 0),
    );
    return item.quantity;
  }

  // تحميل المنتجات من Firestore
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      
      _products = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product(
          id: int.tryParse(doc.id) ?? doc.hashCode,
          title: data['title'] ?? '',
          price: (data['price'] as num).toDouble(),
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          image: data['image'] ?? '',
          isFavorite: data['isFavorite'] ?? false,
        );
      }).toList();
      
      _isOffline = false;
      
      // تحميل السلة من قاعدة البيانات المحلية
      await loadCartFromLocal();
      
    } catch (e) {
      _errorMessage = 'حدث خطأ: $e';
      _isOffline = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  // تحميل السلة من sqflite
  Future<void> loadCartFromLocal() async {
    _cartItems = await _cartDatabase.getCartItems();
    notifyListeners();
  }

  // إضافة إلى السلة (محلياً)
  Future<void> addToCart(int productId) async {
    final product = _products.firstWhere((p) => p.id == productId);
    
    final existingItem = _cartItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(productId: -1, title: '', price: 0, image: '', quantity: 0),
    );
    
    if (existingItem.productId != -1) {
      // موجود مسبقاً -> تحديث الكمية
      final newQuantity = existingItem.quantity + 1;
      await _cartDatabase.updateQuantity(productId, newQuantity);
      
      final index = _cartItems.indexWhere((item) => item.productId == productId);
      _cartItems[index] = CartItem(
        id: existingItem.id,
        productId: productId,
        title: product.title,
        price: product.price,
        image: product.image,
        quantity: newQuantity,
      );
    } else {
      // جديد -> إضافة
      final newItem = CartItem(
        productId: productId,
        title: product.title,
        price: product.price,
        image: product.image,
        quantity: 1,
      );
      await _cartDatabase.addToCart(newItem);
      _cartItems.add(newItem);
    }
    
    notifyListeners();
  }

  // إزالة من السلة
  Future<void> removeFromCart(int productId) async {
    await _cartDatabase.removeFromCart(productId);
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  // زيادة الكمية
  Future<void> increaseQuantity(int productId) async {
    final item = _cartItems.firstWhere((item) => item.productId == productId);
    final newQuantity = item.quantity + 1;
    await _cartDatabase.updateQuantity(productId, newQuantity);
    
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    _cartItems[index] = CartItem(
      id: item.id,
      productId: productId,
      title: item.title,
      price: item.price,
      image: item.image,
      quantity: newQuantity,
    );
    notifyListeners();
  }

  // تقليل الكمية
  Future<void> decreaseQuantity(int productId) async {
    final item = _cartItems.firstWhere((item) => item.productId == productId);
    
    if (item.quantity > 1) {
      final newQuantity = item.quantity - 1;
      await _cartDatabase.updateQuantity(productId, newQuantity);
      
      final index = _cartItems.indexWhere((item) => item.productId == productId);
      _cartItems[index] = CartItem(
        id: item.id,
        productId: productId,
        title: item.title,
        price: item.price,
        image: item.image,
        quantity: newQuantity,
      );
    } else {
      await _cartDatabase.removeFromCart(productId);
      _cartItems.removeWhere((item) => item.productId == productId);
    }
    notifyListeners();
  }

  // مسح السلة بالكامل
  Future<void> clearCart() async {
    await _cartDatabase.clearCart();
    _cartItems.clear();
    notifyListeners();
  }

  // تبديل المفضلة
  void toggleFavorite(int productId) {
    final product = _products.firstWhere((p) => p.id == productId);
    product.isFavorite = !product.isFavorite;
    notifyListeners();
  }
}