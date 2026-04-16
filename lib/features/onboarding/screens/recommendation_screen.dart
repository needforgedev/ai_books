import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({
    super.key,
    required this.onStartReading,
    required this.onSeeOtherPicks,
  });

  final VoidCallback onStartReading;
  final VoidCallback onSeeOtherPicks;

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Text(
                'YOUR FIRST BOOK IS READY',
                style: AppTypography.sectionHeading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                width: 180,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(
                    color: AppColors.border,
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_stories_rounded,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Atomic Habits',
                style: AppTypography.sectionHeading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'James Clear',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Because you picked Business + build discipline + beginner-friendly reading',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.onStartReading,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    textStyle: AppTypography.buttonLarge,
                    elevation: 0,
                  ),
                  child: const Text('START READING'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onSeeOtherPicks,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: AppTypography.body.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                child: const Text('See 2 Other Picks'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
