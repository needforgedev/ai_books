import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _reducedMotion = false;
  int _textSizeIndex = 1; // 0=Small, 1=Medium, 2=Large
  int _darkModeIndex = 0; // 0=System, 1=Light, 2=Dark

  static const _textSizeLabels = ['Small', 'Medium', 'Large'];
  static const _darkModeLabels = ['System', 'Light', 'Dark'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('SETTINGS', style: AppTypography.sectionHeading),
              const SizedBox(height: 24),
              // Notifications
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Notifications',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Daily reading reminders',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _notificationsEnabled,
                activeTrackColor: AppColors.primary,
                activeThumbColor: AppColors.surface,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
              _settingDivider(),
              // Text Size
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Text Size',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SegmentedToggle(
                      labels: _textSizeLabels,
                      selectedIndex: _textSizeIndex,
                      onSelected: (index) {
                        setState(() => _textSizeIndex = index);
                      },
                    ),
                  ],
                ),
              ),
              _settingDivider(),
              // Reduced Motion
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Reduced Motion',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Minimize animations',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _reducedMotion,
                activeTrackColor: AppColors.primary,
                activeThumbColor: AppColors.surface,
                onChanged: (value) {
                  setState(() => _reducedMotion = value);
                },
              ),
              _settingDivider(),
              // Dark Mode
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SegmentedToggle(
                      labels: _darkModeLabels,
                      selectedIndex: _darkModeIndex,
                      onSelected: (index) {
                        setState(() => _darkModeIndex = index);
                      },
                    ),
                  ],
                ),
              ),
              _settingDivider(),
              // Reset Profile
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.danger,
                  size: 22,
                ),
                title: Text(
                  'Reset Profile',
                  style: AppTypography.body.copyWith(
                    color: AppColors.danger,
                  ),
                ),
                subtitle: Text(
                  'Clear all progress and preferences',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () => _showResetDialog(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingDivider() {
    return const Divider(
      height: 1,
      color: AppColors.border,
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          'Reset Profile?',
          style: AppTypography.cardTitle,
        ),
        content: Text(
          'This will clear all your reading progress, bookmarks, and '
          'preferences. This action cannot be undone.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reset action would go here
            },
            child: Text(
              'Reset',
              style: AppTypography.button.copyWith(
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                margin: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: AppTypography.caption.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textTertiary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
