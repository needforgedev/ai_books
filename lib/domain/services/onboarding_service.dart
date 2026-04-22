import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:ai_books/core/storage/database_helper.dart';

class OnboardingService {
  static Future<void> saveOnboardingData(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();

    await db.insert(
      'user_profile',
      {
        'id': 1,
        'display_name': data['displayName'] as String?,
        'selected_interests': jsonEncode(data['interests']),
        'selected_goals': jsonEncode(data['goals']),
        'selected_improvement_areas': jsonEncode(data['improvements']),
        'reading_comfort': data['readingComfort'],
        'daily_time_preference': data['dailyMinutes'],
        'streak_goal': data['streakDays'],
        'notification_opt_in': 0,
        'onboarding_completed_at': now,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('user_profile', where: 'id = 1');
    if (result.isEmpty) return null;
    return result.first;
  }

  static Future<void> updateProfile(Map<String, dynamic> updates) async {
    final db = await DatabaseHelper.instance.database;
    updates['updated_at'] = DateTime.now().toIso8601String();
    await db.update('user_profile', updates, where: 'id = 1');
  }
}
