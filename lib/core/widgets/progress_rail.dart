import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';

/// Vertical or horizontal progress rail — Speedread's signature "spine" motif.
/// Shows N segments with `done` filled at accent color.
class ProgressRail extends StatelessWidget {
  const ProgressRail({
    super.key,
    required this.total,
    required this.done,
    this.accent = AppColors.primary,
    this.height = 120,
    this.thickness = 4,
    this.vertical = true,
  });

  final int total;
  final int done;
  final Color accent;
  final double height;
  final double thickness;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final segments = List.generate(total, (i) {
      final isDone = i < done;
      return Expanded(
        child: Container(
          margin: EdgeInsets.all(thickness / 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(thickness),
            color: isDone ? accent : const Color(0x1AFFFFFF),
            boxShadow: isDone
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
      );
    });

    if (vertical) {
      return SizedBox(
        width: thickness,
        height: height,
        child: Column(children: segments),
      );
    }
    return SizedBox(
      height: thickness,
      child: Row(children: segments),
    );
  }
}
