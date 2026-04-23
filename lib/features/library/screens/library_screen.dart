import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/book_cover.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/features/book_detail/screens/book_detail_screen.dart';
import 'package:ai_books/features/library/screens/category_detail_screen.dart';
import 'package:ai_books/features/search/screens/search_screen.dart';

/// The library screen — cinematic redesign.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<CategoryEntry> _categories = [];
  Map<String, int> _bookCounts = {};
  List<BookEntry> _featured = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await ContentService.getCategories();
    final counts = <String, int>{};
    for (final cat in categories) {
      counts[cat.id] = await ContentService.getBookCount(cat.id);
    }
    final allBooks = await ContentService.getAllBooks();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _bookCounts = counts;
      _featured = allBooks;
      _isLoading = false;
    });
  }

  String _categoryLabel(String id) {
    for (final c in _categories) {
      if (c.id == id) return c.title;
    }
    return id;
  }

  void _openCategory(CategoryEntry cat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryDetailScreen(
          categoryId: cat.id,
          categoryTitle: cat.title,
          categoryDescription: cat.description,
          themeColor: BookVisuals.categoryAccent(cat.id),
        ),
      ),
    );
  }

  void _openBook(BookEntry book) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: AppColors.surface,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final canPop = Navigator.of(context).canPop();

    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            if (canPop) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0x0FFFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
            Text('THE SHELF', style: AppTypography.eyebrow),
            const SizedBox(height: 10),
            Text('Library', style: AppTypography.sectionHeading),
            const SizedBox(height: 18),
            _SearchBar(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
            const SizedBox(height: 28),
            Text('Categories', style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            ...List.generate(_categories.length, (i) {
              final cat = _categories[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CategoryRow(
                  category: cat,
                  accent: BookVisuals.categoryAccent(cat.id),
                  count: _bookCounts[cat.id] ?? 0,
                  onTap: () => _openCategory(cat),
                ),
              );
            }),
            const SizedBox(height: 28),
            Text('Featured', style: AppTypography.titleLarge),
            const SizedBox(height: 14),
            _FeaturedGrid(
              books: _featured,
              categoryLabel: _categoryLabel,
              onTap: _openBook,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0x0FFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search books, authors, topics',
                style: AppTypography.body.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.accent,
    required this.count,
    required this.onTap,
  });

  final CategoryEntry category;
  final Color accent;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 56,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.55),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$count',
              style: AppTypography.titleMedium.copyWith(color: accent),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedGrid extends StatelessWidget {
  const _FeaturedGrid({
    required this.books,
    required this.categoryLabel,
    required this.onTap,
  });

  final List<BookEntry> books;
  final String Function(String) categoryLabel;
  final void Function(BookEntry) onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final tileWidth = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: 20,
          children: books.map((book) {
            final palette = BookVisuals.forBook(
              book.id,
              categoryId: book.categoryId,
            );
            return SizedBox(
              width: tileWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCover(
                    title: book.title,
                    author: book.author,
                    category: categoryLabel(book.categoryId),
                    palette: palette,
                    width: tileWidth,
                    height: tileWidth * 1.5,
                    onTap: () => onTap(book),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
