import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/bookmark_service.dart';
import 'package:ai_books/domain/services/content_service.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<SavedItem> _quotes = [];
  List<SavedItem> _bookmarks = [];
  Map<String, String> _bookTitles = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final quotes = await BookmarkService.getQuotes();
    final bookmarks = await BookmarkService.getBookmarks();

    // Collect unique book IDs and fetch titles
    final bookIds = <String>{};
    for (final item in [...quotes, ...bookmarks]) {
      bookIds.add(item.sourceBookId);
    }

    final titles = <String, String>{};
    for (final id in bookIds) {
      final book = await ContentService.getBook(id);
      if (book != null) {
        titles[id] = book.title;
      }
    }

    if (!mounted) return;
    setState(() {
      _quotes = quotes;
      _bookmarks = bookmarks;
      _bookTitles = titles;
      _isLoading = false;
    });
  }

  Future<void> _removeItem(SavedItem item) async {
    if (item.id == null) return;
    await BookmarkService.removeSaved(item.id!);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_outline_rounded,
            size: 64,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16),
          Text(
            'No saved items yet',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('SAVED', style: AppTypography.sectionHeading),
          const SizedBox(height: 28),
          // Quotes section
          if (_quotes.isNotEmpty) ...[
            Text('QUOTES', style: AppTypography.label),
            const SizedBox(height: 12),
            ..._quotes.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: ValueKey('quote-${item.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red.withValues(alpha: 0.8),
                      child: const Icon(Icons.delete_outline,
                          color: Colors.white),
                    ),
                    onDismissed: (_) => _removeItem(item),
                    child: _QuoteCard(
                      quote: item.savedText ?? '',
                      source:
                          _bookTitles[item.sourceBookId] ?? 'Unknown Book',
                    ),
                  ),
                )),
            const SizedBox(height: 22),
          ],
          // Bookmarks section
          if (_bookmarks.isNotEmpty) ...[
            Text('BOOKMARKS', style: AppTypography.label),
            const SizedBox(height: 12),
            ..._bookmarks.map((item) => Dismissible(
                  key: ValueKey('bookmark-${item.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.withValues(alpha: 0.8),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white),
                  ),
                  onDismissed: (_) => _removeItem(item),
                  child: _BookmarkTile(
                    bookName:
                        _bookTitles[item.sourceBookId] ?? 'Unknown Book',
                    checkpointName:
                        item.sourceCheckpointId ?? 'Checkpoint',
                  ),
                )),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.source,
  });

  final String quote;
  final String source;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"$quote"',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            source,
            style: AppTypography.captionBold,
          ),
        ],
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  const _BookmarkTile({
    required this.bookName,
    required this.checkpointName,
  });

  final String bookName;
  final String checkpointName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bookmark_rounded,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookName,
                  style: AppTypography.bodyEmphasis,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  checkpointName,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
