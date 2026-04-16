import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Luxury typography — Oswald for display, system sans for body.
/// Bold headings, confident, modern.
class AppTypography {
  AppTypography._();

  static final String _displayFont = GoogleFonts.oswald().fontFamily!;

  // Display Hero — 48px, weight 700, uppercase
  static final TextStyle displayHero = TextStyle(
    fontFamily: _displayFont,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: 2.0,
    color: AppColors.textPrimary,
  );

  // Section Heading — 36px, weight 600, uppercase
  static final TextStyle sectionHeading = TextStyle(
    fontFamily: _displayFont,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.10,
    letterSpacing: 1.5,
    color: AppColors.textPrimary,
  );

  // Tile Heading — 24px, weight 500
  static final TextStyle tileHeading = TextStyle(
    fontFamily: _displayFont,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: 0.8,
    color: AppColors.textPrimary,
  );

  // Card Title — 18px, weight 600
  static final TextStyle cardTitle = TextStyle(
    fontFamily: _displayFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.20,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  // Sub-heading — 18px, weight 400
  static final TextStyle subHeading = TextStyle(
    fontFamily: _displayFont,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.20,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  // Body — 15px, weight 400, system font
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.53,
    letterSpacing: -0.2,
    color: AppColors.textSecondary,
  );

  // Body Emphasis — 15px, weight 600
  static const TextStyle bodyEmphasis = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  // Button Large — 16px, weight 500, Oswald
  static final TextStyle buttonLarge = TextStyle(
    fontFamily: _displayFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 1.0,
    color: AppColors.textOnPrimary,
  );

  // Button — 14px, weight 500, Oswald
  static final TextStyle button = TextStyle(
    fontFamily: _displayFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: AppColors.textOnPrimary,
  );

  // Link — 14px, weight 400
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: -0.1,
    color: AppColors.primary,
  );

  // Caption — 13px, weight 400
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.38,
    letterSpacing: 0,
    color: AppColors.textTertiary,
  );

  // Caption Bold — 13px, weight 600
  static const TextStyle captionBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.38,
    color: AppColors.textSecondary,
  );

  // Micro — 11px, weight 400
  static const TextStyle micro = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.36,
    letterSpacing: 0.2,
    color: AppColors.textTertiary,
  );

  // Label — 11px, weight 600, uppercase, Oswald
  static final TextStyle label = TextStyle(
    fontFamily: _displayFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 2.0,
    color: AppColors.textTertiary,
  );
}
