import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/domain/services/progress_service.dart';
import 'package:ai_books/features/reader/screens/checkpoint_complete_screen.dart';
import 'package:ai_books/features/reader/screens/book_complete_screen.dart';

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

    if (!mounted) return;
    setState(() {
      _book = book;
      _checkpoints = checkpoints;
      _currentCheckpointIndex = startIndex;
      _isLoading = false;
    });
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

    // Complete the current checkpoint
    await ProgressService.completeCheckpoint(
      bookId: _book!.id,
      completedCheckpointId: cp.id,
      nextCheckpointId: nextCpId,
      totalCheckpoints: _checkpoints.length,
    );

    if (_isLastCheckpoint) {
      // Finish book
      await ProgressService.finishBook(_book!.id);
      if (!mounted) return;

      // Gather gains from checkpoint titles
      final gains = _checkpoints.map((c) => c.title).toList();

      // Try to get a next book suggestion
      String nextBookTitle = 'Explore more books';
      if (_book!.nextBookIds.isNotEmpty) {
        final nextBook =
            await ContentService.getBook(_book!.nextBookIds.first);
        if (nextBook != null) nextBookTitle = nextBook.title;
      }

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookCompleteScreen(
            bookTitle: _book!.title,
            gains: gains,
            nextBookTitle: nextBookTitle,
            onReadNext: () {
              // Pop back to book detail or library
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            onExplore: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
      // After book complete screen pops, go back to book detail
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      // Show checkpoint complete screen
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
      // Advance to next checkpoint
      if (mounted) {
        setState(() {
          _currentCheckpointIndex++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: const Center(
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

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        title: Text(
          book.title,
          style: AppTypography.bodyEmphasis.copyWith(
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentCheckpointIndex + 1}/${_checkpoints.length}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Checkpoint title
                    Text(checkpoint.title,
                        style: AppTypography.tileHeading),
                    const SizedBox(height: 20),
                    // Hook text
                    if (checkpoint.hookText != null &&
                        checkpoint.hookText!.isNotEmpty) ...[
                      Text(
                        checkpoint.hookText!,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Explanation text
                    if (checkpoint.explanationText != null &&
                        checkpoint.explanationText!.isNotEmpty) ...[
                      Text(
                        checkpoint.explanationText!,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    // Key Quote card
                    if (checkpoint.keyQuote != null &&
                        checkpoint.keyQuote!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceElevated,
                          border: Border(
                            left: BorderSide(
                              color: AppColors.accent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"${checkpoint.keyQuote!}"',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textPrimary,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Modern Example card
                    if (checkpoint.modernExample != null &&
                        checkpoint.modernExample!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modern Example',
                              style: AppTypography.captionBold,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              checkpoint.modernExample!,
                              style: AppTypography.body,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Reflection Prompt card
                    if (checkpoint.reflectionPrompt != null &&
                        checkpoint.reflectionPrompt!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reflect',
                              style: AppTypography.captionBold.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              checkpoint.reflectionPrompt!,
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            // Fixed bottom bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  // Bookmark button
                  GestureDetector(
                    onTap: () {
                      // Bookmark functionality — placeholder
                    },
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(Icons.bookmark_outline_rounded,
                          color: AppColors.textSecondary, size: 22),
                    ),
                  ),
                  const Spacer(),
                  // Next button
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 28),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isLastCheckpoint ? 'FINISH' : 'NEXT',
                            style: AppTypography.button.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
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
