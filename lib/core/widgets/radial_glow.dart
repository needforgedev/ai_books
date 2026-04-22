import 'package:flutter/material.dart';

/// A positioned radial glow — used for atmospheric accent background layers.
class RadialGlow extends StatelessWidget {
  const RadialGlow({
    super.key,
    required this.color,
    this.size = 300,
    this.opacity = 0.3,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    );
  }
}
