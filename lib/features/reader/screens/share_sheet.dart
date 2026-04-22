import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/book_cover.dart';

/// Bottom-sheet share dialog — "Share your win" with a live poster preview.
/// Matches Speedread design exactly.
class ShareSheet extends StatefulWidget {
  const ShareSheet({
    super.key,
    required this.bookTitle,
    required this.author,
    required this.bookId,
    required this.categoryId,
    required this.totalCheckpoints,
    required this.totalMinutes,
    required this.streakDays,
  });

  final String bookTitle;
  final String author;
  final String bookId;
  final String categoryId;
  final int totalCheckpoints;
  final int totalMinutes;
  final int streakDays;

  /// Show as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String bookTitle,
    required String author,
    required String bookId,
    required String categoryId,
    required int totalCheckpoints,
    required int totalMinutes,
    required int streakDays,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => ShareSheet(
        bookTitle: bookTitle,
        author: author,
        bookId: bookId,
        categoryId: categoryId,
        totalCheckpoints: totalCheckpoints,
        totalMinutes: totalMinutes,
        streakDays: streakDays,
      ),
    );
  }

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  int _platformIndex = 0;

  static const List<_Platform> _platforms = [
    _Platform(
      id: 'story',
      label: 'Story',
      sub: 'IG · FB',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
      ),
      icon: Icons.camera_alt_rounded,
    ),
    _Platform(
      id: 'whatsapp',
      label: 'WhatsApp',
      sub: 'Status',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF25D366), Color(0xFF128C7E)],
      ),
      icon: Icons.chat_rounded,
    ),
    _Platform(
      id: 'x',
      label: 'X',
      sub: 'Post',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF000000), Color(0xFF1A1A1A)],
      ),
      icon: Icons.close_rounded,
    ),
    _Platform(
      id: 'threads',
      label: 'Threads',
      sub: '',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1A1A), Color(0xFF3A3A3A)],
      ),
      icon: Icons.alternate_email_rounded,
    ),
    _Platform(
      id: 'copy',
      label: 'Copy link',
      sub: '',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2A2A2E), Color(0xFF1A1A1E)],
      ),
      icon: Icons.content_copy_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final palette =
        BookVisuals.forBook(widget.bookId, categoryId: widget.categoryId);
    final bookAccent = palette.accent;
    final platform = _platforms[_platformIndex];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF101014),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              offset: const Offset(0, -20),
              blurRadius: 60,
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          18,
          14,
          18,
          28 + MediaQuery.of(context).padding.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grabber
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Title row
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      'Share your win',
                      style: AppTypography.titleLarge.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Close',
                      style: AppTypography.caption.copyWith(
                        fontSize: 12.5,
                        color: AppColors.textSecondary
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'A poster, ready for your story.',
                style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              // Live poster preview
              AspectRatio(
                aspectRatio: 9 / 12,
                child: _PosterPreview(
                  bookTitle: widget.bookTitle,
                  author: widget.author,
                  categoryId: widget.categoryId,
                  palette: palette,
                  totalCheckpoints: widget.totalCheckpoints,
                  totalMinutes: widget.totalMinutes,
                  streakDays: widget.streakDays,
                  bookAccent: bookAccent,
                ),
              ),
              const SizedBox(height: 14),
              // Caption edit row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Just finished another one 📚',
                        style: AppTypography.body.copyWith(
                          fontSize: 12.5,
                          color: AppColors.textPrimary
                              .withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Edit',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: bookAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Platform tiles
              Row(
                children: List.generate(_platforms.length, (i) {
                  final p = _platforms[i];
                  final selected = i == _platformIndex;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i == _platforms.length - 1 ? 0 : 8,
                      ),
                      child: _PlatformTile(
                        platform: p,
                        selected: selected,
                        accent: bookAccent,
                        onTap: () => setState(() => _platformIndex = i),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              // Share CTA
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Share to ${platform.label} — soon'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bookAccent,
                    foregroundColor: const Color(0xFF08080A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    shadowColor: bookAccent.withValues(alpha: 0.55),
                  ).copyWith(
                    overlayColor: WidgetStateProperty.all(
                      Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.ios_share_rounded,
                          size: 15, color: Color(0xFF08080A)),
                      const SizedBox(width: 8),
                      Text(
                        'Share to ${platform.label}',
                        style: AppTypography.buttonLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: const Color(0xFF08080A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Saved to Photos · No metadata shared',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  fontSize: 10.5,
                  color: AppColors.textSecondary.withValues(alpha: 0.35),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Poster preview — a 9:12 card that represents the shareable image
// ============================================================================

class _PosterPreview extends StatelessWidget {
  const _PosterPreview({
    required this.bookTitle,
    required this.author,
    required this.categoryId,
    required this.palette,
    required this.totalCheckpoints,
    required this.totalMinutes,
    required this.streakDays,
    required this.bookAccent,
  });

  final String bookTitle;
  final String author;
  final String categoryId;
  final BookPalette palette;
  final int totalCheckpoints;
  final int totalMinutes;
  final int streakDays;
  final Color bookAccent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // Base vertical gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-0.3, -1.0),
                  end: const Alignment(0.3, 1.0),
                  colors: [
                    bookAccent.withValues(alpha: 0.18),
                    const Color(0xFF0A0A0C),
                    const Color(0xFF050506),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          // Accent glow top-center
          Positioned(
            top: -50,
            left: -40,
            right: -40,
            height: 260,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PosterGlowPainter(accent: bookAccent),
              ),
            ),
          ),
          // Subtle diagonal grain
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DiagonalGrainPainter(),
              ),
            ),
          ),
          // Border overlay
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: bookAccent.withValues(alpha: 0.27),
                  ),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              children: [
                // Top brand bar
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            bookAccent,
                            bookAccent.withValues(alpha: 0.53),
                          ],
                        ),
                      ),
                      child: const Text(
                        'S',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF08080A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SPEEDREAD',
                      style: AppTypography.eyebrow.copyWith(
                        fontSize: 11,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'BOOK COMPLETE',
                      style: AppTypography.eyebrow.copyWith(
                        fontSize: 9.5,
                        letterSpacing: 2,
                        color: AppColors.textSecondary
                            .withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                // Cover centered
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Glow halo behind cover
                          IgnorePointer(
                            child: Container(
                              width: 170,
                              height: 225,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    bookAccent.withValues(alpha: 0.33),
                                    bookAccent.withValues(alpha: 0),
                                  ],
                                  stops: const [0.0, 0.65],
                                ),
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: -3 * math.pi / 180,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.7),
                                    offset: const Offset(0, 20),
                                    blurRadius: 40,
                                  ),
                                  BoxShadow(
                                    color: bookAccent
                                        .withValues(alpha: 0.4),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                              child: BookCover(
                                title: bookTitle,
                                author: author,
                                category: categoryId.replaceAll('_', ' '),
                                palette: palette,
                                width: 110,
                                height: 165,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Title + author
                Text(
                  bookTitle,
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                    letterSpacing: -0.5,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary
                        .withValues(alpha: 0.55),
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                // Stat strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: bookAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _PosterStat(
                            value: '${totalMinutes}m',
                            label: 'read',
                            accent: bookAccent,
                          ),
                        ),
                        Container(
                          width: 1,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        Expanded(
                          child: _PosterStat(
                            value: '$totalCheckpoints',
                            label: 'checkpoints',
                            accent: bookAccent,
                          ),
                        ),
                        Container(
                          width: 1,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        Expanded(
                          child: _PosterStat(
                            value: '$streakDays🔥',
                            label: 'streak',
                            accent: bookAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '@nabeel · speedread.app',
                  style: AppTypography.eyebrow.copyWith(
                    fontSize: 9.5,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary
                        .withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterStat extends StatelessWidget {
  const _PosterStat({
    required this.value,
    required this.label,
    required this.accent,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.3,
            color: accent,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label.toUpperCase(),
          style: AppTypography.eyebrow.copyWith(
            fontSize: 8.5,
            letterSpacing: 1.2,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _PosterGlowPainter extends CustomPainter {
  _PosterGlowPainter({required this.accent});
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.4),
        colors: [
          accent.withValues(alpha: 0.53),
          accent.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.6],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_PosterGlowPainter old) => old.accent != accent;
}

class _DiagonalGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.012)
      ..strokeWidth = 1;
    // Diagonal stripes at 45° every 6px
    final step = 6.0;
    final diagonal = size.width + size.height;
    for (double i = -diagonal; i < diagonal; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DiagonalGrainPainter old) => false;
}

// ============================================================================
// Platform tile + data
// ============================================================================

class _Platform {
  const _Platform({
    required this.id,
    required this.label,
    required this.sub,
    required this.gradient,
    required this.icon,
  });

  final String id;
  final String label;
  final String sub;
  final Gradient gradient;
  final IconData icon;
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({
    required this.platform,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final _Platform platform;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.025),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.33)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                gradient: platform.gradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(platform.icon, size: 18, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              platform.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary.withValues(alpha: 0.75),
              ),
            ),
            if (platform.sub.isNotEmpty)
              Text(
                platform.sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  fontSize: 8.5,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
