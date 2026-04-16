import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

/// A card for categories in the library.
/// Luxury dark style: surfaceCard background, thin accent bar on top, sharp edges.
class AiCategoryCard extends StatelessWidget {
  const AiCategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.themeColor,
    required this.bookCount,
    required this.onTap,
  });

  final String title;
  final String description;
  final Color themeColor;
  final int bookCount;
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thin accent bar on top
            Container(
              height: 3,
              color: themeColor,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon area
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 20,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title + description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppTypography.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Book count badge
                  Text(
                    '$bookCount',
                    style: AppTypography.captionBold.copyWith(
                      color: AppColors.textTertiary,
                    ),
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
