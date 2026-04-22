import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/book_cover.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Expanded(
                flex: 5,
                child: Center(
                  child: _loaded && _heroBooks.length >= 3
                      ? _HeroCovers(books: _heroBooks)
                      : const SizedBox(height: 220),
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTypography.displayLarge,
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
              const SizedBox(height: 20),
              Text(
                "Eight checkpoints. Twenty minutes. One big idea you'll actually remember.",
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.onGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: AppTypography.buttonLarge,
                    elevation: 0,
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
                        size: 20,
                        color: AppColors.textOnPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No account needed. Works offline.',
                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
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

    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 8,
            top: 30,
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
          Positioned(
            right: 8,
            top: 30,
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
          BookCover(
            title: center.title,
            author: center.author,
            category: _cat(center.categoryId),
            palette: BookVisuals.forBook(center.id, categoryId: center.categoryId),
            width: 130,
            height: 195,
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
