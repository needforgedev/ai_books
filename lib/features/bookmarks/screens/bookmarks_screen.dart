import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/book_cover.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/bookmark_service.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/domain/services/quiz_service.dart';
import 'package:ai_books/features/book_detail/screens/book_detail_screen.dart';
import 'package:ai_books/features/quiz/screens/quiz_setup_screen.dart';
import 'package:ai_books/features/quiz/widgets/create_quiz_card_sheet.dart';
import 'package:ai_books/features/saved/screens/connections_screen.dart';
import 'package:ai_books/features/saved/widgets/link_picker_sheet.dart';

enum _Tab { saved, connections }

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key, this.refreshTrigger});

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
  int _quizCardCount = 0;
  _Tab _tab = _Tab.saved;

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
    final cardCount = await QuizService.getTotalCardCount();

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
      _quizCardCount = cardCount;
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
        .push(MaterialPageRoute(
          builder: (_) => BookDetailScreen(bookId: bookId),
        ))
        .then((_) => _loadData());
  }

  Future<void> _showItemActions(SavedItem item) async {
    final hasText =
        item.savedText != null && item.savedText!.trim().isNotEmpty;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (hasText)
                ListTile(
                  leading: const Icon(Icons.quiz_outlined,
                      color: AppColors.textSecondary),
                  title: Text('Make a quiz card',
                      style: AppTypography.body
                          .copyWith(color: AppColors.textPrimary)),
                  onTap: () => Navigator.of(context).pop('quiz'),
                ),
              ListTile(
                leading: const Icon(Icons.hub_outlined,
                    color: AppColors.textSecondary),
                title: Text('Link to another note',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textPrimary)),
                onTap: () => Navigator.of(context).pop('link'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (result == 'quiz') {
      final created = await CreateQuizCardSheet.show(context, item);
      if (created) _loadData();
    } else if (result == 'link') {
      final created = await LinkPickerSheet.show(context, item);
      if (created) _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _tab == _Tab.saved
                        ? _buildSaved()
                        : const ConnectionsScreen(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved', style: AppTypography.sectionHeading),
          const SizedBox(height: 16),
          // Saved | Connections segmented toggle
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _SegmentTab(
                  label: 'Saved',
                  active: _tab == _Tab.saved,
                  onTap: () => setState(() => _tab = _Tab.saved),
                ),
                _SegmentTab(
                  label: 'Connections',
                  active: _tab == _Tab.connections,
                  onTap: () => setState(() => _tab = _Tab.connections),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSaved() {
    final isEmpty = _quotes.isEmpty && _bookmarks.isEmpty;
    if (isEmpty) return _buildEmptyState();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
      children: [
        // Quiz banner
        if (_quizCardCount > 0) ...[
          _QuizBanner(
            cardCount: _quizCardCount,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(
                  builder: (_) => const QuizSetupScreen(),
                ))
                .then((_) => _loadData()),
          ),
          const SizedBox(height: 20),
        ],
        if (_quotes.isNotEmpty) ...[
          Text(
            'QUOTES',
            style: AppTypography.eyebrow
                .copyWith(color: AppColors.textTertiary),
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
                  child:
                      const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) => _removeItem(item),
                child: GestureDetector(
                  onTap: () => _openBook(item.sourceBookId),
                  onLongPress: () => _showItemActions(item),
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
            style: AppTypography.eyebrow
                .copyWith(color: AppColors.textTertiary),
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
                  child:
                      const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) => _removeItem(item),
                child: GestureDetector(
                  onTap: () => _openBook(item.sourceBookId),
                  onLongPress: () => _showItemActions(item),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_outline_rounded,
              size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'No saved items yet',
            style:
                AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color:
                active ? AppColors.surfaceCard : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: active
                ? Border.all(color: AppColors.borderSubtle)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: active
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
              fontWeight:
                  active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizBanner extends StatelessWidget {
  const _QuizBanner({required this.cardCount, required this.onTap});

  final int cardCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.quiz_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Quiz yourself  ·  $cardCount card${cardCount == 1 ? '' : 's'} ready',
                style: AppTypography.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote, required this.bookTitle});

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
          Icon(Icons.format_quote_rounded,
              size: 22,
              color: AppColors.primary.withValues(alpha: 0.7)),
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
            style: AppTypography.caption
                .copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  const _BookmarkTile({required this.book, required this.checkpointName});

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
                  style: AppTypography.titleMedium
                      .copyWith(color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book?.title ?? 'Unknown book',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
