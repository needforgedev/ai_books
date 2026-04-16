import 'package:flutter/material.dart';

/// Luxury dark design system — monochromatic, premium, bold.
/// Based on SKILL.md: surface=#000000, primary=#FAFAFA, text=#ffffff
class AppColors {
  AppColors._();

  // Core surfaces
  static const Color surface = Color(0xFF000000);
  static const Color surfaceElevated = Color(0xFF0A0A0A);
  static const Color surfaceCard = Color(0xFF111111);
  static const Color surfaceCardHover = Color(0xFF1A1A1A);
  static const Color surfaceInput = Color(0xFF141414);
  static const Color surfaceMuted = Color(0xFF1C1C1C);

  // Primary
  static const Color primary = Color(0xFFFAFAFA);
  static const Color primaryMuted = Color(0xFFE0E0E0);
  static const Color primaryDim = Color(0xFFAAAAAA);

  // Accent — subtle gold for luxury feel
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentMuted = Color(0xFFB8962E);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textTertiary = Color(0xFF666666);
  static const Color textOnPrimary = Color(0xFF000000);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);

  // Borders
  static const Color border = Color(0xFF222222);
  static const Color borderSubtle = Color(0xFF1A1A1A);
  static const Color borderFocus = Color(0xFFFAFAFA);

  // Button states
  static const Color buttonPrimary = Color(0xFFFAFAFA);
  static const Color buttonPrimaryPressed = Color(0xFFE0E0E0);
  static const Color buttonSecondary = Color(0xFF1A1A1A);
  static const Color buttonSecondaryPressed = Color(0xFF222222);
  static const Color buttonDisabled = Color(0xFF1A1A1A);
  static const Color textDisabled = Color(0xFF444444);

  // Category theme colors
  static const Color scienceColor = Color(0xFF4A90D9);
  static const Color businessColor = Color(0xFF16A34A);
  static const Color personalDevColor = Color(0xFFD97706);

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 4),
      blurRadius: 24,
    ),
  ];
}
