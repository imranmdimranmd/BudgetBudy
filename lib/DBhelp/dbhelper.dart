import 'dart:async';

import '../models/transaction.dart';
import '../constants/categories.dart';

import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static const _databaseName = 'spendings.db';
  static const _databaseVersion = 2;

  static Future<sql.Database> getDatabase() async {
    final dbPath = await sql.getDatabasesPath();

    return sql.openDatabase(
      path.join(dbPath, _databaseName),
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE transactions('
          'id TEXT PRIMARY KEY,'
          'title TEXT,'
          'amount INTEGER,'
          'date TEXT,'
          'category TEXT)',
        );

        await _createCategoriesTable(db);
        await _seedDefaultCategories(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createCategoriesTable(db);
          await _seedDefaultCategories(db);
        }
      },
    );
  }

  static Future<void> _createCategoriesTable(sql.Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        isDefault INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> _seedDefaultCategories(sql.Database db) async {
    for (final category in defaultCategories) {
      await db.insert(
        'categories',
        {'name': category, 'isDefault': 1},
        conflictAlgorithm: sql.ConflictAlgorithm.ignore,
      );
    }
  }

  static Future<List<String>> fetchCategories() async {
    final db = await DBHelper.getDatabase();
    final rows = await db.query(
      'categories',
      columns: ['name'],
      orderBy: 'isDefault DESC, name COLLATE NOCASE',
    );
    return rows.map((row) => row['name'] as String).toList();
  }

  static Future<int> insertCategory(String name) async {
    final db = await DBHelper.getDatabase();
    return db.insert(
      'categories',
      {'name': name.trim(), 'isDefault': 0},
      conflictAlgorithm: sql.ConflictAlgorithm.ignore,
    );
  }

  static Future<int> deleteCategory(String name) async {
    final db = await DBHelper.getDatabase();
    return db.delete(
      'categories',
      where: 'name = ? AND isDefault = 0',
      whereArgs: [name],
    );
  }

  // Inserting transaction data.
  static Future<void> insert(Transaction transaction) async {
    final db = await DBHelper.getDatabase();
    await db.insert(
      'transactions',
      transaction.toMap(transaction),
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  // Retrieving transaction data.
  static Future<List<Map<String, dynamic>>> fetch() async {
    final db = await DBHelper.getDatabase();
    return db.query('transactions');
  }

  // Deleting transactions.
  static Future<void> delete(String id) async {
    final db = await DBHelper.getDatabase();
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
