import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/expense_item.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'budgetbudy.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE subcategories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subcategory_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY(subcategory_id) REFERENCES subcategories(id) ON DELETE CASCADE
      )
    ''');
  }

  // Categories
  static Future<int> insertCategory(Category category) async {
    final db = await database;
    return db.insert('categories', category.toMap()..remove('id'));
  }

  static Future<List<Category>> getCategories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'name ASC');
    return rows.map(Category.fromMap).toList();
  }

  static Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Subcategories
  static Future<int> insertSubcategory(Subcategory subcategory) async {
    final db = await database;
    return db.insert('subcategories', subcategory.toMap()..remove('id'));
  }

  static Future<List<Subcategory>> getSubcategories() async {
    final db = await database;
    final rows = await db.query('subcategories', orderBy: 'name ASC');
    return rows.map(Subcategory.fromMap).toList();
  }

  static Future<void> deleteSubcategory(int id) async {
    final db = await database;
    await db.delete('subcategories', where: 'id = ?', whereArgs: [id]);
  }

  // Items
  static Future<int> insertItem(ExpenseItem item) async {
    final db = await database;
    return db.insert('items', item.toMap()..remove('id'));
  }

  static Future<List<ExpenseItem>> getItems() async {
    final db = await database;
    final rows = await db.query('items', orderBy: 'date DESC');
    return rows.map(ExpenseItem.fromMap).toList();
  }

  static Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }
}
