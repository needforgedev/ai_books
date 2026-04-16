import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

/// A reusable book card widget for showing books in lists/grids.
/// Luxury dark style: surfaceCard background, sharp edges, thin border.
class AiBookCard extends StatelessWidget {
  const AiBookCard({
    super.key,
    required this.title,
    required this.author,
    required this.coverColor,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.onTap,
  });

  final String title;
  final String author;
  final Color coverColor;
  final String difficulty;
  final int estimatedMinutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover placeholder
            Flexible(
              child: Container(
                constraints: const BoxConstraints(minHeight: 100),
                width: double.infinity,
                color: Color.alphaBlend(
                  coverColor.withValues(alpha: 0.6),
                  AppColors.surface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.cardTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _InfoTag(label: difficulty),
                      _InfoTag(label: '$estimatedMinutes min'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: AppTypography.micro,
      ),
    );
  }
}
