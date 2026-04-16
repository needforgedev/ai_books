import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/ai_book_card.dart';

/// Detail screen for a specific category, showing books grouped by difficulty.
class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryDescription,
    required this.themeColor,
  });

  final String categoryTitle;
  final String categoryDescription;
  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          categoryTitle.toUpperCase(),
          style: AppTypography.bodyEmphasis.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Text(
            categoryDescription,
            style: AppTypography.body,
          ),
          const SizedBox(height: 24),

          // -- Start Here (Beginner) --
          _SectionHeader(title: 'START HERE', color: themeColor),
          const SizedBox(height: 12),
          _BookRow(
            books: const [
              _BookData('The Power of Habit', 'Charles Duhigg', 'Beginner', 12),
              _BookData('Sapiens', 'Yuval Noah Harari', 'Beginner', 18),
              _BookData('Outliers', 'Malcolm Gladwell', 'Beginner', 14),
            ],
            coverColor: themeColor,
          ),
          const SizedBox(height: 24),

          // -- Next Depth (Moderate) --
          _SectionHeader(title: 'NEXT DEPTH', color: themeColor),
          const SizedBox(height: 12),
          _BookRow(
            books: const [
              _BookData(
                  'Thinking in Systems', 'Donella Meadows', 'Moderate', 20),
              _BookData('Deep Work', 'Cal Newport', 'Moderate', 16),
              _BookData('The Black Swan', 'Nassim Taleb', 'Moderate', 22),
            ],
            coverColor: themeColor,
          ),
          const SizedBox(height: 24),

          // -- Advanced --
          _SectionHeader(title: 'ADVANCED', color: themeColor),
          const SizedBox(height: 12),
          _BookRow(
            books: const [
              _BookData('Antifragile', 'Nassim Taleb', 'Advanced', 25),
              _BookData(
                  'Godel Escher Bach', 'Douglas Hofstadter', 'Advanced', 30),
              _BookData('The Structure of Scientific Revolutions', 'Thomas Kuhn',
                  'Advanced', 22),
            ],
            coverColor: themeColor,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Section header with a colored accent bar.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.label.copyWith(color: color),
        ),
      ],
    );
  }
}

/// Simple data holder for placeholder books.
class _BookData {
  const _BookData(this.title, this.author, this.difficulty, this.minutes);

  final String title;
  final String author;
  final String difficulty;
  final int minutes;
}

/// A horizontal scrollable row of book cards.
class _BookRow extends StatelessWidget {
  const _BookRow({required this.books, required this.coverColor});

  final List<_BookData> books;
  final Color coverColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          return SizedBox(
            width: 160,
            child: AiBookCard(
              title: book.title,
              author: book.author,
              coverColor: coverColor,
              difficulty: book.difficulty,
              estimatedMinutes: book.minutes,
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
