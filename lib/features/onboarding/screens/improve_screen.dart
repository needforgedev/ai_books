import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/ai_chip.dart';

class ImproveScreen extends StatefulWidget {
  const ImproveScreen({
    super.key,
    required this.onNext,
  });

  final void Function(List<String> selected) onNext;

  @override
  State<ImproveScreen> createState() => _ImproveScreenState();
}

class _ImproveScreenState extends State<ImproveScreen> {
  final Set<String> _selected = {};

  static const List<String> _options = [
    'Focus',
    'Confidence',
    'Habits',
    'Emotional Control',
    'Consistency',
    'Productivity',
    'Relationships',
  ];

  void _toggle(String item) {
    setState(() {
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else {
        _selected.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = _selected.isNotEmpty;
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
                'Which areas do you want to improve?',
                style: AppTypography.tileHeading,
              ),
              const SizedBox(height: 8),
              Text(
                'Pick as many as you like',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _options.map((option) {
                      return AiChip(
                        label: option,
                        isSelected: _selected.contains(option),
                        onTap: () => _toggle(option),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isEnabled
                      ? () => widget.onNext(_selected.toList())
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
