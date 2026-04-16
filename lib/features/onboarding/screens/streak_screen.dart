import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({
    super.key,
    required this.onNext,
  });

  final void Function(int days) onNext;

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  int? _selected;

  static const List<Map<String, dynamic>> _options = [
    {'label': 'No Challenge', 'value': 0},
    {'label': '7 Days', 'value': 7},
    {'label': '14 Days', 'value': 14},
    {'label': '30 Days', 'value': 30},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'Want a reading challenge?',
                style: AppTypography.tileHeading,
              ),
              const SizedBox(height: 8),
              Text(
                'Totally optional. No pressure.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _options.map((option) {
                      final value = option['value'] as int;
                      final isSelected = _selected == value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selected = value;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceCard,
                              borderRadius: BorderRadius.zero,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              option['label'] as String,
                              style: AppTypography.cardTitle.copyWith(
                                color: isSelected
                                    ? AppColors.textOnPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selected != null
                      ? () => widget.onNext(_selected!)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.textOnPrimary,
                    disabledBackgroundColor: AppColors.buttonDisabled,
                    disabledForegroundColor: AppColors.textDisabled,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    textStyle: AppTypography.buttonLarge,
                    elevation: 0,
                  ),
                  child: const Text('NEXT'),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
