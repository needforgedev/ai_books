import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Speedread typography — Fraunces serif for display, Space Grotesk for body.
/// Italic emphasis on accent words is a signature move.
class AppTypography {
  AppTypography._();

  static TextStyle _display({
    required double size,
    FontWeight weight = FontWeight.w400,
    double height = 1.1,
    double letterSpacing = -0.4,
    Color? color,
    FontStyle? style,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.textPrimary,
      fontStyle: style ?? FontStyle.normal,
    );
  }

  static TextStyle _body({
    required double size,
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
    double letterSpacing = 0,
    Color? color,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.textPrimary,
    );
  }

  // Display (Fraunces serif)
  static TextStyle get displayHero => _display(size: 48, height: 1.02, letterSpacing: -1.6);
  static TextStyle get displayLarge => _display(size: 42, height: 1.02, letterSpacing: -1.4);
  static TextStyle get sectionHeading => _display(size: 36, height: 1.0, letterSpacing: -1.2);
  static TextStyle get tileHeading => _display(size: 28, height: 1.08, letterSpacing: -0.8);
  static TextStyle get titleLarge => _display(size: 22, height: 1.1, letterSpacing: -0.4);
  static TextStyle get titleMedium => _display(size: 18, height: 1.2, letterSpacing: -0.3);
  static TextStyle get subHeading => _display(size: 20, height: 1.2, letterSpacing: -0.3);
  static TextStyle get bookTitle => _display(size: 30, weight: FontWeight.w400, height: 1.08, letterSpacing: -0.8);

  // Italic variants (for accent words in headlines)
  static TextStyle displayItalic(double size, {Color? color}) => _display(
        size: size,
        style: FontStyle.italic,
        color: color,
        height: 1.02,
        letterSpacing: -1.4,
      );

  // Body (Space Grotesk)
  static TextStyle get body => _body(size: 15, height: 1.5, color: AppColors.textSecondary);
  static TextStyle get bodyEmphasis => _body(size: 15, weight: FontWeight.w600);
  static TextStyle get bodyLarge => _body(size: 17, height: 1.5);
  static TextStyle get bodySmall => _body(size: 13, height: 1.4, color: AppColors.textSecondary);

  // Buttons (Space Grotesk)
  static TextStyle get buttonLarge => _body(
        size: 17,
        weight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 0.2,
        color: AppColors.textOnPrimary,
      );
  static TextStyle get button => _body(
        size: 15,
        weight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 0.2,
      );

  // Caption / Micro (Space Grotesk)
  static TextStyle get caption => _body(size: 12.5, height: 1.4, color: AppColors.textTertiary);
  static TextStyle get captionBold => _body(size: 12.5, weight: FontWeight.w600, height: 1.4);
  static TextStyle get micro => _body(size: 11, height: 1.3, color: AppColors.textTertiary);

  // Eyebrow / label — tracked uppercase (Space Grotesk)
  static TextStyle get eyebrow => _body(
        size: 11,
        weight: FontWeight.w500,
        letterSpacing: 2.5,
        height: 1.0,
        color: AppColors.textTertiary,
      );
  static TextStyle get label => _body(
        size: 10.5,
        weight: FontWeight.w500,
        letterSpacing: 2.0,
        height: 1.0,
        color: AppColors.textMuted,
      );
  static TextStyle get link => _body(
        size: 13,
        weight: FontWeight.w500,
        color: AppColors.primary,
      );

  // Compat alias — old Luxury typography used `cardTitle`
  static TextStyle get cardTitle => titleMedium;
}
