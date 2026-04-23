import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/progress_rail.dart';
import 'package:ai_books/core/widgets/radial_glow.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/domain/services/progress_service.dart';
import 'package:ai_books/domain/services/bookmark_service.dart';
import 'package:ai_books/domain/services/streak_service.dart';
import 'package:ai_books/features/reader/screens/checkpoint_complete_screen.dart';
import 'package:ai_books/features/reader/screens/book_complete_screen.dart';
import 'package:ai_books/features/reader/screens/mindmap_screen.dart';
import 'package:ai_books/features/reader/screens/quote_decode_screen.dart';

/// Manages the full reading flow for a book: loads checkpoints, shows them
/// one by one, saves progress, and handles checkpoint/book completion.
class BookReaderFlow extends StatefulWidget {
  const BookReaderFlow({super.key, required this.bookId});

  final String bookId;

  @override
  State<BookReaderFlow> createState() => _BookReaderFlowState();
}

class _BookReaderFlowState extends State<BookReaderFlow> {
  BookEntry? _book;
  List<CheckpointEntry> _checkpoints = [];
  int _currentCheckpointIndex = 0;
  bool _isLoading = true;
  bool _isCurrentBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final book = await ContentService.getBook(widget.bookId);
    final checkpoints = await ContentService.getCheckpoints(widget.bookId);
    final progress = await ProgressService.getProgress(widget.bookId);

    // Start book if not already started
    if (book != null && checkpoints.isNotEmpty) {
      await ProgressService.startBook(book.id, checkpoints.first.id);
    }

    // Resume from where user left off
    int startIndex = 0;
    if (progress != null && progress.currentCheckpointId != null) {
      final idx = checkpoints
          .indexWhere((cp) => cp.id == progress.currentCheckpointId);
      if (idx >= 0) startIndex = idx;
    }

    bool bookmarked = false;
    if (checkpoints.isNotEmpty) {
      bookmarked =
          await BookmarkService.isBookmarked(checkpoints[startIndex].id);
    }

    if (!mounted) return;
    setState(() {
      _book = book;
      _checkpoints = checkpoints;
      _currentCheckpointIndex = startIndex;
      _isCurrentBookmarked = bookmarked;
      _isLoading = false;
    });
  }

  Future<void> _checkBookmarkState() async {
    final cp = _currentCheckpoint;
    if (cp == null) return;
    final bookmarked = await BookmarkService.isBookmarked(cp.id);
    if (!mounted) return;
    setState(() => _isCurrentBookmarked = bookmarked);
  }

  CheckpointEntry? get _currentCheckpoint {
    if (_checkpoints.isEmpty ||
        _currentCheckpointIndex >= _checkpoints.length) {
      return null;
    }
    return _checkpoints[_currentCheckpointIndex];
  }

  bool get _isLastCheckpoint =>
      _currentCheckpointIndex >= _checkpoints.length - 1;

  Future<void> _onNext() async {
    final cp = _currentCheckpoint;
    if (cp == null || _book == null) return;

    final nextCpId = _isLastCheckpoint
        ? null
        : _checkpoints[_currentCheckpointIndex + 1].id;

    await ProgressService.completeCheckpoint(
      bookId: _book!.id,
      completedCheckpointId: cp.id,
      nextCheckpointId: nextCpId,
      totalCheckpoints: _checkpoints.length,
    );

    await StreakService.recordActivity(additionalCheckpoints: 1);

    if (_isLastCheckpoint) {
      await ProgressService.finishBook(_book!.id);
      if (!mounted) return;

      // Pick the most memorable quote as the takeaway — last checkpoint's
      // key quote, else first non-empty, else last checkpoint title.
      String? takeawayQuote;
      for (final c in _checkpoints.reversed) {
        if (c.keyQuote != null && c.keyQuote!.trim().isNotEmpty) {
          takeawayQuote = c.keyQuote!.trim();
          break;
        }
      }
      takeawayQuote ??= _checkpoints.last.title;

      final String? nextBookId =
          _book!.nextBookIds.isNotEmpty ? _book!.nextBookIds.first : null;

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookCompleteScreen(
            bookTitle: _book!.title,
            author: _book!.author,
            bookId: _book!.id,
            categoryId: _book!.categoryId,
            totalCheckpoints: _checkpoints.length,
            totalMinutes: _book!.estimatedMinutes,
            takeawayQuote: takeawayQuote!,
            nextBookId: nextBookId,
          ),
        ),
      );
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    } else {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckpointCompleteScreen(
            checkpointNumber: _currentCheckpointIndex + 1,
            totalCheckpoints: _checkpoints.length,
            keyTakeaway: cp.recapText ?? cp.title,
            onContinue: () => Navigator.of(context).pop(),
            onReturnHome: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
      if (mounted) {
        setState(() {
          _currentCheckpointIndex++;
        });
        _checkBookmarkState();
      }
    }
  }

  Future<void> _onPrev() async {
    if (_currentCheckpointIndex == 0) return;
    setState(() {
      _currentCheckpointIndex--;
    });
    _checkBookmarkState();
  }

  Future<void> _onToggleBookmark() async {
    final cp = _currentCheckpoint;
    if (cp == null || _book == null) return;
    final isNowBookmarked = await BookmarkService.toggleBookmark(
      bookId: _book!.id,
      checkpointId: cp.id,
    );
    if (!mounted) return;
    setState(() => _isCurrentBookmarked = isNowBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isNowBookmarked ? 'Bookmark saved' : 'Bookmark removed'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openQuoteDecode(BookPalette palette, CheckpointEntry cp) {
    if (cp.keyQuote == null || cp.keyQuote!.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => QuoteDecodeScreen(
          quote: cp.keyQuote!,
          author: _book?.author ?? 'Unknown',
          meaning: cp.explanationText ?? cp.recapText ?? cp.title,
          palette: palette,
          onSave: () async {
            if (_book == null) return;
            await BookmarkService.saveQuote(
              bookId: _book!.id,
              checkpointId: cp.id,
              quoteText: cp.keyQuote!,
            );
          },
        ),
      ),
    );
  }

  void _openMindMap() {
    final book = _book;
    final path = book?.mindmapAssetPath;
    if (book == null || path == null || path.isEmpty) return;
    final palette =
        BookVisuals.forBook(book.id, categoryId: book.categoryId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MindMapScreen(
          assetPath: path,
          bookTitle: book.title,
          accent: palette.accent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final book = _book;
    final checkpoint = _currentCheckpoint;
    if (book == null || checkpoint == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Text(
            'No content available',
            style:
                AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final palette = BookVisuals.forBook(book.id, categoryId: book.categoryId);
    final nextTitle = _isLastCheckpoint
        ? 'Finish book'
        : 'Checkpoint ${_currentCheckpointIndex + 2}: '
            '${_checkpoints[_currentCheckpointIndex + 1].title}';

    return Scaffold(
      backgroundColor: palette.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Ambient accent glow top-right
              Positioned(
                top: -100,
                right: -60,
                child: RadialGlow(
                  color: palette.accent,
                  size: 300,
                  opacity: 0.15,
                ),
              ),
              // Vertical progress rail on LEFT edge
              Positioned(
                top: 120,
                bottom: 120,
                left: 12,
                child: ProgressRail(
                  total: _checkpoints.length,
                  done: _currentCheckpointIndex,
                  accent: palette.accent,
                  height: constraints.maxHeight - 240,
                  thickness: 3,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // Top chrome
                    _ReaderTopBar(
                      palette: palette,
                      bookTitle: book.title,
                      current: _currentCheckpointIndex + 1,
                      total: _checkpoints.length,
                      bookmarked: _isCurrentBookmarked,
                      onBack: () => Navigator.of(context).pop(true),
                      onToggleBookmark: _onToggleBookmark,
                    ),
                    // Body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(48, 12, 24, 160),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Eyebrow
                            Text(
                              'CORE IDEA',
                              style: AppTypography.eyebrow.copyWith(
                                color: palette.accent,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Huge checkpoint title
                            Text(
                              checkpoint.title,
                              style: AppTypography
                                  .sectionHeading
                                  .copyWith(
                                fontSize: 34,
                                color: palette.ink,
                                letterSpacing: -1.0,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Hook card
                            if (checkpoint.hookText != null &&
                                checkpoint.hookText!.isNotEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: palette.ink.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        palette.ink.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HOOK',
                                      style: AppTypography.eyebrow.copyWith(
                                        color: palette.ink
                                            .withValues(alpha: 0.55),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      checkpoint.hookText!,
                                      style: AppTypography.titleMedium
                                          .copyWith(
                                        color: palette.ink,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                            ],
                            // Explanation text
                            if (checkpoint.explanationText != null &&
                                checkpoint.explanationText!.isNotEmpty) ...[
                              Text(
                                checkpoint.explanationText!,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontSize: 16,
                                  height: 1.65,
                                  color:
                                      palette.ink.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 22),
                            ],
                            // Optional illustration — rendered right below
                            // the checkpoint's explanation text when the
                            // checkpoint has a bundled image asset.
                            if (checkpoint.imageAssetOrUrl != null &&
                                checkpoint.imageAssetOrUrl!.isNotEmpty) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: palette.ink.withValues(alpha: 0.04),
                                    border: Border.all(
                                      color: palette.ink
                                          .withValues(alpha: 0.12),
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Image.asset(
                                    checkpoint.imageAssetOrUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(
                                        'Image unavailable',
                                        style: AppTypography.caption.copyWith(
                                          color: palette.ink
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),
                            ],
                            // Modern example
                            if (checkpoint.modernExample != null &&
                                checkpoint.modernExample!.isNotEmpty) ...[
                              Text(
                                'MODERN EXAMPLE',
                                style: AppTypography.eyebrow.copyWith(
                                  color: palette.ink
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                checkpoint.modernExample!,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontSize: 16,
                                  height: 1.65,
                                  color:
                                      palette.ink.withValues(alpha: 0.78),
                                ),
                              ),
                              const SizedBox(height: 22),
                            ],
                            // Quote pull (tappable)
                            if (checkpoint.keyQuote != null &&
                                checkpoint.keyQuote!.isNotEmpty) ...[
                              GestureDetector(
                                onTap: () =>
                                    _openQuoteDecode(palette, checkpoint),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: palette.accent,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.format_quote_rounded,
                                        color: palette.bg,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              checkpoint.keyQuote!,
                                              style: AppTypography
                                                  .titleMedium
                                                  .copyWith(
                                                color: palette.bg,
                                                fontStyle: FontStyle.italic,
                                                height: 1.35,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'TAP TO DECODE →',
                                              style: AppTypography.eyebrow
                                                  .copyWith(
                                                color: palette.bg
                                                    .withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),
                            ],
                            // Reflection prompt
                            if (checkpoint.reflectionPrompt != null &&
                                checkpoint
                                    .reflectionPrompt!.isNotEmpty) ...[
                              Text(
                                'REFLECT',
                                style: AppTypography.eyebrow.copyWith(
                                  color: palette.accent,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                checkpoint.reflectionPrompt!,
                                style: AppTypography.titleMedium.copyWith(
                                  color: palette.ink,
                                  height: 1.4,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            // Mind map teaser — shown ONLY on the last
                            // checkpoint (right before "Finish book") when
                            // the book has a bundled mind map HTML asset.
                            if (_isLastCheckpoint &&
                                _book!.mindmapAssetPath != null &&
                                _book!.mindmapAssetPath!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _MindMapTeaserCard(
                                palette: palette,
                                onTap: _openMindMap,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom nav bar with gradient fade
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ReaderBottomBar(
                  palette: palette,
                  nextTitle: nextTitle,
                  showPrev: _currentCheckpointIndex > 0,
                  onPrev: _onPrev,
                  onNext: _onNext,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReaderTopBar extends StatelessWidget {
  const _ReaderTopBar({
    required this.palette,
    required this.bookTitle,
    required this.current,
    required this.total,
    required this.bookmarked,
    required this.onBack,
    required this.onToggleBookmark,
  });

  final BookPalette palette;
  final String bookTitle;
  final int current;
  final int total;
  final bool bookmarked;
  final VoidCallback onBack;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            palette: palette,
            onTap: onBack,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  bookTitle.toUpperCase(),
                  style: AppTypography.eyebrow.copyWith(
                    color: palette.ink.withValues(alpha: 0.55),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Checkpoint $current of $total',
                  style: AppTypography.caption.copyWith(
                    color: palette.ink.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _RoundIconButton(
            icon: bookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_outline_rounded,
            palette: palette,
            tint: bookmarked ? palette.accent : null,
            onTap: onToggleBookmark,
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.palette,
    required this.onTap,
    this.tint,
  });

  final IconData icon;
  final BookPalette palette;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: palette.ink.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.ink.withValues(alpha: 0.12)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: tint ?? palette.ink.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _ReaderBottomBar extends StatelessWidget {
  const _ReaderBottomBar({
    required this.palette,
    required this.nextTitle,
    required this.showPrev,
    required this.onPrev,
    required this.onNext,
  });

  final BookPalette palette;
  final String nextTitle;
  final bool showPrev;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.bg.withValues(alpha: 0),
            palette.bg.withValues(alpha: 0.85),
            palette.bg,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (showPrev) ...[
              GestureDetector(
                onTap: onPrev,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: palette.ink.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: palette.ink.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: palette.ink.withValues(alpha: 0.9),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: GestureDetector(
                onTap: onNext,
                child: Container(
                  height: 56,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          nextTitle,
                          style: AppTypography.button.copyWith(
                            color: palette.bg,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: palette.bg,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Teaser card shown on the last checkpoint inviting the reader to open
/// the mind map before tapping "Finish book."
class _MindMapTeaserCard extends StatelessWidget {
  const _MindMapTeaserCard({required this.palette, required this.onTap});

  final BookPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              palette.accent.withValues(alpha: 0.16),
              palette.accent.withValues(alpha: 0.04),
            ],
          ),
          border: Border.all(color: palette.accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: palette.accent.withValues(alpha: 0.55),
                ),
              ),
              child: Icon(
                Icons.account_tree_rounded,
                size: 20,
                color: palette.accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MIND MAP',
                    style: AppTypography.eyebrow.copyWith(
                      color: palette.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'See the whole book as one picture',
                    style: AppTypography.titleMedium.copyWith(
                      color: palette.ink,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: palette.accent,
            ),
          ],
        ),
      ),
    );
  }
}
