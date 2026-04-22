import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

/// Splash — wordmark over a spotlight + two vertical accent rails.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surface,
      body: _SplashBody(),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Soft spotlight glow centered slightly above middle
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: const Alignment(0, -0.2),
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.18),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Left rail — tall stack of small bars, top portion lit
        const Positioned(
          top: 140,
          bottom: 140,
          left: 40,
          child: _SplashRail(total: 24, lit: 14),
        ),
        // Right rail — slightly different proportions
        const Positioned(
          top: 220,
          bottom: 80,
          right: 40,
          child: _SplashRail(total: 20, lit: 6),
        ),
        // Wordmark + tagline center
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 54,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                    letterSpacing: -2,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    const TextSpan(text: 'Speed'),
                    TextSpan(
                      text: 'read',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 54,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        letterSpacing: -2,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'THE SPINE OF GREAT BOOKS',
                style: AppTypography.eyebrow.copyWith(
                  fontSize: 12,
                  letterSpacing: 4,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SplashRail extends StatelessWidget {
  const _SplashRail({required this.total, required this.lit});

  final int total;
  final int lit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 3,
      child: Column(
        children: List.generate(total, (i) {
          final isLit = i < lit;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 1.5),
              decoration: BoxDecoration(
                color: isLit
                    ? AppColors.primary
                    : const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(3),
                boxShadow: isLit
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}
