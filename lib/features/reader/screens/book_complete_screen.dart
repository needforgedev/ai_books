import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

class BookCompleteScreen extends StatelessWidget {
  const BookCompleteScreen({
    super.key,
    required this.bookTitle,
    required this.gains,
    required this.nextBookTitle,
    this.onReadNext,
    this.onExplore,
  });

  final String bookTitle;
  final List<String> gains;
  final String nextBookTitle;
  final VoidCallback? onReadNext;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Celebration area
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border.all(color: AppColors.border),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Title
              Text(
                'BOOK COMPLETE',
                style: AppTypography.sectionHeading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You finished $bookTitle',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              // What you gained
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'What you gained',
                  style: AppTypography.cardTitle,
                ),
              ),
              const SizedBox(height: 12),
              ...gains.map(
                (gain) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(gain, style: AppTypography.body),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Next for you
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Next for you', style: AppTypography.cardTitle),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 24,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextBookTitle,
                            style: AppTypography.bodyEmphasis,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Recommended for you',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onReadNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'READ NEXT',
                    style: AppTypography.buttonLarge.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onExplore,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'EXPLORE',
                    style: AppTypography.button.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
