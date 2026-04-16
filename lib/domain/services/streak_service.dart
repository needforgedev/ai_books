import 'package:ai_books/core/storage/database_helper.dart';

class StreakService {
  /// Record reading activity for today.
  /// Call this whenever the user completes a checkpoint or spends time reading.
  static Future<void> recordActivity({
    int additionalMinutes = 0,
    int additionalCheckpoints = 0,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final existing = await db.query(
      'streak_records',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (existing.isNotEmpty) {
      final row = existing.first;
      await db.update(
        'streak_records',
        {
          'reading_minutes':
              (row['reading_minutes'] as int? ?? 0) + additionalMinutes,
          'checkpoints_completed':
              (row['checkpoints_completed'] as int? ?? 0) +
                  additionalCheckpoints,
        },
        where: 'date = ?',
        whereArgs: [today],
      );
    } else {
      await db.insert('streak_records', {
        'date': today,
        'reading_minutes': additionalMinutes,
        'checkpoints_completed': additionalCheckpoints,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Get the current streak (consecutive days ending today or yesterday)
  static Future<int> getCurrentStreak() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'streak_records',
      columns: ['date'],
      orderBy: 'date DESC',
    );

    if (results.isEmpty) return 0;

    final dates = results
        .map((r) => DateTime.parse(r['date'] as String))
        .toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Start from today or yesterday
    DateTime checkDate = today;
    final firstRecordDate = DateTime(
      dates.first.year,
      dates.first.month,
      dates.first.day,
    );

    // If today has no record, start from yesterday
    if (firstRecordDate.isBefore(today)) {
      checkDate = today.subtract(const Duration(days: 1));
    }

    int streak = 0;
    final dateSet = <String>{};
    for (final d in dates) {
      dateSet.add(d.toIso8601String().substring(0, 10));
    }

    while (dateSet.contains(checkDate.toIso8601String().substring(0, 10))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Get today's reading stats
  static Future<Map<String, int>> getTodayStats() async {
    final db = await DatabaseHelper.instance.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final results = await db.query(
      'streak_records',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (results.isEmpty) {
      return {'minutes': 0, 'checkpoints': 0};
    }

    final row = results.first;
    return {
      'minutes': row['reading_minutes'] as int? ?? 0,
      'checkpoints': row['checkpoints_completed'] as int? ?? 0,
    };
  }

  /// Get total reading minutes across all days
  static Future<int> getTotalMinutes() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(reading_minutes), 0) as total FROM streak_records',
    );
    return result.first['total'] as int? ?? 0;
  }

  /// Get streak goal from user profile
  static Future<int> getStreakGoal() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'user_profile',
      columns: ['streak_goal'],
      limit: 1,
    );
    if (results.isEmpty) return 7; // default goal
    return results.first['streak_goal'] as int? ?? 7;
  }
}
