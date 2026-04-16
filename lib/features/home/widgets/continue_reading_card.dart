import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/ai_progress_bar.dart';

/// A card showing the user's current reading progress on a book.
class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard({
    super.key,
    required this.bookTitle,
    required this.author,
    required this.currentCheckpoint,
    required this.totalCheckpoints,
    required this.progress,
    required this.onTap,
  });

  final String bookTitle;
  final String author;
  final int currentCheckpoint;
  final int totalCheckpoints;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bookTitle,
              style: AppTypography.cardTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              author,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            AiProgressBar(progress: progress),
            const SizedBox(height: 8),
            Text(
              'Checkpoint $currentCheckpoint of $totalCheckpoints',
              style: AppTypography.micro,
            ),
          ],
        ),
      ),
    );
  }
}
