import 'package:flutter/material.dart';

/// Speedread cinematic dark design system.
/// Deep neutral field + per-book accent palettes + vertical progress rails.
class AppColors {
  AppColors._();

  // Core surfaces — deep cinematic dark
  static const Color surface = Color(0xFF0A0A0C);
  static const Color surfaceElevated = Color(0xFF121215);
  static const Color surfaceCard = Color(0xFF141418);
  static const Color surfaceCardHover = Color(0xFF1A1A1F);
  static const Color surfaceInput = Color(0xFF141418);
  static const Color surfaceMuted = Color(0xFF1C1C22);

  // Primary — default crimson accent (can be overridden per book)
  static const Color primary = Color(0xFFFF3B3B);
  static const Color primaryMuted = Color(0xFFCC2E2E);
  static const Color primaryDim = Color(0xFFAAAAAA);

  // Warm accent (flame/streak)
  static const Color flame = Color(0xFFFF7A36);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F0);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70%
  static const Color textTertiary = Color(0x80FFFFFF); // 50%
  static const Color textMuted = Color(0x59FFFFFF); // 35%
  static const Color textDim = Color(0x40FFFFFF); // 25%
  static const Color textOnPrimary = Color(0xFF0A0A0A);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);

  // Borders
  static const Color border = Color(0x1AFFFFFF); // 10%
  static const Color borderSubtle = Color(0x0FFFFFFF); // 6%
  static const Color borderFocus = Color(0xFFFF3B3B);

  // Glass (for floating tab bar)
  static const Color glassBg = Color(0xB8161618);
  static const Color glassBorder = Color(0x12FFFFFF);

  // Temporary compat shims (old Luxury tokens) — remove once screens redesigned
  static const Color accent = Color(0xFFD4AF37);
  static const Color buttonPrimary = primary;
  static const Color buttonDisabled = Color(0xFF1A1A1A);
  static const Color textDisabled = Color(0x40FFFFFF);
  static const Color textSecondaryOnDark = textSecondary;
  static const Color textTertiaryOnDark = textTertiary;
  static const Color scienceColor = catScience;
  static const Color businessColor = catBusiness;
  static const Color personalDevColor = catPersonal;
  static const Color nearBlack = Color(0xFF1D1D1F);
  static const Color lightGray = surfaceMuted;
  static const Color white = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);

  // Category theme colors (from design data)
  static const Color catPersonal = Color(0xFF4EA8FF);
  static const Color catBusiness = Color(0xFFC8F24B);
  static const Color catPhilosophy = Color(0xFFD4B266);
  static const Color catScience = Color(0xFF5EE2D0);
  static const Color catHistory = Color(0xFFD99A5B);
  static const Color catScifi = Color(0xFFE8A33D);
  static const Color catPsychology = Color(0xFFFF7A9A);
  static const Color catSpirituality = Color(0xFFB2A4FF);
}

/// Per-book visual palette. Used by [BookCover] and reader theming.
class BookPalette {
  const BookPalette({
    required this.bg,
    required this.ink,
    required this.accent,
    required this.shadow,
    required this.coverStyle,
  });

  final Color bg;
  final Color ink;
  final Color accent;
  final Color shadow;
  final String coverStyle; // stacked-bars, split-block, horizon, orbit, brutalist, arch, grid, column

  static const BookPalette defaultPalette = BookPalette(
    bg: Color(0xFF141418),
    ink: Color(0xFFE8F0D6),
    accent: Color(0xFFC8F24B),
    shadow: Color(0xFF1F3A1F),
    coverStyle: 'stacked-bars',
  );
}

/// Lookup table of per-book palettes keyed by book id.
class BookVisuals {
  BookVisuals._();

  static const Map<String, BookPalette> palettes = {
    // Science
    'brief_history_of_time': BookPalette(
      bg: Color(0xFF0A1628),
      ink: Color(0xFFDDEBFF),
      accent: Color(0xFF4EA8FF),
      shadow: Color(0xFF122A4A),
      coverStyle: 'orbit',
    ),
    'sapiens': BookPalette(
      bg: Color(0xFF1F1A14),
      ink: Color(0xFFF0E4D0),
      accent: Color(0xFFD99A5B),
      shadow: Color(0xFF3A2E1F),
      coverStyle: 'arch',
    ),
    'selfish_gene': BookPalette(
      bg: Color(0xFF0D1F1F),
      ink: Color(0xFFCFF5EE),
      accent: Color(0xFF5EE2D0),
      shadow: Color(0xFF1A3838),
      coverStyle: 'grid',
    ),
    // Business
    'atomic_habits': BookPalette(
      bg: Color(0xFF0A1628),
      ink: Color(0xFFDDEBFF),
      accent: Color(0xFF4EA8FF),
      shadow: Color(0xFF122A4A),
      coverStyle: 'orbit',
    ),
    'lean_startup': BookPalette(
      bg: Color(0xFF0F1A0F),
      ink: Color(0xFFE8F0D6),
      accent: Color(0xFFC8F24B),
      shadow: Color(0xFF1F3A1F),
      coverStyle: 'stacked-bars',
    ),
    'zero_to_one': BookPalette(
      bg: Color(0xFF2A0E0E),
      ink: Color(0xFFFFE8D6),
      accent: Color(0xFFFF5A36),
      shadow: Color(0xFF4A1818),
      coverStyle: 'split-block',
    ),
    // Personal Development
    'courage_to_be_disliked': BookPalette(
      bg: Color(0xFF0D0D14),
      ink: Color(0xFFE6E6F0),
      accent: Color(0xFF7B6BFF),
      shadow: Color(0xFF1C1A2E),
      coverStyle: 'grid',
    ),
    'meditations': BookPalette(
      bg: Color(0xFF141414),
      ink: Color(0xFFE8DFC8),
      accent: Color(0xFFD4B266),
      shadow: Color(0xFF2A2218),
      coverStyle: 'column',
    ),
    'mans_search_for_meaning': BookPalette(
      bg: Color(0xFF0A0A0A),
      ink: Color(0xFFF2F2F2),
      accent: Color(0xFFFF3B3B),
      shadow: Color(0xFF2A0808),
      coverStyle: 'brutalist',
    ),
  };

  /// Get palette for a book id. Falls back to a generated palette based on category.
  static BookPalette forBook(String bookId, {String? categoryId}) {
    final palette = palettes[bookId];
    if (palette != null) return palette;
    return forCategory(categoryId);
  }

  /// Fallback palette based on category.
  static BookPalette forCategory(String? categoryId) {
    switch (categoryId) {
      case 'science':
        return const BookPalette(
          bg: Color(0xFF0D1F1F),
          ink: Color(0xFFCFF5EE),
          accent: Color(0xFF5EE2D0),
          shadow: Color(0xFF1A3838),
          coverStyle: 'grid',
        );
      case 'business':
        return const BookPalette(
          bg: Color(0xFF0F1A0F),
          ink: Color(0xFFE8F0D6),
          accent: Color(0xFFC8F24B),
          shadow: Color(0xFF1F3A1F),
          coverStyle: 'stacked-bars',
        );
      case 'personal_development':
        return const BookPalette(
          bg: Color(0xFF0A1628),
          ink: Color(0xFFDDEBFF),
          accent: Color(0xFF4EA8FF),
          shadow: Color(0xFF122A4A),
          coverStyle: 'orbit',
        );
      default:
        return BookPalette.defaultPalette;
    }
  }

  /// Get category accent color by id.
  static Color categoryAccent(String? categoryId) {
    switch (categoryId) {
      case 'science':
        return AppColors.catScience;
      case 'business':
        return AppColors.catBusiness;
      case 'personal_development':
        return AppColors.catPersonal;
      default:
        return AppColors.primary;
    }
  }
}
