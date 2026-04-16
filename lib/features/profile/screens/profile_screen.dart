import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/storage/database_helper.dart';
import 'package:ai_books/features/profile/screens/edit_interests_screen.dart';
import 'package:ai_books/features/settings/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  List<String> _interests = [];
  List<String> _goals = [];
  List<String> _improvements = [];
  String _readingComfort = 'Beginner';
  int _booksCompleted = 0;
  int _streakDays = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final db = await DatabaseHelper.instance.database;

    // Load user profile
    final profileRows = await db.query('user_profile', limit: 1);
    if (profileRows.isNotEmpty) {
      final profile = profileRows.first;
      final interestsRaw = profile['selected_interests'] as String?;
      final goalsRaw = profile['selected_goals'] as String?;
      final improvementsRaw = profile['selected_improvement_areas'] as String?;
      final comfortRaw = profile['reading_comfort'] as String?;

      _interests = _decodeJsonList(interestsRaw);
      _goals = _decodeJsonList(goalsRaw);
      _improvements = _decodeJsonList(improvementsRaw);
      _readingComfort = comfortRaw ?? 'Beginner';
    }

    // Load books completed count
    final booksResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reading_progress WHERE finished_at IS NOT NULL',
    );
    _booksCompleted = (booksResult.first['count'] as int?) ?? 0;

    // Load streak days (simple count of streak_records as placeholder)
    final streakResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM streak_records',
    );
    _streakDays = (streakResult.first['count'] as int?) ?? 0;

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _decodeJsonList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.cast<String>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _navigateToEditInterests() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditInterestsScreen(
          initialInterests: List<String>.from(_interests),
          initialGoals: List<String>.from(_goals),
          initialImprovements: List<String>.from(_improvements),
        ),
      ),
    );
    if (result == true) {
      _loadProfileData();
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Avatar
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.surfaceCard,
                child: Icon(
                  Icons.person_rounded,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text('Reader', style: AppTypography.cardTitle),
              const SizedBox(height: 4),
              Text(
                'Joined April 2026',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              // Stats row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _StatItem(label: 'Reading Level', value: _readingComfort),
                    _divider(),
                    _StatItem(
                      label: 'Streak',
                      value: '$_streakDays day${_streakDays == 1 ? '' : 's'}',
                    ),
                    _divider(),
                    _StatItem(label: 'Books', value: '$_booksCompleted'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Interests
              if (_interests.isNotEmpty) ...[
                const _SectionHeader(title: 'Interests'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _interests
                      .map((label) => _ProfileChip(label: label))
                      .toList(),
                ),
                const SizedBox(height: 28),
              ],
              // Goals
              if (_goals.isNotEmpty) ...[
                const _SectionHeader(title: 'Goals'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _goals.map((label) => _ProfileChip(label: label)).toList(),
                ),
                const SizedBox(height: 28),
              ],
              // Areas to Improve
              if (_improvements.isNotEmpty) ...[
                const _SectionHeader(title: 'Areas to Improve'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _improvements
                      .map((label) => _ProfileChip(label: label))
                      .toList(),
                ),
                const SizedBox(height: 28),
              ],
              const SizedBox(height: 8),
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _navigateToEditInterests,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'EDIT INTERESTS',
                    style: AppTypography.button.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _navigateToSettings,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'REMINDER SETTINGS',
                    style: AppTypography.button.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.border,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: AppTypography.cardTitle),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.bodyEmphasis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.micro,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
