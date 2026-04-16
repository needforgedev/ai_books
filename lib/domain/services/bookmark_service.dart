import 'package:ai_books/core/storage/database_helper.dart';
import 'package:ai_books/domain/models/models.dart';

class BookmarkService {
  /// Convert a snake_case DB row to camelCase keys expected by SavedItem.fromMap
  static Map<String, dynamic> _savedItemFromRow(Map<String, dynamic> row) {
    return {
      'id': row['id'],
      'type': row['type'],
      'sourceBookId': row['source_book_id'],
      'sourceCheckpointId': row['source_checkpoint_id'],
      'savedText': row['saved_text'],
      'createdAt': row['created_at'],
    };
  }

  /// Save a quote
  static Future<void> saveQuote({
    required String bookId,
    required String checkpointId,
    required String quoteText,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('saved_items', {
      'type': 'quote',
      'source_book_id': bookId,
      'source_checkpoint_id': checkpointId,
      'saved_text': quoteText,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Save a checkpoint bookmark
  static Future<void> bookmarkCheckpoint({
    required String bookId,
    required String checkpointId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('saved_items', {
      'type': 'bookmark',
      'source_book_id': bookId,
      'source_checkpoint_id': checkpointId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get all saved items (quotes + bookmarks), newest first
  static Future<List<SavedItem>> getAllSaved() async {
    final db = await DatabaseHelper.instance.database;
    final rows =
        await db.query('saved_items', orderBy: 'created_at DESC');
    return rows.map((row) => SavedItem.fromMap(_savedItemFromRow(row))).toList();
  }

  /// Get saved quotes only
  static Future<List<SavedItem>> getQuotes() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'saved_items',
      where: 'type = ?',
      whereArgs: ['quote'],
      orderBy: 'created_at DESC',
    );
    return rows.map((row) => SavedItem.fromMap(_savedItemFromRow(row))).toList();
  }

  /// Get bookmarks only
  static Future<List<SavedItem>> getBookmarks() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'saved_items',
      where: 'type = ?',
      whereArgs: ['bookmark'],
      orderBy: 'created_at DESC',
    );
    return rows.map((row) => SavedItem.fromMap(_savedItemFromRow(row))).toList();
  }

  /// Check if a checkpoint is bookmarked
  static Future<bool> isBookmarked(String checkpointId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'saved_items',
      where: 'type = ? AND source_checkpoint_id = ?',
      whereArgs: ['bookmark', checkpointId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Remove a saved item by id
  static Future<void> removeSaved(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('saved_items', where: 'id = ?', whereArgs: [id]);
  }

  /// Toggle bookmark for a checkpoint (add if not exists, remove if exists)
  /// Returns true if bookmarked, false if removed
  static Future<bool> toggleBookmark({
    required String bookId,
    required String checkpointId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'saved_items',
      where: 'type = ? AND source_checkpoint_id = ?',
      whereArgs: ['bookmark', checkpointId],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      await db.delete(
        'saved_items',
        where: 'id = ?',
        whereArgs: [rows.first['id']],
      );
      return false;
    } else {
      await bookmarkCheckpoint(bookId: bookId, checkpointId: checkpointId);
      return true;
    }
  }
}
