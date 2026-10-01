import 'package:ai_books/core/storage/database_helper.dart';
import 'package:ai_books/domain/models/models.dart';

class QuizService {
  // Bucket → days until next review
  static const _bucketDays = [0, 1, 3, 7];

  static Future<void> createCard({
    required int savedItemId,
    required String fullText,
    required int blankStart,
    required int blankLength,
    required String correctAnswer,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('quiz_cards', {
      'saved_item_id': savedItemId,
      'full_text': fullText,
      'blank_start': blankStart,
      'blank_length': blankLength,
      'correct_answer': correctAnswer,
      'times_shown': 0,
      'times_correct': 0,
      'next_review_at': null,
      'review_bucket': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<QuizCard>> getDueCards() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();
    final rows = await db.rawQuery('''
      SELECT * FROM quiz_cards
      WHERE next_review_at IS NULL OR next_review_at <= ?
      ORDER BY next_review_at ASC, created_at ASC
    ''', [now]);
    return rows.map(QuizCard.fromMap).toList();
  }

  static Future<List<QuizCard>> getAllCards() async {
    final db = await DatabaseHelper.instance.database;
    final rows =
        await db.query('quiz_cards', orderBy: 'created_at DESC');
    return rows.map(QuizCard.fromMap).toList();
  }

  static Future<int> getTotalCardCount() async {
    final db = await DatabaseHelper.instance.database;
    final res =
        await db.rawQuery('SELECT COUNT(*) as c FROM quiz_cards');
    return (res.first['c'] as int?) ?? 0;
  }

  static Future<int> getDueCardCount() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();
    final res = await db.rawQuery('''
      SELECT COUNT(*) as c FROM quiz_cards
      WHERE next_review_at IS NULL OR next_review_at <= ?
    ''', [now]);
    return (res.first['c'] as int?) ?? 0;
  }

  /// Records an attempt and advances the spaced-repetition bucket.
  /// bucket 0=new, 1=again(1d), 2=soon(3d), 3=later(7d)
  static Future<void> recordAttempt(int cardId, bool wasCorrect) async {
    final db = await DatabaseHelper.instance.database;
    final rows =
        await db.query('quiz_cards', where: 'id = ?', whereArgs: [cardId]);
    if (rows.isEmpty) return;

    final card = QuizCard.fromMap(rows.first);
    final newBucket = wasCorrect
        ? (card.reviewBucket + 1).clamp(0, 3)
        : 1; // wrong → back to "again (1d)"

    final days = _bucketDays[newBucket];
    final nextReview = days == 0
        ? null
        : DateTime.now().add(Duration(days: days)).toIso8601String();

    await db.update(
      'quiz_cards',
      {
        'times_shown': card.timesShown + 1,
        'times_correct': card.timesCorrect + (wasCorrect ? 1 : 0),
        'review_bucket': newBucket,
        'next_review_at': nextReview,
      },
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  static Future<void> deleteCard(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('quiz_cards', where: 'id = ?', whereArgs: [id]);
  }

  /// Logs a completed session and returns XP earned (10 per correct answer).
  static Future<int> logSession({
    required int cardsReviewed,
    required int cardsCorrect,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final xp = cardsCorrect * 10;
    await db.insert('review_sessions', {
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'cards_reviewed': cardsReviewed,
      'cards_correct': cardsCorrect,
      'xp_earned': xp,
      'created_at': DateTime.now().toIso8601String(),
    });
    return xp;
  }

  static Future<int> getLifetimeXP() async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery(
        'SELECT COALESCE(SUM(xp_earned), 0) as total FROM review_sessions');
    return (res.first['total'] as int?) ?? 0;
  }

  static Future<double> getAllTimeAccuracy() async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery('''
      SELECT
        COALESCE(SUM(times_shown), 0) as shown,
        COALESCE(SUM(times_correct), 0) as correct
      FROM quiz_cards
    ''');
    final shown = (res.first['shown'] as int?) ?? 0;
    final correct = (res.first['correct'] as int?) ?? 0;
    if (shown == 0) return 0;
    return correct / shown;
  }
}
