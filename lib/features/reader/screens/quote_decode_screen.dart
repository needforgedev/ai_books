import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/radial_glow.dart';

/// A dedicated screen for decoding a key quote — reached by tapping the
/// accent quote pull in the reader.
class QuoteDecodeScreen extends StatelessWidget {
  const QuoteDecodeScreen({
    super.key,
    required this.quote,
    required this.author,
    required this.meaning,
    required this.palette,
    this.onSave,
  });

  final String quote;
  final String author;
  final String meaning;
  final BookPalette palette;
  final Future<void> Function()? onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Atmospheric glow
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: RadialGlow(
                color: palette.accent,
                size: 400,
                opacity: 0.15,
              ),
            ),
          ),
          // Close button
          Positioned(
            top: 0,
            right: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          // Body
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Big quote icon
                  Center(
                    child: Icon(
                      Icons.format_quote_rounded,
                      size: 64,
                      color: palette.accent.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quote text
                  Text(
                    quote,
                    textAlign: TextAlign.center,
                    style: AppTypography.displayItalic(
                      32,
                      color: AppColors.textPrimary,
                    ).copyWith(
                      height: 1.2,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      '— $author'.toUpperCase(),
                      style: AppTypography.eyebrow.copyWith(
                        color: palette.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // "What this means" card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WHAT THIS MEANS',
                          style: AppTypography.eyebrow.copyWith(
                            color: palette.accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          meaning,
                          style: AppTypography.subHeading.copyWith(
                            fontSize: 20,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Bottom buttons
                  Row(
                    children: [
                      Expanded(
                        child: _OutlinedActionButton(
                          label: 'Save quote',
                          icon: Icons.bookmark_outline_rounded,
                          onTap: () async {
                            if (onSave != null) {
                              await onSave!();
                            }
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Quote saved'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilledActionButton(
                          label: 'Continue',
                          icon: Icons.arrow_forward_rounded,
                          background: palette.accent,
                          foreground: palette.bg,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.button.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledActionButton extends StatelessWidget {
  const _FilledActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.button.copyWith(
                color: foreground,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: foreground, size: 18),
          ],
        ),
      ),
    );
  }
}
