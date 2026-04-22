import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/book_cover.dart';
import 'package:ai_books/core/widgets/radial_glow.dart';
import 'package:ai_books/domain/models/book_entry.dart';
import 'package:ai_books/domain/services/content_service.dart';

class OnboardingWelcomeScreen extends StatefulWidget {
  const OnboardingWelcomeScreen({
    super.key,
    required this.onGetStarted,
  });

  final VoidCallback onGetStarted;

  @override
  State<OnboardingWelcomeScreen> createState() =>
      _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState extends State<OnboardingWelcomeScreen> {
  List<BookEntry> _heroBooks = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    List<BookEntry> books = await ContentService.getFeaturedBooks();
    if (books.length < 3) {
      books = await ContentService.getAllBooks();
    }
    final three = books.take(3).toList();
    if (!mounted) return;
    setState(() {
      _heroBooks = three;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ===== Hero collage (top half, fills) =====
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Atmospheric radial glow
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        alignment: const Alignment(0, -0.4),
                        child: RadialGlow(
                          color: AppColors.primary,
                          size: 480,
                          opacity: 0.18,
                        ),
                      ),
                    ),
                  ),
                  // Book collage centered ~ 90px from top
                  if (_loaded && _heroBooks.length >= 3)
                    Positioned(
                      top: 90,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _HeroCovers(books: _heroBooks),
                      ),
                    ),
                ],
              ),
            ),
            // ===== Bottom content =====
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 42,
                        height: 1.02,
                        letterSpacing: -1.4,
                      ),
                      children: [
                        const TextSpan(text: "The world's best books. In "),
                        TextSpan(
                          text: 'your',
                          style: AppTypography.displayItalic(42,
                              color: AppColors.primary),
                        ),
                        const TextSpan(text: ' language.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      "Eight checkpoints. Twenty minutes. One big idea you'll actually remember.",
                      style: AppTypography.body.copyWith(
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Start the climb',
                            style: AppTypography.buttonLarge,
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: AppColors.textOnPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'No account needed. Works offline.',
                      style: AppTypography.caption.copyWith(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCovers extends StatelessWidget {
  const _HeroCovers({required this.books});

  final List<BookEntry> books;

  @override
  Widget build(BuildContext context) {
    final left = books[0];
    final center = books[1];
    final right = books[2];

    // Center cover is taller; others are shorter and rotated outward + dropped.
    return SizedBox(
      height: 235,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Left cover: rotated -8°, dropped 20px
          Positioned(
            top: 20,
            right: 130,
            child: Transform.rotate(
              angle: -8 * math.pi / 180,
              child: BookCover(
                title: left.title,
                author: left.author,
                category: _cat(left.categoryId),
                palette: BookVisuals.forBook(left.id, categoryId: left.categoryId),
                width: 110,
                height: 165,
              ),
            ),
          ),
          // Right cover: rotated +8°, dropped 20px
          Positioned(
            top: 20,
            left: 130,
            child: Transform.rotate(
              angle: 8 * math.pi / 180,
              child: BookCover(
                title: right.title,
                author: right.author,
                category: _cat(right.categoryId),
                palette: BookVisuals.forBook(right.id, categoryId: right.categoryId),
                width: 110,
                height: 165,
              ),
            ),
          ),
          // Center cover: forward, larger, slightly raised
          Positioned(
            top: 0,
            child: BookCover(
              title: center.title,
              author: center.author,
              category: _cat(center.categoryId),
              palette: BookVisuals.forBook(center.id, categoryId: center.categoryId),
              width: 130,
              height: 195,
            ),
          ),
        ],
      ),
    );
  }

  String _cat(String categoryId) {
    switch (categoryId) {
      case 'science':
        return 'Science';
      case 'business':
        return 'Business';
      case 'personal_development':
        return 'Personal';
      default:
        return categoryId.replaceAll('_', ' ');
    }
  }
}
