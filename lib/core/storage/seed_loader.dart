import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

class SeedLoader {
  static Future<void> seedIfNeeded(Database db) async {
    final result = await db.query('categories', limit: 1);
    if (result.isNotEmpty) return;

    await _seedCategories(db);
    await _seedBooks(db);
    await _seedCheckpoints(db);
  }

  static Future<void> _seedCategories(Database db) async {
    final jsonString =
        await rootBundle.loadString('assets/seed/categories.json');
    final List<dynamic> items = json.decode(jsonString) as List<dynamic>;

    await db.transaction((txn) async {
      for (final item in items) {
        await txn.insert(
          'categories',
          Map<String, dynamic>.from(item as Map),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  static Future<void> _seedBooks(Database db) async {
    final jsonString =
        await rootBundle.loadString('assets/seed/books.json');
    final List<dynamic> items = json.decode(jsonString) as List<dynamic>;

    await db.transaction((txn) async {
      for (final item in items) {
        await txn.insert(
          'books',
          Map<String, dynamic>.from(item as Map),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  static Future<void> _seedCheckpoints(Database db) async {
    final jsonString =
        await rootBundle.loadString('assets/seed/checkpoints.json');
    final List<dynamic> items = json.decode(jsonString) as List<dynamic>;

    await db.transaction((txn) async {
      for (final item in items) {
        await txn.insert(
          'checkpoints',
          Map<String, dynamic>.from(item as Map),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
