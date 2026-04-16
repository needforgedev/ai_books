import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';

/// A simple linear progress bar with rectangular ends.
/// Luxury dark style: surfaceMuted background, primary fill, thin 3px height.
class AiProgressBar extends StatelessWidget {
  const AiProgressBar({
    super.key,
    required this.progress,
    this.height = 3,
    this.activeColor = AppColors.primary,
    this.backgroundColor = AppColors.surfaceMuted,
  });

  /// Progress value between 0.0 and 1.0.
  final double progress;

  /// Height of the progress bar.
  final double height;

  /// Color of the filled portion.
  final Color activeColor;

  /// Color of the background track.
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.zero,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: constraints.maxWidth * clampedProgress,
              height: height,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        );
      },
    );
  }
}
