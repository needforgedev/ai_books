import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_books/app/theme/app_colors.dart';

/// A reusable selectable chip widget for onboarding screens.
/// Luxury dark style: sharp rectangular edges, Oswald font.
class AiChip extends StatelessWidget {
  const AiChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceCard,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.oswald(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
