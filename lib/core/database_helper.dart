import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'outfit_matcher.db');
    return await openDatabase(
      path,
      version: 4, // Upgraded to version 4 for product_id
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT, -- Added to link with Firebase ID
        title TEXT,
        imageUrl TEXT,
        category TEXT,
        tags TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        name TEXT,
        last_login TEXT,
        auth_token TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT,
        total_amount REAL,
        shipping_address TEXT,
        payment_method TEXT,
        card_holder TEXT,
        card_number TEXT,
        expiry_date TEXT,
        status TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER,
        outfit_title TEXT,
        price REAL,
        quantity INTEGER,
        FOREIGN KEY (order_id) REFERENCES orders (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, name TEXT, last_login TEXT, auth_token TEXT)');
      await db.execute(
          'CREATE TABLE IF NOT EXISTS orders (id INTEGER PRIMARY KEY AUTOINCREMENT, user_email TEXT, total_amount REAL, shipping_address TEXT, payment_method TEXT, status TEXT, created_at TEXT)');
      await db.execute(
          'CREATE TABLE IF NOT EXISTS order_items (id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER, outfit_title TEXT, price REAL, quantity INTEGER, FOREIGN KEY (order_id) REFERENCES orders (id))');
    }
    if (oldVersion < 3) {
      // Adding payment detail columns to orders table
      await db.execute('ALTER TABLE orders ADD COLUMN card_holder TEXT');
      await db.execute('ALTER TABLE orders ADD COLUMN card_number TEXT');
      await db.execute('ALTER TABLE orders ADD COLUMN expiry_date TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE favorites ADD COLUMN product_id TEXT');
    }
  }

  // --- User Operations ---
  Future<int> saveUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // --- Favorites CRUD ---
  Future<int> addFavorite(Map<String, dynamic> outfit) async {
    final db = await database;
    return await db.insert('favorites', outfit);
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query('favorites');
  }

  Future<int> removeFavorite(int id) async {
    final db = await database;
    return await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isFavorite(String imageUrl) async {
    final db = await database;
    final maps = await db.query(
      'favorites',
      where: 'imageUrl = ?',
      whereArgs: [imageUrl],
    );
    return maps.isNotEmpty;
  }

  // --- Order Operations ---
  Future<int> createOrder(
      Map<String, dynamic> order, List<Map<String, dynamic>> items) async {
    final db = await database;
    return await db.transaction((txn) async {
      int orderId = await txn.insert('orders', order);
      for (var item in items) {
        item['order_id'] = orderId;
        await txn.insert('order_items', item);
      }
      return orderId;
    });
  }

  Future<List<Map<String, dynamic>>> getOrderHistory(String email) async {
    final db = await database;
    return await db
        .query('orders', where: 'user_email = ?', whereArgs: [email]);
  }
}
