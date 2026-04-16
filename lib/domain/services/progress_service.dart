import 'dart:convert';

import 'package:ai_books/core/storage/database_helper.dart';
import 'package:ai_books/domain/models/models.dart';

class ProgressService {
  /// Convert a snake_case DB row to the camelCase keys expected by ReadingProgress.fromMap
  static Map<String, dynamic> _progressFromRow(Map<String, dynamic> row) {
    return {
      'id': row['id'],
      'bookId': row['book_id'],
      'currentCheckpointId': row['current_checkpoint_id'],
      'completedCheckpointIds': row['completed_checkpoint_ids'],
      'completionPercent': row['completion_percent'],
      'startedAt': row['started_at'],
      'lastOpenedAt': row['last_opened_at'],
      'finishedAt': row['finished_at'],
    };
  }

  /// Get or create reading progress for a book
  static Future<ReadingProgress?> getProgress(String bookId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'reading_progress',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
    if (rows.isEmpty) return null;
    return ReadingProgress.fromMap(_progressFromRow(rows.first));
  }

  /// Start reading a book (create progress row if not exists)
  static Future<ReadingProgress> startBook(
    String bookId,
    String firstCheckpointId,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();

    // Check if progress already exists
    final existing = await getProgress(bookId);
    if (existing != null) {
      // Update last_opened_at and return
      await db.update(
        'reading_progress',
        {'last_opened_at': now},
        where: 'book_id = ?',
        whereArgs: [bookId],
      );
      return existing.copyWith(lastOpenedAt: DateTime.now());
    }

    // Insert new progress row
    await db.insert('reading_progress', {
      'book_id': bookId,
      'current_checkpoint_id': firstCheckpointId,
      'completed_checkpoint_ids': jsonEncode(<String>[]),
      'completion_percent': 0.0,
      'started_at': now,
      'last_opened_at': now,
      'finished_at': null,
    });

    // Return the newly created progress
    final result = await getProgress(bookId);
    return result!;
  }

  /// Mark a checkpoint as completed and advance to next
  static Future<void> completeCheckpoint({
    required String bookId,
    required String completedCheckpointId,
    required String? nextCheckpointId,
    required int totalCheckpoints,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();

    // Query current progress
    final progress = await getProgress(bookId);
    if (progress == null) return;

    // Add completedCheckpointId to the list (avoid duplicates)
    final completedIds = List<String>.from(progress.completedCheckpointIds);
    if (!completedIds.contains(completedCheckpointId)) {
      completedIds.add(completedCheckpointId);
    }

    // Calculate new completion percent
    final completionPercent = completedIds.length / totalCheckpoints;

    // Build update map
    final updates = <String, dynamic>{
      'completed_checkpoint_ids': jsonEncode(completedIds),
      'completion_percent': completionPercent,
      'current_checkpoint_id': nextCheckpointId,
      'last_opened_at': now,
    };

    // If last checkpoint, mark as finished
    if (nextCheckpointId == null) {
      updates['finished_at'] = now;
    }

    await db.update(
      'reading_progress',
      updates,
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
  }

  /// Mark a book as finished
  static Future<void> finishBook(String bookId) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'reading_progress',
      {
        'finished_at': now,
        'last_opened_at': now,
        'completion_percent': 1.0,
      },
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
  }

  /// Get the most recently opened book (for "continue reading")
  static Future<ReadingProgress?> getMostRecentProgress() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'reading_progress',
      where: 'finished_at IS NULL',
      orderBy: 'last_opened_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ReadingProgress.fromMap(_progressFromRow(rows.first));
  }

  /// Get all books in progress (started but not finished)
  static Future<List<ReadingProgress>> getBooksInProgress() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'reading_progress',
      where: 'finished_at IS NULL',
      orderBy: 'last_opened_at DESC',
    );
    return rows
        .map((row) => ReadingProgress.fromMap(_progressFromRow(row)))
        .toList();
  }

  /// Get count of finished books
  static Future<int> getFinishedBookCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reading_progress WHERE finished_at IS NOT NULL',
    );
    return result.first['count'] as int;
  }
}
