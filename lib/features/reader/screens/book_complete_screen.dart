import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ai_books/app/main_shell.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/book_cover.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/domain/services/onboarding_service.dart';
import 'package:ai_books/domain/services/progress_service.dart';
import 'package:ai_books/domain/services/streak_service.dart';
import 'package:ai_books/features/book_detail/screens/book_detail_screen.dart';
import 'package:ai_books/features/reader/screens/share_sheet.dart';

class BookCompleteScreen extends StatefulWidget {
  const BookCompleteScreen({
    super.key,
    required this.bookTitle,
    required this.author,
    required this.bookId,
    required this.categoryId,
    required this.totalCheckpoints,
    required this.totalMinutes,
    required this.takeawayQuote,
    this.nextBookId,
  });

  final String bookTitle;
  final String author;
  final String bookId;
  final String categoryId;
  final int totalCheckpoints;
  final int totalMinutes;
  final String takeawayQuote;
  final String? nextBookId;

  @override
  State<BookCompleteScreen> createState() => _BookCompleteScreenState();
}

class _BookCompleteScreenState extends State<BookCompleteScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rayController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;
  late final AnimationController _riseController;
  late final AnimationController _driftController;

  int _streakDays = 0;
  int _booksFinished = 0;
  BookEntry? _nextBook;
  String _displayName = '';

  static const Color _bgBase = Color(0xFF08080A);

  @override
  void initState() {
    super.initState();
    _rayController =
        AnimationController(vsync: this, duration: const Duration(seconds: 40))
          ..repeat();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _riseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _loadAsyncData();
  }

  Future<void> _loadAsyncData() async {
    final streak = await StreakService.getCurrentStreak();
    final finished = await ProgressService.getFinishedBookCount();
    final profile = await OnboardingService.getUserProfile();
    BookEntry? next;
    if (widget.nextBookId != null) {
      next = await ContentService.getBook(widget.nextBookId!);
    }
    if (!mounted) return;
    setState(() {
      _streakDays = streak;
      _booksFinished = finished;
      _nextBook = next;
      _displayName = ((profile?['display_name'] as String?) ?? '').trim();
    });
  }

  @override
  void dispose() {
    _rayController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _driftController.dispose();
    _riseController.dispose();
    super.dispose();
  }

  void _onBackHome() {
    MainShell.goToTab(context, tab: MainShellTabs.home);
  }

  Future<void> _onReadNext() async {
    final next = _nextBook;
    if (next == null) {
      _onBackHome();
      return;
    }
    // Pop all reader/complete routes, then push the next book detail.
    final nav = Navigator.of(context);
    nav.popUntil((route) => route.isFirst);
    nav.push(MaterialPageRoute(
      builder: (_) => BookDetailScreen(bookId: next.id),
    ));
  }

  void _onOpenShare() {
    ShareSheet.show(
      context,
      bookTitle: widget.bookTitle,
      author: widget.author,
      bookId: widget.bookId,
      categoryId: widget.categoryId,
      totalCheckpoints: widget.totalCheckpoints,
      totalMinutes: widget.totalMinutes,
      streakDays: _streakDays,
      displayName: _displayName,
    );
  }

  void _onSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to your shelf')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette =
        BookVisuals.forBook(widget.bookId, categoryId: widget.categoryId);
    final bookAccent = palette.accent;

    return Scaffold(
      backgroundColor: _bgBase,
      body: Stack(
        children: [
          // Atmospheric dual radial gradient background
          const Positioned.fill(child: ColoredBox(color: _bgBase)),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _AmbientBackgroundPainter(
                  topAccent: bookAccent,
                  bottomAccent: AppColors.primary,
                ),
              ),
            ),
          ),
          // Drifting particles
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _driftController,
                builder: (_, _) {
                  return CustomPaint(
                    painter: _ParticlesPainter(
                      accent: bookAccent,
                      t: _driftController.value,
                    ),
                  );
                },
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: _RiseIn(
                          controller: _riseController,
                          child: Column(
                            children: [
                              _BookCompleteBadge(accent: bookAccent),
                              const SizedBox(height: 14),
                              _HeroMedal(
                                palette: palette,
                                bookTitle: widget.bookTitle,
                                author: widget.author,
                                categoryId: widget.categoryId,
                                bookId: widget.bookId,
                                bgBase: _bgBase,
                                rayAnimation: _rayController,
                                pulseAnimation: _pulseController,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'You finished',
                                style: AppTypography.body.copyWith(
                                  fontSize: 14,
                                  color: AppColors.textSecondary
                                      .withValues(alpha: 0.5),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.bookTitle,
                                style: AppTypography.tileHeading.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400,
                                  height: 1.05,
                                  letterSpacing: -0.9,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.author} · ${widget.totalCheckpoints} checkpoints · ${widget.totalMinutes} min',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              _StatsTrio(
                                insight: '+120',
                                insightColor: bookAccent,
                                streak: '$_streakDays',
                                booksRead: '$_booksFinished',
                              ),
                              const SizedBox(height: 12),
                              _TakeawayStrip(
                                accent: bookAccent,
                                quote: widget.takeawayQuote,
                              ),
                              const SizedBox(height: 12),
                              _FlexWorthyCard(
                                onTap: _onOpenShare,
                                shimmer: _shimmerController,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Giant next-book CTA + demoted actions pinned at bottom
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
                      child: Column(
                        children: [
                          _NextBookCta(
                            next: _nextBook,
                            onTap: _onReadNext,
                          ),
                          const SizedBox(height: 8),
                          _DemotedActions(
                            onBackHome: _onBackHome,
                            onSave: _onSave,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Rise-in wrapper
// ============================================================================

class _RiseIn extends StatelessWidget {
  const _RiseIn({required this.controller, required this.child});

  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final t = Curves.easeOutCubic.transform(controller.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ============================================================================
// Ambient background + particles
// ============================================================================

class _AmbientBackgroundPainter extends CustomPainter {
  _AmbientBackgroundPainter({
    required this.topAccent,
    required this.bottomAccent,
  });

  final Color topAccent;
  final Color bottomAccent;

  @override
  void paint(Canvas canvas, Size size) {
    // Top ellipse glow
    final topRect = Rect.fromCenter(
      center: Offset(size.width / 2, 0),
      width: size.width * 1.6,
      height: size.height * 0.9,
    );
    final topPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          topAccent.withValues(alpha: 0.33),
          topAccent.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.45],
      ).createShader(topRect);
    canvas.drawRect(topRect, topPaint);

    // Bottom ellipse glow
    final botRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height),
      width: size.width * 1.4,
      height: size.height * 1.1,
    );
    final botPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          bottomAccent.withValues(alpha: 0.13),
          bottomAccent.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.55],
      ).createShader(botRect);
    canvas.drawRect(botRect, botPaint);
  }

  @override
  bool shouldRepaint(_AmbientBackgroundPainter old) =>
      old.topAccent != topAccent || old.bottomAccent != bottomAccent;
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({required this.accent, required this.t});

  final Color accent;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = accent.withValues(alpha: 0.55);
    for (var i = 0; i < 14; i++) {
      final radius = 2.0 + (i % 3);
      final baseLeft = (i * 67) % 100;
      final baseTop = 10 + ((i * 37) % 70);
      final offset = math.sin((t * 2 * math.pi) + i * 0.5) * 20;
      final cx = size.width * (baseLeft / 100.0);
      final cy = size.height * (baseTop / 100.0) + offset;
      // Glow + dot
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(cx, cy), radius * 1.4, paint);
      paint.maskFilter = null;
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) =>
      old.t != t || old.accent != accent;
}

// ============================================================================
// Book complete eyebrow pill
// ============================================================================

class _BookCompleteBadge extends StatelessWidget {
  const _BookCompleteBadge({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.27)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.8),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'BOOK COMPLETE',
            style: AppTypography.eyebrow.copyWith(
              color: accent,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Hero medal (188×188) — rays + halo + ring + cover + check seal
// ============================================================================

class _HeroMedal extends StatelessWidget {
  const _HeroMedal({
    required this.palette,
    required this.bookTitle,
    required this.author,
    required this.categoryId,
    required this.bookId,
    required this.bgBase,
    required this.rayAnimation,
    required this.pulseAnimation,
  });

  final BookPalette palette;
  final String bookTitle;
  final String author;
  final String categoryId;
  final String bookId;
  final Color bgBase;
  final AnimationController rayAnimation;
  final AnimationController pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final accent = palette.accent;
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Rotating rays (fill the whole 160x160 canvas)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: rayAnimation,
              builder: (_, child) {
                return Transform.rotate(
                  angle: rayAnimation.value * 2 * math.pi,
                  child: child,
                );
              },
              child: CustomPaint(
                painter: _RaysPainter(color: accent),
              ),
            ),
          ),
          // Pulsing halo
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (_, _) {
              final raw = Curves.easeInOut.transform(pulseAnimation.value);
              final scale = 1.0 + raw * 0.06;
              final opacity = 0.55 + raw * 0.25;
              return Container(
                width: 136 * scale,
                height: 136 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.4 * opacity),
                      accent.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.65],
                  ),
                ),
              );
            },
          ),
          // Outer ring
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 28,
                ),
              ],
            ),
          ),
          // Inner ring
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withValues(alpha: 0.27),
                width: 1,
              ),
            ),
          ),
          // Book cover (slightly rotated)
          Transform.rotate(
            angle: -4 * math.pi / 180,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    offset: const Offset(0, 14),
                    blurRadius: 32,
                  ),
                  BoxShadow(
                    color: accent.withValues(alpha: 0.33),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: BookCover(
                title: bookTitle,
                author: author,
                category: categoryId.replaceAll('_', ' '),
                palette: palette,
                width: 62,
                height: 94,
              ),
            ),
          ),
          // Checkmark seal — tucked against the book's bottom-right,
          // sitting on the small ring edge (matches design bottom:2 right:18).
          Positioned(
            bottom: 2,
            right: 14,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent, accent.withValues(alpha: 0.67)],
                ),
                border: Border.all(color: bgBase, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.53),
                    offset: const Offset(0, 4),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 16,
                color: Color(0xFF0A0A0A),
              ),
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
    // 16 rays, inner radius 0.36 outer 0.48 of size (matches normalized 100 viewBox in design)
    final cx = size.width / 2;
    final cy = size.height / 2;
    final inner = size.width * 0.36;
    final outer = size.width * 0.48;

    for (var i = 0; i < 16; i++) {
      final angle = i * 22.5 * math.pi / 180;
      final isMajor = i.isEven;
      final paint = Paint()
        ..color = color.withValues(alpha: isMajor ? 0.7 : 0.35)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = isMajor ? size.width * 0.016 : size.width * 0.008;

      final start = Offset(cx + math.cos(angle) * inner, cy + math.sin(angle) * inner);
      final end = Offset(cx + math.cos(angle) * outer, cy + math.sin(angle) * outer);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(_RaysPainter old) => old.color != color;
}

// ============================================================================
// Stats trio
// ============================================================================

class _StatsTrio extends StatelessWidget {
  const _StatsTrio({
    required this.insight,
    required this.insightColor,
    required this.streak,
    required this.booksRead,
  });

  final String insight;
  final Color insightColor;
  final String streak;
  final String booksRead;

  static const _flame = Color(0xFFFF7A36);
  static const _mint = Color(0xFF5EE2D0);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RewardStat(
            value: insight,
            label: 'INSIGHT',
            tint: insightColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RewardStat(
            value: streak,
            label: 'DAY STREAK',
            tint: _flame,
            icon: Icons.local_fire_department_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RewardStat(
            value: booksRead,
            label: 'BOOKS READ',
            tint: _mint,
          ),
        ),
      ],
    );
  }
}

class _RewardStat extends StatelessWidget {
  const _RewardStat({
    required this.value,
    required this.label,
    required this.tint,
    this.icon,
  });

  final String value;
  final String label;
  final Color tint;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          border: Border.all(color: tint.withValues(alpha: 0.2)),
        ),
        child: Stack(
          children: [
            // Corner glow
            Positioned(
              top: -12,
              right: -12,
              child: IgnorePointer(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tint.withValues(alpha: 0.13),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 14, color: tint),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      value,
                      style: AppTypography.tileHeading.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTypography.eyebrow.copyWith(
                    fontSize: 10.5,
                    letterSpacing: 1.5,
                    color: AppColors.textSecondary
                        .withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// "What you gained" compressed quote strip
// ============================================================================

class _TakeawayStrip extends StatelessWidget {
  const _TakeawayStrip({required this.accent, required this.quote});
  final Color accent;
  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Icon(Icons.format_quote_rounded, size: 18, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: AppTypography.titleMedium.copyWith(
                fontSize: 13.5,
                fontStyle: FontStyle.italic,
                height: 1.35,
                color: AppColors.textPrimary.withValues(alpha: 0.85),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FLEX-WORTHY SHARE CARD — signature engagement element
// ============================================================================

class _FlexWorthyCard extends StatelessWidget {
  const _FlexWorthyCard({required this.onTap, required this.shimmer});

  final VoidCallback onTap;
  final AnimationController shimmer;

  static const _pink = Color(0xFFDD2A7B);
  static const _purple = Color(0xFF8134AF);
  static const _blue = Color(0xFF4EA8FF);
  static const _flame = Color(0xFFFF7A36);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Base gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _pink.withValues(alpha: 0.18),
                      _purple.withValues(alpha: 0.18),
                      _blue.withValues(alpha: 0.18),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            // Top-left pink halo
            Positioned(
              top: -30,
              left: -20,
              child: IgnorePointer(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _pink.withValues(alpha: 0.45),
                        _pink.withValues(alpha: 0),
                      ],
                      stops: const [0.0, 0.65],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom-right blue halo
            Positioned(
              bottom: -30,
              right: -20,
              child: IgnorePointer(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _blue.withValues(alpha: 0.4),
                        _blue.withValues(alpha: 0),
                      ],
                      stops: const [0.0, 0.65],
                    ),
                  ),
                ),
              ),
            ),
            // Shimmer sweep
            AnimatedBuilder(
              animation: shimmer,
              builder: (_, _) {
                return Positioned.fill(
                  child: IgnorePointer(
                    child: FractionallySizedBox(
                      alignment: Alignment(-1.0 + shimmer.value * 2.4, 0),
                      widthFactor: 0.4,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.skewX(-0.31),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.12),
                                Colors.white.withValues(alpha: 0.22),
                                Colors.white.withValues(alpha: 0.12),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Border + shadow wrap (inner border)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const _StackedSocialGlyphs(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _flame.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _flame.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                size: 11,
                                color: _flame,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'FLEX-WORTHY',
                                style: AppTypography.eyebrow.copyWith(
                                  fontSize: 9.5,
                                  letterSpacing: 1.8,
                                  fontWeight: FontWeight.w700,
                                  color: _flame,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Show the world you finished it.',
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.15,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Auto-generated poster · 1 tap to share',
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.55),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // White share chip
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.85),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.25),
                          offset: const Offset(0, 6),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.ios_share_rounded,
                      size: 17,
                      color: Color(0xFF08080A),
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

class _StackedSocialGlyphs extends StatelessWidget {
  const _StackedSocialGlyphs();

  static const _bgBase = Color(0xFF08080A);

  @override
  Widget build(BuildContext context) {
    final glyphs = [
      _SocialGlyph(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
        ),
        icon: Icons.camera_alt_rounded,
      ),
      _SocialGlyph(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF25D366), Color(0xFF128C7E)],
        ),
        icon: Icons.chat_rounded,
      ),
      _SocialGlyph(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF000000), Color(0xFF1A1A1A)],
        ),
        icon: Icons.close_rounded, // X approximation
      ),
      _SocialGlyph(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF3A3A3A)],
        ),
        icon: Icons.alternate_email_rounded,
      ),
    ];
    return SizedBox(
      width: 84,
      height: 42,
      child: Stack(
        children: [
          for (var i = 0; i < glyphs.length; i++)
            Positioned(
              left: i * 16.0,
              top: 0,
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: glyphs[i].gradient,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: _bgBase, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(glyphs[i].icon, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _SocialGlyph {
  _SocialGlyph({required this.gradient, required this.icon});
  final Gradient gradient;
  final IconData icon;
}

// ============================================================================
// GIANT NEXT-BOOK CTA — hero of the lower half
// ============================================================================

class _NextBookCta extends StatelessWidget {
  const _NextBookCta({required this.next, required this.onTap});

  final BookEntry? next;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final book = next;
    if (book == null) {
      // Fallback: neutral accent card that goes home
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withValues(alpha: 0.03),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Explore more books',
                  textAlign: TextAlign.center,
                ),
              ),
              Icon(Icons.arrow_forward_rounded,
                  size: 18, color: AppColors.primary),
            ],
          ),
        ),
      );
    }

    final palette = BookVisuals.forBook(book.id, categoryId: book.categoryId);
    final accent = palette.accent;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Base gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-0.5, -1),
                    end: const Alignment(0.5, 1),
                    colors: [
                      accent.withValues(alpha: 0.16),
                      Colors.white.withValues(alpha: 0.01),
                    ],
                    stops: const [0.0, 0.55],
                  ),
                ),
              ),
            ),
            // Top-right radiant
            Positioned(
              top: -40,
              right: -30,
              child: IgnorePointer(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.33),
                        accent.withValues(alpha: 0),
                      ],
                      stops: const [0.0, 0.65],
                    ),
                  ),
                ),
              ),
            ),
            // Border overlay
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.27),
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Row(
                    children: [
                      // Tilted book cover with "NEXT" corner tag
                      SizedBox(
                        width: 74,
                        height: 96,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 6,
                              top: 2,
                              child: Transform.rotate(
                                angle: 3 * math.pi / 180,
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.5),
                                        offset: const Offset(0, 10),
                                        blurRadius: 22,
                                      ),
                                      BoxShadow(
                                        color: accent.withValues(alpha: 0.4),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                  child: BookCover(
                                    title: book.title,
                                    author: book.author,
                                    category: book.categoryId
                                        .replaceAll('_', ' '),
                                    palette: palette,
                                    width: 58,
                                    height: 86,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -2,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          accent.withValues(alpha: 0.53),
                                      offset: const Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'NEXT',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: Color(0xFF08080A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PICKED FOR YOUR STREAK',
                              style: AppTypography.eyebrow.copyWith(
                                fontSize: 10,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.title,
                              style: AppTypography.titleLarge.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                height: 1.1,
                                letterSpacing: -0.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              book.author,
                              style: AppTypography.caption.copyWith(
                                fontSize: 11.5,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '~${book.estimatedMinutes} min',
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Big accent footer CTA bar inside the card
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [accent, accent.withValues(alpha: 0.87)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.33),
                          offset: const Offset(0, 8),
                          blurRadius: 22,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Start reading',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: Color(0xFF08080A),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Checkpoint 1',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF08080A)
                                    .withValues(alpha: 0.73),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Color(0xFF08080A),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Demoted secondary actions — "Back home · Save"
// ============================================================================

class _DemotedActions extends StatelessWidget {
  const _DemotedActions({required this.onBackHome, required this.onSave});

  final VoidCallback onBackHome;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.caption.copyWith(
      fontSize: 12.5,
      letterSpacing: 0.2,
      color: AppColors.textSecondary.withValues(alpha: 0.5),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: onBackHome,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('Back home', style: style),
        ),
        Text(
          '·',
          style: AppTypography.caption.copyWith(
            fontSize: 14,
            color: AppColors.textDim,
          ),
        ),
        TextButton(
          onPressed: onSave,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_outline_rounded,
                size: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 5),
              Text('Save', style: style),
            ],
          ),
        ),
      ],
    );
  }
}
