import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item.dart';

class CartDatabase {
  static final CartDatabase _instance = CartDatabase._internal();
  factory CartDatabase() => _instance;
  CartDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cart_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        UNIQUE(product_id)
      )
    ''');
  }

  // إضافة منتج إلى السلة
  Future<void> addToCart(CartItem item) async {
    final db = await database;
    await db.insert(
      'cart_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // جلب جميع عناصر السلة
  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart_items');
    return List.generate(maps.length, (i) => CartItem.fromMap(maps[i]));
  }

  // تحديث كمية منتج
  Future<void> updateQuantity(int productId, int quantity) async {
    final db = await database;
    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  // حذف منتج من السلة
  Future<void> removeFromCart(int productId) async {
    final db = await database;
    await db.delete(
      'cart_items',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  // مسح السلة بالكامل
  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  // الحصول على عدد المنتجات في السلة
  Future<int> getCartCount() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(quantity) as total FROM cart_items'
    );
    return result.first['total'] as int? ?? 0;
  }

  // الحصول على المجموع الكلي
  Future<double> getTotalPrice() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(price * quantity) as total FROM cart_items'
    );
    return result.first['total'] as double? ?? 0.0;
  }
}