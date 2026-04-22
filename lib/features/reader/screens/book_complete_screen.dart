import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ai_books/app/main_shell.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/book_cover.dart';
import 'package:ai_books/core/widgets/radial_glow.dart';
import 'package:ai_books/domain/services/progress_service.dart';
import 'package:ai_books/domain/services/streak_service.dart';

class BookCompleteScreen extends StatefulWidget {
  const BookCompleteScreen({
    super.key,
    required this.bookTitle,
    required this.gains,
    required this.nextBookTitle,
    required this.bookId,
    required this.categoryId,
    required this.author,
    this.onReadNext,
    this.onExplore,
  });

  final String bookTitle;
  final List<String> gains;
  final String nextBookTitle;
  final String bookId;
  final String categoryId;
  final String author;
  final VoidCallback? onReadNext;
  final VoidCallback? onExplore;

  @override
  State<BookCompleteScreen> createState() => _BookCompleteScreenState();
}

class _BookCompleteScreenState extends State<BookCompleteScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rayController;
  late final AnimationController _pulseController;
  int _streakDays = 0;
  int _booksFinished = 0;

  @override
  void initState() {
    super.initState();
    _rayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadStats();
  }

  Future<void> _loadStats() async {
    final streak = await StreakService.getCurrentStreak();
    final finished = await ProgressService.getFinishedBookCount();
    if (!mounted) return;
    setState(() {
      _streakDays = streak;
      _booksFinished = finished;
    });
  }

  @override
  void dispose() {
    _rayController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette =
        BookVisuals.forBook(widget.bookId, categoryId: widget.categoryId);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Top radial glow accent
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Center(
              child: RadialGlow(
                color: palette.accent,
                size: 480,
                opacity: 0.35,
              ),
            ),
          ),
          // Bottom flame glow
          Positioned(
            bottom: -80,
            left: 0,
            right: 0,
            child: Center(
              child: RadialGlow(
                color: AppColors.flame,
                size: 360,
                opacity: 0.12,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Eyebrow pill
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: palette.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: palette.accent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: palette.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'BOOK COMPLETE',
                            style: AppTypography.eyebrow.copyWith(
                              color: palette.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Hero medal
                  Center(
                    child: _HeroMedal(
                      palette: palette,
                      title: widget.bookTitle,
                      author: widget.author,
                      categoryId: widget.categoryId,
                      bookId: widget.bookId,
                      rayAnimation: _rayController,
                      pulseAnimation: _pulseController,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'You finished',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.bookTitle,
                    style: AppTypography.tileHeading.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  // Stat trio
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '+120',
                          label: 'Insight points',
                          accent: palette.accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          value: '$_streakDays',
                          label: _streakDays == 1 ? 'day streak' : 'days streak',
                          accent: AppColors.flame,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          value: '$_booksFinished',
                          label: _booksFinished == 1
                              ? 'book finished'
                              : 'books finished',
                          accent: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Hero Next card
                  _NextCard(
                    palette: palette,
                    nextTitle: widget.nextBookTitle,
                    onTap: widget.onReadNext,
                  ),
                  const SizedBox(height: 18),
                  // Secondary buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: TextButton(
                            onPressed: () {
                              MainShell.goToTab(
                                context,
                                tab: MainShellTabs.home,
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Back home',
                              style: AppTypography.button.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMedal extends StatelessWidget {
  const _HeroMedal({
    required this.palette,
    required this.title,
    required this.author,
    required this.categoryId,
    required this.bookId,
    required this.rayAnimation,
    required this.pulseAnimation,
  });

  final BookPalette palette;
  final String title;
  final String author;
  final String categoryId;
  final String bookId;
  final AnimationController rayAnimation;
  final AnimationController pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing halo
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              final t = 0.8 + (pulseAnimation.value * 0.2);
              return Container(
                width: 200 * t,
                height: 200 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      palette.accent.withValues(
                          alpha: 0.4 - (pulseAnimation.value * 0.2)),
                      palette.accent.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.75],
                  ),
                ),
              );
            },
          ),
          // Rotating rays
          AnimatedBuilder(
            animation: rayAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: rayAnimation.value * 2 * math.pi,
                child: child,
              );
            },
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _RaysPainter(color: palette.accent),
            ),
          ),
          // Ring border
          Container(
            width: 188,
            height: 188,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: palette.accent.withValues(alpha: 0.55),
                width: 2,
              ),
            ),
          ),
          // Inner book cover (slightly rotated)
          Transform.rotate(
            angle: -4 * math.pi / 180,
            child: BookCover(
              title: title,
              author: author,
              category: categoryId.toUpperCase(),
              palette: palette,
              width: 74,
              height: 110,
            ),
          ),
        ],
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  _RaysPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi / 6);
      final inner = 80.0;
      final outer = 100.0;
      paint.strokeWidth = i.isEven ? 2 : 1;
      final start = Offset(
        center.dx + math.cos(angle) * inner,
        center.dy + math.sin(angle) * inner,
      );
      final end = Offset(
        center.dx + math.cos(angle) * outer,
        center.dy + math.sin(angle) * outer,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.accent,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: accent,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.micro.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({
    required this.palette,
    required this.nextTitle,
    required this.onTap,
  });

  final BookPalette palette;
  final String nextTitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            // Cover thumb
            Container(
              width: 74,
              height: 110,
              decoration: BoxDecoration(
                color: palette.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: palette.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: palette.accent,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: palette.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'NEXT',
                      style: AppTypography.eyebrow.copyWith(
                        color: palette.accent,
                        fontSize: 10,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nextTitle,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Start reading',
                        style: AppTypography.button.copyWith(
                          color: palette.accent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: palette.accent,
                        size: 16,
                      ),
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
