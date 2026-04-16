import 'dart:convert';
import 'package:ai_books/core/storage/database_helper.dart';
import 'package:ai_books/domain/models/book_entry.dart';

class RecommendationService {
  /// Returns a map with 'primary' [BookEntry], 'alternates' (list of
  /// [BookEntry]), and 'reason' (String).
  static Future<Map<String, dynamic>> getRecommendations({
    required List<String> interests,
    required List<String> goals,
    required List<String> improvements,
    required String readingComfort,
  }) async {
    final db = await DatabaseHelper.instance.database;

    // Query all books from SQLite
    final rows = await db.query('books');

    // Convert rows to BookEntry objects (DB uses snake_case keys)
    final books = rows.map((row) {
      return BookEntry.fromMap({
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
      });
    }).toList();

    // Lowercase user preferences for case-insensitive matching
    final userInterests = interests.map((e) => e.toLowerCase()).toSet();
    final userGoals = goals.map((e) => e.toLowerCase()).toSet();
    final userImprovements = improvements.map((e) => e.toLowerCase()).toSet();
    final userComfort = readingComfort.toLowerCase();

    // Score each book
    final scored = <MapEntry<BookEntry, int>>[];
    for (final book in books) {
      int score = 0;

      // +3 per matching interest tag
      for (final tag in book.interestTags) {
        if (userInterests.contains(tag.toLowerCase())) {
          score += 3;
        }
      }

      // +2 per matching goal tag
      for (final tag in book.goalTags) {
        if (userGoals.contains(tag.toLowerCase())) {
          score += 2;
        }
      }

      // +1 per matching improvement tag
      for (final tag in book.improvementTags) {
        if (userImprovements.contains(tag.toLowerCase())) {
          score += 1;
        }
      }

      // +5 if difficulty matches readingComfort
      final bookDifficulty = book.difficulty.toLowerCase();
      if (bookDifficulty == userComfort) {
        score += 5;
      }

      // Extra +3 if both are beginner
      if (bookDifficulty == 'beginner' && userComfort == 'beginner') {
        score += 3;
      }

      scored.add(MapEntry(book, score));
    }

    // Sort by score descending
    scored.sort((a, b) => b.value.compareTo(a.value));

    // Pick top book as primary, next 2 as alternates
    final primary = scored.isNotEmpty ? scored[0].key : books.first;
    final alternates = <BookEntry>[];
    if (scored.length > 1) alternates.add(scored[1].key);
    if (scored.length > 2) alternates.add(scored[2].key);

    // Generate reason string
    final firstInterest = _findFirstMatch(
      primary.interestTags,
      userInterests,
    );
    final firstGoal = _findFirstMatch(
      primary.goalTags,
      userGoals,
    );
    final difficultyLabel = '${primary.difficulty.toLowerCase()}-friendly';

    final reasonParts = <String>[];
    if (firstInterest != null) reasonParts.add(firstInterest);
    if (firstGoal != null) reasonParts.add(firstGoal);
    reasonParts.add('$difficultyLabel reading');
    final reason = 'Because you picked ${reasonParts.join(' + ')}';

    // Save to recommendation_results table
    final now = DateTime.now().toIso8601String();
    await db.insert('recommendation_results', {
      'primary_book_id': primary.id,
      'alternate_book_ids': jsonEncode(alternates.map((b) => b.id).toList()),
      'reason_text': reason,
      'generated_at': now,
    });

    return {
      'primary': primary,
      'alternates': alternates,
      'reason': reason,
    };
  }

  /// Finds the first tag that matches a user preference set.
  static String? _findFirstMatch(
    List<String> tags,
    Set<String> userPrefs,
  ) {
    for (final tag in tags) {
      if (userPrefs.contains(tag.toLowerCase())) {
        return tag;
      }
    }
    return null;
  }
}
