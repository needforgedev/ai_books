import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_books/app/theme/app_colors.dart';

/// Floating glass pill tab bar — signature Speedread chrome.
/// Active tab becomes a filled accent chip with label; others show icon only.
class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.accent = AppColors.primary,
    this.badgeIndices = const {},
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color accent;
  /// Tab indices (0-based) that should show a red dot badge.
  final Set<int> badgeIndices;

  static const _tabs = [
    _TabItem('Home', Icons.home_rounded),
    _TabItem('Library', Icons.grid_view_rounded),
    _TabItem('Saved', Icons.bookmark_rounded),
    _TabItem('You', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24, bottom: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00000000),
            Color(0xBF0A0A0C),
            Color(0xFA0A0A0C),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.glassBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    offset: const Offset(0, 12),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_tabs.length, (i) {
                  final active = i == currentIndex;
                  final tab = _tabs[i];
                  return _TabButton(
                    label: tab.label,
                    icon: tab.icon,
                    active: active,
                    accent: accent,
                    hasBadge: badgeIndices.contains(i),
                    onTap: () => onTap(i),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.accent,
    required this.onTap,
    this.hasBadge = false,
  });

  final String label;
  final IconData icon;
  final bool active;
  final Color accent;
  final VoidCallback onTap;
  final bool hasBadge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: active ? 16 : 12),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: active ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: active
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary.withValues(alpha: 0.55),
                ),
                if (active) ...[
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ],
            ),
            if (hasBadge && !active)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
