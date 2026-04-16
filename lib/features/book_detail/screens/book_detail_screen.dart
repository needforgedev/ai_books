import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({
    super.key,
    required this.bookTitle,
    required this.author,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.checkpointCount,
    required this.coverColor,
    required this.onStartReading,
    this.isInProgress = false,
    this.progressPercent = 0,
  });

  final String bookTitle;
  final String author;
  final String difficulty;
  final int estimatedMinutes;
  final int checkpointCount;
  final Color coverColor;
  final VoidCallback onStartReading;
  final bool isInProgress;
  final int progressPercent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Cover placeholder
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: AppColors.border, width: 0.5),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title and author
                    Text(bookTitle, style: AppTypography.sectionHeading),
                    const SizedBox(height: 4),
                    Text(
                      author,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Metadata pills
                    Row(
                      children: [
                        _MetadataPill(label: difficulty),
                        const SizedBox(width: 8),
                        _MetadataPill(label: '$estimatedMinutes min'),
                        const SizedBox(width: 8),
                        _MetadataPill(label: '$checkpointCount checkpoints'),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Why this book matters
                    Text('Why this book matters', style: AppTypography.cardTitle),
                    const SizedBox(height: 8),
                    Text(
                      'This book challenges conventional thinking and provides a '
                      'framework for understanding the world in a fundamentally '
                      'different way. Drawing on research from psychology, economics, '
                      'and neuroscience, it offers practical insights that can '
                      'transform how you make decisions and navigate uncertainty.',
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: 28),
                    // What you'll learn
                    Text("What you'll learn", style: AppTypography.cardTitle),
                    const SizedBox(height: 12),
                    _BulletPoint(
                      text:
                          'How to identify and overcome common cognitive biases that '
                          'affect your daily decisions',
                    ),
                    _BulletPoint(
                      text:
                          'A practical framework for thinking more clearly under '
                          'pressure and uncertainty',
                    ),
                    _BulletPoint(
                      text:
                          'Why the stories we tell ourselves shape our reality, and '
                          'how to rewrite them',
                    ),
                    _BulletPoint(
                      text:
                          'Strategies for building better habits that stick, backed '
                          'by behavioral science',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onStartReading,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isInProgress
                        ? 'CONTINUE READING ($progressPercent%)'
                        : 'START READING',
                    style: AppTypography.buttonLarge,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataPill extends StatelessWidget {
  const _MetadataPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Expanded(child: Text(text, style: AppTypography.body)),
        ],
      ),
    );
  }
}
