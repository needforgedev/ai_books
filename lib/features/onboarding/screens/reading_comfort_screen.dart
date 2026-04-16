import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

class ReadingComfortScreen extends StatefulWidget {
  const ReadingComfortScreen({
    super.key,
    required this.onNext,
  });

  final void Function(String selected) onNext;

  @override
  State<ReadingComfortScreen> createState() => _ReadingComfortScreenState();
}

class _ReadingComfortScreenState extends State<ReadingComfortScreen> {
  String? _selected;

  static const List<Map<String, String>> _options = [
    {
      'title': 'Beginner',
      'description': 'I rarely read or I\'m just getting started',
    },
    {
      'title': 'Moderate',
      'description': 'I read sometimes and enjoy it when I do',
    },
    {
      'title': 'Advanced',
      'description': 'I read often and love diving into books',
    },
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
                'How comfortable are you with reading?',
                style: AppTypography.tileHeading,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _options.map((option) {
                      final isSelected = _selected == option['title'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selected = option['title'];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['title']!,
                                  style: AppTypography.cardTitle.copyWith(
                                    color: isSelected
                                        ? AppColors.textOnPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option['description']!,
                                  style: AppTypography.caption.copyWith(
                                    color: isSelected
                                        ? AppColors.textOnPrimary
                                        : AppColors.textTertiary,
                                  ),
                                ),
                              ],
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
