import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/core/widgets/progress_rail.dart';

/// Speedread book cover — typographic, no images needed.
/// 8 distinct cover styles driven by [BookPalette.coverStyle].
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.title,
    required this.author,
    required this.category,
    required this.palette,
    this.width = 140,
    this.height = 210,
    this.withRail = false,
    this.doneCount = 0,
    this.totalCheckpoints = 6,
    this.onTap,
  });

  final String title;
  final String author;
  final String category;
  final BookPalette palette;
  final double width;
  final double height;
  final bool withRail;
  final int doneCount;
  final int totalCheckpoints;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final titleSize = math.max(12.0, (width / 9).floorToDouble());
    final subSize = math.max(7.0, (width / 22).floorToDouble());
    final padding = width * 0.09;
    final radius = math.max(4.0, width * 0.04);

    final cover = Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            offset: const Offset(0, 12),
            blurRadius: 28,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decoration layer (per-style)
          Positioned.fill(child: _CoverDecoration(palette: palette, width: width, height: height)),
          // Text layer
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: subSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    color: palette.ink.withValues(alpha: 0.65),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.fraunces(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w500,
                      height: 1.02,
                      letterSpacing: -0.3,
                      color: palette.ink,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  author,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: subSize + 1,
                    letterSpacing: 0.2,
                    color: palette.ink.withValues(alpha: 0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final content = withRail
        ? SizedBox(
            height: height,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProgressRail(
                  total: totalCheckpoints,
                  done: doneCount,
                  accent: palette.accent,
                  height: height,
                  thickness: 4,
                ),
                const SizedBox(width: 6),
                cover,
              ],
            ),
          )
        : cover;

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

class _CoverDecoration extends StatelessWidget {
  const _CoverDecoration({required this.palette, required this.width, required this.height});

  final BookPalette palette;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _CoverPainter(palette: palette),
    );
  }
}

class _CoverPainter extends CustomPainter {
  _CoverPainter({required this.palette});

  final BookPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final accent = palette.accent;

    switch (palette.coverStyle) {
      case 'stacked-bars':
        _paintStackedBars(canvas, w, h, accent);
        break;
      case 'split-block':
        _paintSplitBlock(canvas, w, h, accent);
        break;
      case 'horizon':
        _paintHorizon(canvas, w, h, accent);
        break;
      case 'orbit':
        _paintOrbit(canvas, w, h, accent);
        break;
      case 'brutalist':
        _paintBrutalist(canvas, w, h, accent);
        break;
      case 'arch':
        _paintArch(canvas, w, h, accent);
        break;
      case 'grid':
        _paintGrid(canvas, w, h, accent);
        break;
      case 'column':
        _paintColumn(canvas, w, h, accent);
        break;
    }
  }

  void _paintStackedBars(Canvas canvas, double w, double h, Color accent) {
    for (var i = 0; i < 8; i++) {
      final paint = Paint()
        ..color = accent.withValues(alpha: i < 4 ? 0.38 : 0.12)
        ..strokeWidth = 1;
      canvas.save();
      canvas.translate(-10 + i * 8, h * 0.35 - i * 6);
      canvas.rotate(-0.05);
      canvas.drawLine(Offset(0, 0), Offset(w * 1.4, 0), paint);
      canvas.restore();
    }
  }

  void _paintSplitBlock(Canvas canvas, double w, double h, Color accent) {
    final paint = Paint()..color = accent;
    canvas.drawRect(Rect.fromLTWH(w * 0.45, 0, w * 0.55, h), paint);
  }

  void _paintHorizon(Canvas canvas, double w, double h, Color accent) {
    final linePaint = Paint()
      ..color = accent.withValues(alpha: 0.8)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, h * 0.62), Offset(w, h * 0.62), linePaint);

    // Sun/circle
    final cx = w / 2;
    final cy = h * 0.62;
    final radius = w * 0.2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    final gradient = RadialGradient(
      colors: [accent, accent.withValues(alpha: 0)],
      stops: const [0.0, 0.7],
    );
    final gradPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(Offset(cx, cy), radius, gradPaint);
  }

  void _paintOrbit(Canvas canvas, double w, double h, Color accent) {
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = accent.withValues(alpha: 0.56)
      ..strokeWidth = 1.5;
    canvas.drawCircle(
      Offset(w * 0.85, h * 0.35),
      w * 0.45,
      outerPaint,
    );
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = accent.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawCircle(
      Offset(w * 0.75, h * 0.4),
      w * 0.35,
      innerPaint,
    );
    // Dot
    final dotPaint = Paint()..color = accent;
    canvas.drawCircle(Offset(w * 0.6, h * 0.35), w * 0.04, dotPaint);
  }

  void _paintBrutalist(Canvas canvas, double w, double h, Color accent) {
    final hPaint = Paint()
      ..color = accent
      ..strokeWidth = 2;
    canvas.drawLine(Offset(-1, h * 0.45), Offset(w + 1, h * 0.45), hPaint);
    final vPaint = Paint()
      ..color = accent
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(w * 0.15, h * 0.45),
      Offset(w * 0.15, h * 0.85),
      vPaint,
    );
  }

  void _paintArch(Canvas canvas, double w, double h, Color accent) {
    final rect = Rect.fromLTWH(w * 0.15, h * 0.45, w * 0.7, h * 0.55);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [accent, accent.withValues(alpha: 0.25)],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    final path = Path()
      ..moveTo(w * 0.15, h)
      ..lineTo(w * 0.15, h * 0.55)
      ..arcToPoint(
        Offset(w * 0.85, h * 0.55),
        radius: Radius.circular(w * 0.35),
      )
      ..lineTo(w * 0.85, h)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _paintGrid(Canvas canvas, double w, double h, Color accent) {
    final paint = Paint()
      ..color = accent.withValues(alpha: 0.2)
      ..strokeWidth = 1;
    for (var r = 0; r < 6; r++) {
      final y = (r + 1) * (h / 7);
      canvas.drawLine(Offset(0, y), Offset(w, y), paint);
    }
    final blockPaint = Paint()..color = accent;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.2, h * 0.55, w * 0.15, w * 0.15),
      blockPaint,
    );
  }

  void _paintColumn(Canvas canvas, double w, double h, Color accent) {
    for (var i = 0; i < 3; i++) {
      final x = w * 0.18 + i * w * 0.22;
      final rect = Rect.fromLTWH(x, h * 0.42, w * 0.08, h * 0.45);
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [accent, accent.withValues(alpha: 0.15)],
      );
      final paint = Paint()..shader = gradient.createShader(rect);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CoverPainter oldDelegate) {
    return oldDelegate.palette != palette;
  }
}
