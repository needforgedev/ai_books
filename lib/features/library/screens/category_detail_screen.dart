import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/book_cover.dart';
import 'package:ai_books/core/widgets/radial_glow.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/features/book_detail/screens/book_detail_screen.dart';

/// Detail screen for a specific category — cinematic redesign.
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
        groups['beginner']!.add(book);
      }
    }
    return groups;
  }

  void _openBook(BookEntry book) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.themeColor;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Hero(
                    title: widget.categoryTitle,
                    description: widget.categoryDescription,
                    accent: accent,
                    bookCount: _books.length,
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        'A guided climb from accessible ideas to deep interpretation. Read in order or jump in.',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._buildTier(
                        label: 'START HERE',
                        books: _groupByDifficulty()['beginner']!,
                        accent: accent,
                        accentOpacity: 1.0,
                      ),
                      const SizedBox(height: 24),
                      ..._buildTier(
                        label: 'NEXT DEPTH',
                        books: _groupByDifficulty()['moderate']!,
                        accent: accent,
                        accentOpacity: 0.65,
                      ),
                      const SizedBox(height: 24),
                      ..._buildTier(
                        label: 'ADVANCED',
                        books: _groupByDifficulty()['advanced']!,
                        accent: accent,
                        accentOpacity: 0.4,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildTier({
    required String label,
    required List<BookEntry> books,
    required Color accent,
    required double accentOpacity,
  }) {
    return [
      _TierHeader(
        label: label,
        accent: accent.withValues(alpha: accentOpacity),
      ),
      const SizedBox(height: 14),
      if (books.isEmpty)
        _EmptyTier(accent: accent.withValues(alpha: accentOpacity * 0.6))
      else
        ...books.map((book) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BookRowCard(
                book: book,
                categoryTitle: widget.categoryTitle,
                onTap: () => _openBook(book),
              ),
            )),
    ];
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.title,
    required this.description,
    required this.accent,
    required this.bookCount,
    required this.onBack,
  });

  final String title;
  final String description;
  final Color accent;
  final int bookCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accent.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -30,
            right: -40,
            child: IgnorePointer(
              child: RadialGlow(color: accent, size: 280, opacity: 0.35),
            ),
          ),
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x0FFFFFFF),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CATEGORY',
                  style: AppTypography.eyebrow.copyWith(color: accent),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: AppTypography.sectionHeading.copyWith(fontSize: 38),
                ),
                const SizedBox(height: 6),
                Text(
                  '$description  ·  $bookCount books',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierHeader extends StatelessWidget {
  const _TierHeader({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 24, height: 1, color: accent),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTypography.eyebrow.copyWith(color: accent),
        ),
      ],
    );
  }
}

class _BookRowCard extends StatelessWidget {
  const _BookRowCard({
    required this.book,
    required this.categoryTitle,
    required this.onTap,
  });

  final BookEntry book;
  final String categoryTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = BookVisuals.forBook(book.id, categoryId: book.categoryId);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(
              title: book.title,
              author: book.author,
              category: categoryTitle,
              palette: palette,
              width: 72,
              height: 108,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    book.title,
                    style: AppTypography.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${book.estimatedMinutes} min · ${book.difficulty.toLowerCase()}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
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

class _EmptyTier extends StatelessWidget {
  const _EmptyTier({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withValues(alpha: 0.4),
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Text(
        'Unlocks as you finish earlier books',
        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}
