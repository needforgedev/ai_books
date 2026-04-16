import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'seed_loader.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ai_books.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        display_name TEXT,
        selected_interests TEXT,
        selected_goals TEXT,
        selected_improvement_areas TEXT,
        reading_comfort TEXT,
        daily_time_preference INTEGER,
        streak_goal INTEGER,
        notification_opt_in INTEGER DEFAULT 0,
        onboarding_completed_at TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        theme_color TEXT,
        icon_asset TEXT,
        sort_order INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE books (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT,
        author TEXT NOT NULL,
        category_id TEXT NOT NULL,
        difficulty TEXT,
        estimated_minutes INTEGER,
        cover_image TEXT,
        intro_hook TEXT,
        why_it_matters TEXT,
        short_description TEXT,
        interest_tags TEXT,
        goal_tags TEXT,
        improvement_tags TEXT,
        is_featured INTEGER DEFAULT 0,
        next_book_ids TEXT,
        sort_order INTEGER,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE checkpoints (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        checkpoint_order INTEGER NOT NULL,
        title TEXT NOT NULL,
        checkpoint_type TEXT,
        hook_text TEXT,
        explanation_text TEXT,
        modern_example TEXT,
        reflection_prompt TEXT,
        key_quote TEXT,
        image_asset_or_url TEXT,
        recap_text TEXT,
        estimated_minutes INTEGER,
        FOREIGN KEY (book_id) REFERENCES books(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE reading_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id TEXT NOT NULL UNIQUE,
        current_checkpoint_id TEXT,
        completed_checkpoint_ids TEXT,
        completion_percent REAL,
        started_at TEXT,
        last_opened_at TEXT,
        finished_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE saved_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        source_book_id TEXT NOT NULL,
        source_checkpoint_id TEXT,
        saved_text TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE recommendation_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        primary_book_id TEXT NOT NULL,
        alternate_book_ids TEXT,
        reason_text TEXT,
        generated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE streak_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        reading_minutes INTEGER,
        checkpoints_completed INTEGER,
        created_at TEXT
      )
    ''');

    // Indexes
    await db.execute(
        'CREATE INDEX idx_books_category ON books(category_id)');
    await db.execute(
        'CREATE INDEX idx_checkpoints_book ON checkpoints(book_id)');
    await db.execute(
        'CREATE INDEX idx_checkpoints_order ON checkpoints(book_id, checkpoint_order)');
    await db.execute(
        'CREATE INDEX idx_reading_progress_book ON reading_progress(book_id)');
    await db.execute(
        'CREATE INDEX idx_saved_items_book ON saved_items(source_book_id)');
    await db.execute(
        'CREATE INDEX idx_streak_records_date ON streak_records(date)');

    // Seed initial data
    await SeedLoader.seedIfNeeded(db);
  }

  Future<bool> isOnboardingComplete() async {
    final db = await database;
    final result = await db.query(
      'user_profile',
      where: 'onboarding_completed_at IS NOT NULL',
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('streak_records');
    await db.delete('recommendation_results');
    await db.delete('saved_items');
    await db.delete('reading_progress');
    await db.delete('checkpoints');
    await db.delete('books');
    await db.delete('categories');
    await db.delete('user_profile');
  }
}
