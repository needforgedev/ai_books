import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/ai_book_card.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/features/book_detail/screens/book_detail_screen.dart';

/// Detail screen for a specific category, showing books grouped by difficulty.
class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryDescription,
    required this.themeColor,
  });

  final String categoryId;
  final String categoryTitle;
  final String categoryDescription;
  final Color themeColor;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<BookEntry> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await ContentService.getBooksByCategory(widget.categoryId);
    if (!mounted) return;
    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  Map<String, List<BookEntry>> _groupByDifficulty() {
    final groups = <String, List<BookEntry>>{
      'beginner': [],
      'moderate': [],
      'advanced': [],
    };
    for (final book in _books) {
      final key = book.difficulty.toLowerCase();
      if (groups.containsKey(key)) {
        groups[key]!.add(book);
      } else {
        // Fallback: put unrecognized difficulties in beginner
        groups['beginner']!.add(book);
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByDifficulty();

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
          widget.categoryTitle.toUpperCase(),
          style: AppTypography.bodyEmphasis.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                Text(
                  widget.categoryDescription,
                  style: AppTypography.body,
                ),
                const SizedBox(height: 24),
                if (groups['beginner']!.isNotEmpty) ...[
                  _SectionHeader(
                      title: 'START HERE', color: widget.themeColor),
                  const SizedBox(height: 12),
                  _BookRow(
                    books: groups['beginner']!,
                    coverColor: widget.themeColor,
                    onBookTap: _onBookTap,
                  ),
                  const SizedBox(height: 24),
                ],
                if (groups['moderate']!.isNotEmpty) ...[
                  _SectionHeader(
                      title: 'NEXT DEPTH', color: widget.themeColor),
                  const SizedBox(height: 12),
                  _BookRow(
                    books: groups['moderate']!,
                    coverColor: widget.themeColor,
                    onBookTap: _onBookTap,
                  ),
                  const SizedBox(height: 24),
                ],
                if (groups['advanced']!.isNotEmpty) ...[
                  _SectionHeader(
                      title: 'ADVANCED', color: widget.themeColor),
                  const SizedBox(height: 12),
                  _BookRow(
                    books: groups['advanced']!,
                    coverColor: widget.themeColor,
                    onBookTap: _onBookTap,
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
    );
  }

  void _onBookTap(BookEntry book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailScreen(bookId: book.id),
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

/// A horizontal scrollable row of book cards.
class _BookRow extends StatelessWidget {
  const _BookRow({
    required this.books,
    required this.coverColor,
    required this.onBookTap,
  });

  final List<BookEntry> books;
  final Color coverColor;
  final void Function(BookEntry) onBookTap;

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
              estimatedMinutes: book.estimatedMinutes,
              onTap: () => onBookTap(book),
            ),
          );
        },
      ),
    );
  }
}
