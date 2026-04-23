import 'package:ai_books/core/storage/database_helper.dart';
import 'package:ai_books/domain/models/models.dart';

class ContentService {
  /// Convert a snake_case DB row to the camelCase keys expected by CategoryEntry.fromMap
  static Map<String, dynamic> _categoryFromRow(Map<String, dynamic> row) {
    return {
      'id': row['id'],
      'title': row['title'],
      'description': row['description'],
      'themeColor': row['theme_color'],
      'iconAsset': row['icon_asset'],
      'sortOrder': row['sort_order'],
    };
  }

  /// Convert a snake_case DB row to the camelCase keys expected by BookEntry.fromMap
  static Map<String, dynamic> _bookFromRow(Map<String, dynamic> row) {
    return {
      'id': row['id'],
      'title': row['title'],
      'subtitle': row['subtitle'],
      'author': row['author'],
      'categoryId': row['category_id'],
      'difficulty': row['difficulty'],
      'estimatedMinutes': row['estimated_minutes'],
      'coverImage': row['cover_image'],
      'introHook': row['intro_hook'],
      'whyItMatters': row['why_it_matters'],
      'shortDescription': row['short_description'],
      'interestTags': row['interest_tags']?.toString() ?? '[]',
      'goalTags': row['goal_tags']?.toString() ?? '[]',
      'improvementTags': row['improvement_tags']?.toString() ?? '[]',
      'isFeatured': row['is_featured'],
      'nextBookIds': row['next_book_ids']?.toString() ?? '[]',
      'sortOrder': row['sort_order'],
      'mindmapAssetPath': row['mindmap_asset_path'],
    };
  }

  /// Convert a snake_case DB row to the camelCase keys expected by CheckpointEntry.fromMap
  static Map<String, dynamic> _checkpointFromRow(Map<String, dynamic> row) {
    return {
      'id': row['id'],
      'bookId': row['book_id'],
      'checkpointOrder': row['checkpoint_order'],
      'title': row['title'],
      'checkpointType': row['checkpoint_type'],
      'hookText': row['hook_text'],
      'explanationText': row['explanation_text'],
      'modernExample': row['modern_example'],
      'reflectionPrompt': row['reflection_prompt'],
      'keyQuote': row['key_quote'],
      'imageAssetOrUrl': row['image_asset_or_url'],
      'recapText': row['recap_text'],
      'estimatedMinutes': row['estimated_minutes'],
    };
  }

  /// Get all categories ordered by sort_order
  static Future<List<CategoryEntry>> getCategories() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('categories', orderBy: 'sort_order');
    return rows.map((row) => CategoryEntry.fromMap(_categoryFromRow(row))).toList();
  }

  /// Get a single category by id
  static Future<CategoryEntry?> getCategory(String id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return CategoryEntry.fromMap(_categoryFromRow(rows.first));
  }

  /// Get all books for a category, ordered by sort_order
  static Future<List<BookEntry>> getBooksByCategory(String categoryId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'books',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'sort_order',
    );
    return rows.map((row) => BookEntry.fromMap(_bookFromRow(row))).toList();
  }

  /// Get all books (all categories)
  static Future<List<BookEntry>> getAllBooks() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('books', orderBy: 'sort_order');
    return rows.map((row) => BookEntry.fromMap(_bookFromRow(row))).toList();
  }

  /// Get a single book by id
  static Future<BookEntry?> getBook(String bookId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('books', where: 'id = ?', whereArgs: [bookId]);
    if (rows.isEmpty) return null;
    return BookEntry.fromMap(_bookFromRow(rows.first));
  }

  /// Get all checkpoints for a book, ordered by checkpoint_order
  static Future<List<CheckpointEntry>> getCheckpoints(String bookId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'checkpoints',
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'checkpoint_order',
    );
    return rows.map((row) => CheckpointEntry.fromMap(_checkpointFromRow(row))).toList();
  }

  /// Get a single checkpoint by id
  static Future<CheckpointEntry?> getCheckpoint(String checkpointId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('checkpoints', where: 'id = ?', whereArgs: [checkpointId]);
    if (rows.isEmpty) return null;
    return CheckpointEntry.fromMap(_checkpointFromRow(rows.first));
  }

  /// Get book count per category
  static Future<int> getBookCount(String categoryId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM books WHERE category_id = ?',
      [categoryId],
    );
    return result.first['count'] as int;
  }

  /// Get featured books
  static Future<List<BookEntry>> getFeaturedBooks() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'books',
      where: 'is_featured = ?',
      whereArgs: [1],
      orderBy: 'sort_order',
    );
    return rows.map((row) => BookEntry.fromMap(_bookFromRow(row))).toList();
  }
}
