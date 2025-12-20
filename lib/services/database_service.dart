import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'ashtana.db';
  static const int _dbVersion = 1;

  // Singleton instance
  static final DatabaseService instance = DatabaseService._private();
  DatabaseService._private();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        image_path TEXT,
        category_id INTEGER,
        stock INTEGER DEFAULT 0,
        rating REAL DEFAULT 0.0,
        review_count INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Cart table
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        added_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT UNIQUE NOT NULL,
        total_amount REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        shipping_address TEXT,
        payment_method TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        added_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
    // Insert sample products
    await _insertSampleProducts(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    const categories = [
      {'name': 'New Arrivals', 'image_path': 'assets/categories/c2.jpg'},
      {'name': 'Jewelry', 'image_path': 'assets/categories/c3.jpg'},
      {'name': "Women's Fashion", 'image_path': 'assets/categories/c10.jpg'},
      {'name': 'Accessories', 'image_path': 'assets/categories/c1.jpg'},
    ];

    for (var category in categories) {
      await db.insert('categories', category);
    }
  }

  Future<void> _insertSampleProducts(Database db) async {
    // Sample products - you'll replace these with your actual products
    const products = [
      {
        'name': 'Classic Silver Necklace',
        'description': 'Elegant silver necklace with precious stone',
        'price': 129.99,
        'image_path': 'assets/products/earrings1.jpg',
        'category_id': 2, // Jewelry
        'stock': 25,
        'rating': 4.5,
      },
      {
        'name': 'Crop Top',
        'description': 'Light and comfortable stylish crop top',
        'price': 20.99,
        'image_path': 'assets/products/Top04.png',
        'category_id': 3, // Women's Fashion
        'stock': 15,
        'rating': 4.2,
      },
      {
        'name': 'Leather Handbag',
        'description': 'Premium leather handbag with multiple compartments',
        'price': 89.99,
        'image_path': 'assets/products/bag.jpg',
        'category_id': 4, // Accessories
        'stock': 10,
        'rating': 4.7,
      },
      {
        'name': 'Silver Earrings',
        'description': '24K silver plated earrings',
        'price': 79.99,
        'image_path': 'assets/products/s.jpg',
        'category_id': 2, // Jewelry
        'stock': 30,
        'rating': 4.8,
      },
      // Add more products as needed
    ];

    for (var product in products) {
      await db.insert('products', product);
    }
  }

  // Category operations
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'name');
  }

  // Product operations
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return await db.query('products', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(int categoryId) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getProductById(int id) async {
    final db = await database;
    final results = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Cart operations
  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.*, p.name, p.price, p.image_path, p.stock 
      FROM cart_items c 
      JOIN products p ON c.product_id = p.id
      ORDER BY c.added_at DESC
    ''');
  }

  Future<int> addToCart(int productId, [int quantity = 1]) async {
    final db = await database;
    
    // Check if already in cart
    final existing = await db.query(
      'cart_items',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    
    if (existing.isNotEmpty) {
      // Update quantity
      final currentQty = existing.first['quantity'] as int;
      return await db.update(
        'cart_items',
        {'quantity': currentQty + quantity},
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } else {
      // Insert new item
      return await db.insert('cart_items', {
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  Future<int> updateCartQuantity(int cartItemId, int quantity) async {
    final db = await database;
    if (quantity <= 0) {
      return await db.delete(
        'cart_items',
        where: 'id = ?',
        whereArgs: [cartItemId],
      );
    }
    
    return await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }

  Future<int> removeFromCart(int cartItemId) async {
    final db = await database;
    return await db.delete(
      'cart_items',
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }

  Future<int> clearCart() async {
    final db = await database;
    return await db.delete('cart_items');
  }

  // Order operations
  Future<int> createOrder(Map<String, dynamic> orderData) async {
    final db = await database;
    
    // Generate order number
    final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    
    final orderId = await db.insert('orders', {
      ...orderData,
      'order_number': orderNumber,
    });
    
    return orderId;
  }

  Future<int> addOrderItem(Map<String, dynamic> itemData) async {
    final db = await database;
    return await db.insert('order_items', itemData);
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return await db.query('orders', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    final db = await database;
    return await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  // Favorite operations
  Future<int> addToFavorites(int productId) async {
    final db = await database;
    
    // Check if already favorited
    final existing = await db.query(
      'favorites',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    
    if (existing.isEmpty) {
      return await db.insert('favorites', {'product_id': productId});
    }
    return 0;
  }

  Future<int> removeFromFavorites(int productId) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT f.*, p.name, p.price, p.image_path, p.description 
      FROM favorites f 
      JOIN products p ON f.product_id = p.id
      ORDER BY f.added_at DESC
    ''');
  }

  Future<bool> isProductFavorited(int productId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty;
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}