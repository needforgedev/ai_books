import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.onEditInterests,
    this.onReminderSettings,
  });

  final VoidCallback? onEditInterests;
  final VoidCallback? onReminderSettings;

  @override
  Widget build(BuildContext context) {
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
                    const _StatItem(label: 'Reading Level', value: 'Beginner'),
                    _divider(),
                    const _StatItem(label: 'Streak', value: '7 days'),
                    _divider(),
                    const _StatItem(label: 'Books', value: '4'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Interests
              const _SectionHeader(title: 'Interests'),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ProfileChip(label: 'Psychology'),
                  _ProfileChip(label: 'Science'),
                  _ProfileChip(label: 'Business'),
                ],
              ),
              const SizedBox(height: 28),
              // Goals
              const _SectionHeader(title: 'Goals'),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ProfileChip(label: 'Read 1 book a week'),
                  _ProfileChip(label: 'Build better habits'),
                  _ProfileChip(label: 'Think more clearly'),
                ],
              ),
              const SizedBox(height: 28),
              // Favorite Categories
              const _SectionHeader(title: 'Favorite Categories'),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ProfileChip(label: 'Self-Improvement'),
                  _ProfileChip(label: 'Behavioral Science'),
                  _ProfileChip(label: 'Entrepreneurship'),
                ],
              ),
              const SizedBox(height: 36),
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onEditInterests,
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
                  onPressed: onReminderSettings,
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
