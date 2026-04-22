import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/book_cover.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/bookmark_service.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/features/book_detail/screens/book_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key, this.refreshTrigger});

  /// External notifier — when its value changes, the screen reloads.
  /// Used by MainShell to refresh on tab tap.
  final ValueListenable<int>? refreshTrigger;

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<SavedItem> _quotes = [];
  List<SavedItem> _bookmarks = [];
  Map<String, BookEntry> _booksById = {};
  Map<String, CheckpointEntry> _checkpointsById = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    widget.refreshTrigger?.addListener(_loadData);
  }

  @override
  void dispose() {
    widget.refreshTrigger?.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final quotes = await BookmarkService.getQuotes();
    final bookmarks = await BookmarkService.getBookmarks();

    final bookIds = <String>{};
    final checkpointIds = <String>{};
    for (final item in [...quotes, ...bookmarks]) {
      bookIds.add(item.sourceBookId);
      if (item.sourceCheckpointId != null) {
        checkpointIds.add(item.sourceCheckpointId!);
      }
    }

    final bookMap = <String, BookEntry>{};
    for (final id in bookIds) {
      final book = await ContentService.getBook(id);
      if (book != null) bookMap[id] = book;
    }

    final checkpointMap = <String, CheckpointEntry>{};
    for (final id in checkpointIds) {
      final cp = await ContentService.getCheckpoint(id);
      if (cp != null) checkpointMap[id] = cp;
    }

    if (!mounted) return;
    setState(() {
      _quotes = quotes;
      _bookmarks = bookmarks;
      _booksById = bookMap;
      _checkpointsById = checkpointMap;
      _isLoading = false;
    });
  }

  Future<void> _removeItem(SavedItem item) async {
    if (item.id == null) return;
    await BookmarkService.removeSaved(item.id!);
    _loadData();
  }

  void _openBook(String bookId) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => BookDetailScreen(bookId: bookId),
      ),
    )
        .then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : (_quotes.isEmpty && _bookmarks.isEmpty)
                ? _buildEmptyState()
                : _buildContent(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_outline_rounded,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved items yet',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Text('Saved', style: AppTypography.sectionHeading),
        const SizedBox(height: 28),
        if (_quotes.isNotEmpty) ...[
          Text(
            'QUOTES',
            style: AppTypography.eyebrow.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 14),
          ..._quotes.map((item) {
            final book = _booksById[item.sourceBookId];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey('quote-${item.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) => _removeItem(item),
                child: GestureDetector(
                  onTap: () => _openBook(item.sourceBookId),
                  child: _QuoteCard(
                    quote: item.savedText ?? '',
                    bookTitle: book?.title ?? 'Unknown',
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
        if (_bookmarks.isNotEmpty) ...[
          Text(
            'BOOKMARKS',
            style: AppTypography.eyebrow.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 14),
          ..._bookmarks.map((item) {
            final book = _booksById[item.sourceBookId];
            final cp = item.sourceCheckpointId != null
                ? _checkpointsById[item.sourceCheckpointId!]
                : null;
            final cpName = cp?.title ?? 'Checkpoint';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey('bookmark-${item.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) => _removeItem(item),
                child: GestureDetector(
                  onTap: () => _openBook(item.sourceBookId),
                  child: _BookmarkTile(
                    book: book,
                    checkpointName: cpName,
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.bookTitle,
  });

  final String quote;
  final String bookTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 22,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 10),
          Text(
            quote,
            style: AppTypography.displayItalic(16).copyWith(
              color: AppColors.textPrimary,
              height: 1.45,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '— $bookTitle',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  const _BookmarkTile({
    required this.book,
    required this.checkpointName,
  });

  final BookEntry? book;
  final String checkpointName;

  @override
  Widget build(BuildContext context) {
    final palette = book != null
        ? BookVisuals.forBook(book!.id, categoryId: book!.categoryId)
        : BookPalette.defaultPalette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          BookCover(
            title: book?.title ?? 'Unknown',
            author: book?.author ?? '',
            category: (book?.categoryId ?? '').toUpperCase(),
            palette: palette,
            width: 60,
            height: 90,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checkpointName,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book?.title ?? 'Unknown book',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
