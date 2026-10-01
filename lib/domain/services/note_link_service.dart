import 'package:ai_books/core/storage/database_helper.dart';
import 'package:ai_books/domain/models/models.dart';

class NoteLinkService {
  static Future<void> createLink({
    required int fromId,
    required int toId,
    String? label,
  }) async {
    if (await linkExists(fromId, toId)) return;
    final db = await DatabaseHelper.instance.database;
    await db.insert('note_links', {
      'from_saved_item_id': fromId,
      'to_saved_item_id': toId,
      'label': label,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<bool> linkExists(int fromId, int toId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT id FROM note_links
      WHERE (from_saved_item_id = ? AND to_saved_item_id = ?)
         OR (from_saved_item_id = ? AND to_saved_item_id = ?)
      LIMIT 1
    ''', [fromId, toId, toId, fromId]);
    return rows.isNotEmpty;
  }

  static Future<List<NoteLink>> getLinksForItem(int savedItemId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT * FROM note_links
      WHERE from_saved_item_id = ? OR to_saved_item_id = ?
      ORDER BY created_at DESC
    ''', [savedItemId, savedItemId]);
    return rows.map(NoteLink.fromMap).toList();
  }

  /// Returns all distinct link pairs as [NoteLink] list, newest first.
  static Future<List<NoteLink>> getAllLinks() async {
    final db = await DatabaseHelper.instance.database;
    final rows =
        await db.query('note_links', orderBy: 'created_at DESC');
    return rows.map(NoteLink.fromMap).toList();
  }

  static Future<int> getLinkCount() async {
    final db = await DatabaseHelper.instance.database;
    final res =
        await db.rawQuery('SELECT COUNT(*) as c FROM note_links');
    return (res.first['c'] as int?) ?? 0;
  }

  static Future<void> deleteLink(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('note_links', where: 'id = ?', whereArgs: [id]);
  }
}
