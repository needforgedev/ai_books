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
  DateTime? _joinedAt;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final db = await DatabaseHelper.instance.database;

    final profileRows = await db.query('user_profile', limit: 1);
    if (profileRows.isNotEmpty) {
      final profile = profileRows.first;
      final interestsRaw = profile['selected_interests'] as String?;
      final goalsRaw = profile['selected_goals'] as String?;
      final improvementsRaw =
          profile['selected_improvement_areas'] as String?;
      final comfortRaw = profile['reading_comfort'] as String?;
      final createdAtRaw = profile['created_at'] as String?;

      _interests = _decodeJsonList(interestsRaw);
      _goals = _decodeJsonList(goalsRaw);
      _improvements = _decodeJsonList(improvementsRaw);
      _readingComfort = comfortRaw ?? 'Beginner';
      if (createdAtRaw != null) {
        _joinedAt = DateTime.tryParse(createdAtRaw);
      }
    }

    final booksResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reading_progress WHERE finished_at IS NOT NULL',
    );
    _booksCompleted = (booksResult.first['count'] as int?) ?? 0;

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
      if (decoded is List) return decoded.cast<String>();
      return [];
    } catch (_) {
      return [];
    }
  }

  String _formatJoined(DateTime? dt) {
    if (dt == null) return 'New member';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return 'Joined ${months[dt.month - 1]} ${dt.year}';
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
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
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
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Reader',
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatJoined(_joinedAt),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Premium membership card
            _PremiumCard(),
            const SizedBox(height: 18),
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Reading Level',
                    value: _readingComfort,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Streak',
                    value:
                        '$_streakDays ${_streakDays == 1 ? 'day' : 'days'}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Books',
                    value: '$_booksCompleted',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (_interests.isNotEmpty) ...[
              _buildSection('INTERESTS', _interests),
              const SizedBox(height: 24),
            ],
            if (_goals.isNotEmpty) ...[
              _buildSection('GOALS', _goals),
              const SizedBox(height: 24),
            ],
            if (_improvements.isNotEmpty) ...[
              _buildSection('AREAS TO IMPROVE', _improvements),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 8),
            // Buttons
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _navigateToEditInterests,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Edit Interests',
                  style: AppTypography.button.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _navigateToSettings,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Reminder Settings',
                  style: AppTypography.button.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.eyebrow.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((label) => _ProfileChip(label: label)).toList(),
        ),
      ],
    );
  }
}

class _PremiumCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4B266).withValues(alpha: 0.25),
            const Color(0xFFD4B266).withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFD4B266).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD4B266).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFD4B266).withValues(alpha: 0.6),
              ),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFE8C87A),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '10,000+ books · premium tier',
                  style: AppTypography.bodyEmphasis.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unlock every checkpoint + AI discussions',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Go Gold',
                style: AppTypography.button.copyWith(
                  color: const Color(0xFFE8C87A),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFFE8C87A),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.micro.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSubtle),
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
