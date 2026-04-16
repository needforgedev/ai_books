import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/ai_book_card.dart';
import 'package:ai_books/features/home/widgets/continue_reading_card.dart';

/// The main home screen with greeting, continue reading, recommendations,
/// and category chips.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            // -- Header --
            Text(
              'HELLO THERE',
              style: AppTypography.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatBadge(label: 'Streak: 4 days'),
                const SizedBox(width: 8),
                _StatBadge(label: 'Books: 2'),
              ],
            ),
            const SizedBox(height: 24),

            // -- Continue Reading --
            Text(
              'CONTINUE READING',
              style: AppTypography.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ContinueReadingCard(
              bookTitle: 'Meditations',
              author: 'Marcus Aurelius',
              currentCheckpoint: 3,
              totalCheckpoints: 6,
              progress: 0.5,
              onTap: () {},
            ),
            const SizedBox(height: 24),

            // -- Recommended For You --
            Text(
              'RECOMMENDED',
              style: AppTypography.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: 160,
                    child: AiBookCard(
                      title: 'Atomic Habits',
                      author: 'James Clear',
                      coverColor: const Color(0xFFFF9500),
                      difficulty: 'Beginner',
                      estimatedMinutes: 15,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 160,
                    child: AiBookCard(
                      title: 'Thinking Fast and Slow',
                      author: 'Daniel Kahneman',
                      coverColor: const Color(0xFF4A90D9),
                      difficulty: 'Moderate',
                      estimatedMinutes: 20,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 160,
                    child: AiBookCard(
                      title: 'The Lean Startup',
                      author: 'Eric Ries',
                      coverColor: const Color(0xFF34C759),
                      difficulty: 'Beginner',
                      estimatedMinutes: 12,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // -- Categories --
            Text(
              'CATEGORIES',
              style: AppTypography.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  _CategoryChip(
                    label: 'Science',
                    color: AppColors.scienceColor,
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Business',
                    color: AppColors.businessColor,
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Personal Development',
                    color: AppColors.personalDevColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Small badge showing a stat (e.g. "Streak: 4 days").
class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Text(
        label,
        style: AppTypography.micro.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// A small colored chip representing a category.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
