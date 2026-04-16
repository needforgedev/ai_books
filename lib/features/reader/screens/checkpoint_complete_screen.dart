import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

class CheckpointCompleteScreen extends StatelessWidget {
  const CheckpointCompleteScreen({
    super.key,
    required this.checkpointNumber,
    required this.totalCheckpoints,
    required this.keyTakeaway,
    this.onContinue,
    this.onReturnHome,
  });

  final int checkpointNumber;
  final int totalCheckpoints;
  final String keyTakeaway;
  final VoidCallback? onContinue;
  final VoidCallback? onReturnHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Checkmark icon
              const Icon(
                Icons.check_rounded,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 28),
              // Title
              Text(
                'CHECKPOINT COMPLETE',
                style: AppTypography.sectionHeading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Progress
              Text(
                '$checkpointNumber of $totalCheckpoints finished',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // Key takeaway card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Key Takeaway', style: AppTypography.cardTitle),
                    const SizedBox(height: 8),
                    Text(keyTakeaway, style: AppTypography.body),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'CONTINUE',
                    style: AppTypography.buttonLarge.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Return Home button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: onReturnHome,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'Return Home',
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
}
