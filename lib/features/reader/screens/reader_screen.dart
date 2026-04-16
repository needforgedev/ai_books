import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({
    super.key,
    required this.bookTitle,
    required this.checkpointTitle,
    required this.currentCheckpoint,
    required this.totalCheckpoints,
    this.onBookmark,
    this.onReflect,
    this.onNext,
  });

  final String bookTitle;
  final String checkpointTitle;
  final int currentCheckpoint;
  final int totalCheckpoints;
  final VoidCallback? onBookmark;
  final VoidCallback? onReflect;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          bookTitle,
          style: AppTypography.bodyEmphasis.copyWith(
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$currentCheckpoint/$totalCheckpoints',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Checkpoint title
                    Text(checkpointTitle, style: AppTypography.tileHeading),
                    const SizedBox(height: 20),
                    // Concept illustration placeholder
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Explanation text
                    Text(
                      'Our brains are wired to take shortcuts. These mental '
                      'shortcuts, known as heuristics, help us make quick decisions '
                      'in a complex world. But they can also lead us astray.\n\n'
                      'Think about the last time you made a snap judgment about '
                      'someone or something. That instant reaction was your '
                      'fast-thinking system at work. It operates automatically and '
                      'effortlessly, but it is also prone to systematic errors.\n\n'
                      'The key insight is that we are not as rational as we think. '
                      'Understanding this is the first step toward making better '
                      'decisions in every area of life.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Key Quote card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        border: const Border(
                          left: BorderSide(
                            color: AppColors.accent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"Nothing in life is as important as you think it is, '
                            'while you are thinking about it."',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textPrimary,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 40,
                            height: 1,
                            color: AppColors.border,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'What this means',
                            style: AppTypography.captionBold,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'We tend to overvalue whatever we are currently focused '
                            'on. This focusing illusion affects everything from '
                            'career choices to happiness predictions.',
                            style: AppTypography.body,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Modern Example section
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
                          Text(
                            'Modern Example',
                            style: AppTypography.captionBold,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Think about social media algorithms. When you scroll '
                            'through your feed, the content you see is designed to '
                            'trigger your fast-thinking system. Outrage, surprise, '
                            'and fear all bypass your rational mind. Recognizing '
                            'this is the first step to consuming content more '
                            'deliberately.',
                            style: AppTypography.body,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Reflection Prompt
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reflect',
                            style: AppTypography.captionBold.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Think of a recent decision you made quickly. Looking '
                            'back, was your fast-thinking system helping you or '
                            'leading you astray?',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: onReflect,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'SAVE THOUGHT',
                                style: AppTypography.button.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            // Fixed bottom bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  // Bookmark button
                  _BottomBarIconButton(
                    icon: Icons.bookmark_outline_rounded,
                    onTap: onBookmark,
                  ),
                  const SizedBox(width: 12),
                  // Reflect button
                  _BottomBarIconButton(
                    icon: Icons.edit_note_rounded,
                    onTap: onReflect,
                  ),
                  const Spacer(),
                  // Next button
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'NEXT',
                            style: AppTypography.button.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
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

class _BottomBarIconButton extends StatelessWidget {
  const _BottomBarIconButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, color: AppColors.textSecondary, size: 22),
      ),
    );
  }
}
