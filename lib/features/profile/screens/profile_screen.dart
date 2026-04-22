import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/storage/database_helper.dart';
import 'package:ai_books/core/widgets/radial_glow.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/domain/services/streak_service.dart';
import 'package:ai_books/features/profile/screens/edit_interests_screen.dart';
import 'package:ai_books/features/settings/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  String _displayName = '';
  List<String> _interests = [];
  List<String> _goals = [];
  List<String> _improvements = [];
  String _readingComfort = 'Beginner';
  int _dailyMinutes = 0;
  int _streakDays = 0;
  int _booksFinished = 0;
  int _checkpointsCompleted = 0;
  // Active days in the last 7 days (Mon..Sun, where index 0 = Monday).
  List<bool> _weekActivity = List.filled(7, false);
  // Index of "today" in Mon..Sun
  int _todayIndex = 0;
  // Per-category progress: list of (categoryTitle, accent, pct)
  List<_CategoryProgress> _categoryProgress = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final db = await DatabaseHelper.instance.database;

    // Profile row
    final profileRows = await db.query('user_profile', limit: 1);
    if (profileRows.isNotEmpty) {
      final p = profileRows.first;
      _displayName = ((p['display_name'] as String?) ?? '').trim();
      _interests = _decodeJsonList(p['selected_interests'] as String?);
      _goals = _decodeJsonList(p['selected_goals'] as String?);
      _improvements =
          _decodeJsonList(p['selected_improvement_areas'] as String?);
      _readingComfort = (p['reading_comfort'] as String?) ?? 'Beginner';
      _dailyMinutes = (p['daily_time_preference'] as int?) ?? 0;
    }

    // Streak — actual consecutive streak
    _streakDays = await StreakService.getCurrentStreak();

    // Books finished
    final booksRes = await db.rawQuery(
      'SELECT COUNT(*) as c FROM reading_progress WHERE finished_at IS NOT NULL',
    );
    _booksFinished = (booksRes.first['c'] as int?) ?? 0;

    // Total checkpoints completed (sum across all days)
    final cpRes = await db.rawQuery(
      'SELECT COALESCE(SUM(checkpoints_completed), 0) as c FROM streak_records',
    );
    _checkpointsCompleted = (cpRes.first['c'] as int?) ?? 0;

    // Week activity (Mon..Sun anchored to current week)
    _weekActivity = await _loadWeekActivity(db);
    final now = DateTime.now();
    _todayIndex = now.weekday - 1; // Mon=0..Sun=6

    // Category progress
    _categoryProgress = await _loadCategoryProgress(db);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<String> _decodeJsonList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.cast<String>();
    } catch (_) {}
    return const [];
  }

  Future<List<bool>> _loadWeekActivity(Database db) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Start of the current Mon..Sun week
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final formatted = List.generate(7, (i) {
      final d = weekStart.add(Duration(days: i));
      return d.toIso8601String().substring(0, 10);
    });

    final rows = await db.query(
      'streak_records',
      columns: ['date'],
      where: 'date IN (?, ?, ?, ?, ?, ?, ?)',
      whereArgs: formatted,
    );
    final activeDates = <String>{
      for (final r in rows) r['date'] as String,
    };

    return List.generate(
      7,
      (i) => activeDates.contains(formatted[i]),
    );
  }

  Future<List<_CategoryProgress>> _loadCategoryProgress(Database db) async {
    final categories = await ContentService.getCategories();
    final allBooks = await ContentService.getAllBooks();

    final finishedRes = await db.rawQuery(
      'SELECT book_id FROM reading_progress WHERE finished_at IS NOT NULL',
    );
    final finishedIds = <String>{
      for (final r in finishedRes) r['book_id'] as String,
    };

    final result = <_CategoryProgress>[];
    for (final cat in categories) {
      final catBooks = allBooks.where((b) => b.categoryId == cat.id).toList();
      if (catBooks.isEmpty) continue;
      final finishedInCat = catBooks.where((b) => finishedIds.contains(b.id)).length;
      result.add(_CategoryProgress(
        title: cat.title,
        accent: BookVisuals.categoryAccent(cat.id),
        pct: finishedInCat / catBooks.length,
      ));
    }
    return result;
  }

  String get _subtitle {
    final comfort = _readingComfort.isNotEmpty ? _readingComfort : 'Beginner';
    final mins = _dailyMinutes > 0 ? '$_dailyMinutes min/day' : 'No daily goal';
    return '$comfort reader · $mins';
  }

  String get _avatarLetter {
    if (_displayName.isEmpty) return 'R';
    return _displayName.substring(0, 1).toUpperCase();
  }

  String get _displayedName => _displayName.isNotEmpty ? _displayName : 'Reader';

  Future<void> _onEditInterests() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditInterestsScreen(
          initialInterests: List<String>.from(_interests),
          initialGoals: List<String>.from(_goals),
          initialImprovements: List<String>.from(_improvements),
        ),
      ),
    );
    if (result == true) _loadProfileData();
  }

  void _onSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _onResetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Reset progress?', style: AppTypography.titleMedium),
        content: Text(
          'This will clear your reading progress, streak, and saved items. Your profile (name, interests) will be kept.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTypography.button.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Reset',
              style: AppTypography.button.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final db = await DatabaseHelper.instance.database;
    await db.delete('reading_progress');
    await db.delete('saved_items');
    await db.delete('streak_records');
    await db.delete('recommendation_results');
    if (!mounted) return;
    _loadProfileData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress reset')),
    );
  }

  void _onGoGold() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium tier — coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
        ),
      );
    }

    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 120),
          children: [
            // ===== Header =====
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: RadialGlow(
                          color: AppColors.primary,
                          size: 280,
                          opacity: 0.18,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _Avatar(letter: _avatarLetter),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayedName,
                              style: AppTypography.tileHeading.copyWith(
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _subtitle,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ===== Premium card =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PremiumCard(onTap: _onGoGold),
            ),
            const SizedBox(height: 22),

            // ===== Stat trio =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: AppColors.flame,
                      value: '$_streakDays',
                      label: _streakDays == 1 ? 'day streak' : 'day streak',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.check_rounded,
                      iconColor: AppColors.primary,
                      value: '$_booksFinished',
                      label: 'finished',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.layers_rounded,
                      iconColor: AppColors.catScience,
                      value: '$_checkpointsCompleted',
                      label: 'checkpoints',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ===== Streak calendar =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WeekCalendar(
                activity: _weekActivity,
                todayIndex: _todayIndex,
              ),
            ),

            // ===== Category progress =====
            if (_categoryProgress.isNotEmpty) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                child: Text(
                  'Category progress',
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 20,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    for (final c in _categoryProgress) ...[
                      _CategoryRow(progress: c),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ],

            // ===== Preferences =====
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
              child: Text(
                'PREFERENCES',
                style: AppTypography.eyebrow.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _PrefRow(label: 'Edit interests', onTap: _onEditInterests),
                  const SizedBox(height: 6),
                  _PrefRow(label: 'Reminder settings', onTap: _onSettings),
                  const SizedBox(height: 6),
                  _PrefRow(label: 'Reading comfort', onTap: _onEditInterests),
                  const SizedBox(height: 6),
                  _PrefRow(
                    label: 'Reset progress',
                    onTap: _onResetProgress,
                    danger: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: Text(
        letter,
        style: AppTypography.tileHeading.copyWith(
          color: AppColors.textOnPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _CategoryProgress {
  const _CategoryProgress({
    required this.title,
    required this.accent,
    required this.pct,
  });
  final String title;
  final Color accent;
  final double pct;
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.tileHeading.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.micro.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekCalendar extends StatelessWidget {
  const _WeekCalendar({required this.activity, required this.todayIndex});

  final List<bool> activity;
  final int todayIndex;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'THIS WEEK',
                  style: AppTypography.eyebrow.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              Text(
                '7-day goal',
                style: AppTypography.caption.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isActive = activity[i];
              final isToday = i == todayIndex;
              return Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AppColors.primary
                          : isToday
                              ? const Color(0x14FFFFFF)
                              : const Color(0x0AFFFFFF),
                      border: isToday && !isActive
                          ? Border.all(
                              color: AppColors.primary,
                              width: 2,
                              style: BorderStyle.solid,
                            )
                          : null,
                    ),
                    child: isActive
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: AppColors.textOnPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _labels[i],
                    style: AppTypography.micro.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.progress});

  final _CategoryProgress progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  progress.title,
                  style: AppTypography.titleMedium.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(progress.pct * 100).round()}%',
                style: AppTypography.caption.copyWith(color: progress.accent),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 4,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(color: const Color(0x14FFFFFF)),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.pct.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: progress.accent,
                        boxShadow: [
                          BoxShadow(
                            color: progress.accent.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  const _PrefRow({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0x05FFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0x0DFFFFFF),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                  fontSize: 14,
                  color: danger ? AppColors.danger : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: danger ? AppColors.danger : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Premium membership card — gilded gradient with shimmer
// ============================================================================

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.onTap});

  final VoidCallback onTap;

  static const _bgDark = Color(0xFF1A140A);
  static const _bgMid = Color(0xFF2B1F0C);
  static const _bgLight = Color(0xFF3D2A10);
  static const _gold1 = Color(0xFFF5D58A);
  static const _gold2 = Color(0xFFE8A33D);
  static const _goldDeep = Color(0xFFA76A1E);
  static const _ink = Color(0xFFF8E8C4);
  static const _inkDeep = Color(0xFF2A1A05);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Base gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_bgDark, _bgMid, _bgLight],
                    stops: [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Top-right gold glow
            Positioned(
              top: -30,
              right: -30,
              child: IgnorePointer(
                child: RadialGlow(color: _gold2, size: 200, opacity: 0.45),
              ),
            ),
            // Bottom-left soft amber glow
            Positioned(
              bottom: -50,
              left: -50,
              child: IgnorePointer(
                child: RadialGlow(
                  color: const Color(0xFFD4B266),
                  size: 220,
                  opacity: 0.2,
                ),
              ),
            ),
            // Shimmer streak
            Positioned(
              top: -30,
              left: -120,
              bottom: -30,
              child: IgnorePointer(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.skewX(-0.21),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.transparent,
                          const Color(0x24FFEBB4),
                          const Color(0x47FFEBB4),
                          const Color(0x24FFEBB4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Hairline border + inner highlight
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _gold2.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emblem
                      Container(
                        width: 54,
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_gold1, _gold2, _goldDeep],
                            stops: [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _gold2.withValues(alpha: 0.45),
                              offset: const Offset(0, 6),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: _inkDeep,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'SPEEDREAD',
                                  style: AppTypography.eyebrow.copyWith(
                                    color: _gold1,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: const LinearGradient(
                                      colors: [_gold1, _gold2],
                                    ),
                                  ),
                                  child: Text(
                                    'GOLD',
                                    style: AppTypography.eyebrow.copyWith(
                                      color: _inkDeep,
                                      fontSize: 9,
                                      letterSpacing: 1.6,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Unlock the full library.',
                              style: AppTypography.titleLarge.copyWith(
                                fontSize: 20,
                                color: _ink,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '10,000+ books · offline packs · no limits',
                              style: AppTypography.caption.copyWith(
                                color: _ink.withValues(alpha: 0.6),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0x2EE8A33D), width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 12, 14, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$4.99',
                              style: AppTypography.titleLarge.copyWith(
                                fontSize: 22,
                                color: _ink,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ month',
                              style: AppTypography.caption.copyWith(
                                color: _ink.withValues(alpha: 0.55),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$9.99',
                              style: AppTypography.caption.copyWith(
                                color: _ink.withValues(alpha: 0.45),
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_gold1, _gold2],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _gold2.withValues(alpha: 0.4),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Go Gold',
                              style: AppTypography.button.copyWith(
                                color: _inkDeep,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: _inkDeep,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
