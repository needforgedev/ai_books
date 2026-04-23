import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/book_cover.dart';
import 'package:ai_books/core/widgets/radial_glow.dart';
import 'package:ai_books/domain/models/book_entry.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({
    super.key,
    required this.onStartReading,
    required this.onSeeOtherPicks,
    this.onExplore,
    this.book,
    this.reasonText = '',
    this.alternateCount = 2,
  });

  final VoidCallback onStartReading;
  final VoidCallback onSeeOtherPicks;

  /// Fired when the engine returned no book and the user taps "Explore library".
  final VoidCallback? onExplore;
  final BookEntry? book;
  final String reasonText;
  final int alternateCount;

  @override
  Widget build(BuildContext context) {
    final b = book;

    // Engine returned nothing — surface an honest empty state that
    // routes the user to the library.
    if (b == null) {
      return _NoMatchState(onExplore: onExplore);
    }

    final palette = BookVisuals.forBook(b.id, categoryId: b.categoryId);
    final accent = palette.accent;

    final title = b.title;
    final author = b.author;
    final difficulty = b.difficulty;
    final minutes = b.estimatedMinutes;
    final categoryLabel = _categoryLabel(b.categoryId);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                'YOUR MATCH',
                style: AppTypography.eyebrow.copyWith(color: accent),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 360,
                        height: 320,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            RadialGlow(color: accent, size: 360, opacity: 0.25),
                            BookCover(
                              title: title,
                              author: author,
                              category: categoryLabel,
                              palette: palette,
                              width: 190,
                              height: 285,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        title,
                        style: AppTypography.tileHeading,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'by $author',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _TaglineText(accent: accent),
                      const SizedBox(height: 14),
                      Text(
                        '$minutes min  ·  6 checkpoints  ·  $difficulty',
                        style: AppTypography.caption,
                      ),
                      if (reasonText.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          reasonText,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onStartReading,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 22),
                      const SizedBox(width: 6),
                      Text('Start reading', style: AppTypography.buttonLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onSeeOtherPicks,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'See $alternateCount other picks for you',
                    style: AppTypography.button.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(String id) {
    switch (id) {
      case 'science':
        return 'Science';
      case 'business':
        return 'Business';
      case 'personal_development':
        return 'Personal';
      default:
        return id.replaceAll('_', ' ');
    }
  }
}

class _NoMatchState extends StatelessWidget {
  const _NoMatchState({required this.onExplore});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                'YOUR MATCH',
                style: AppTypography.eyebrow.copyWith(color: AppColors.primary),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No match yet',
                        style: AppTypography.tileHeading,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "We couldn't lock in a pick from your answers. Take a look around — you'll know the right book when you see it.",
                          style: AppTypography.body.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onExplore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Explore library',
                        style: AppTypography.buttonLarge,
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.textOnPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaglineText extends StatelessWidget {
  const _TaglineText({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.body.copyWith(color: AppColors.textSecondary);
    final hot = base.copyWith(color: accent, fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: base,
          children: [
            const TextSpan(text: 'Matched on '),
            TextSpan(text: 'mindset', style: hot),
            const TextSpan(text: ', '),
            TextSpan(text: 'clarity', style: hot),
            const TextSpan(text: ', and '),
            TextSpan(text: 'beginner-friendly', style: hot),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
