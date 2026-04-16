import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/domain/services/progress_service.dart';
import 'package:ai_books/features/reader/screens/book_reader_flow.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({
    super.key,
    required this.bookId,
  });

  final String bookId;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  BookEntry? _book;
  List<CheckpointEntry> _checkpoints = [];
  ReadingProgress? _progress;
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
    if (!mounted) return;
    setState(() {
      _book = book;
      _checkpoints = checkpoints;
      _progress = progress;
      _isLoading = false;
    });
  }

  bool get _isInProgress =>
      _progress != null && _progress!.finishedAt == null;

  int get _progressPercent =>
      (_progress != null ? (_progress!.completionPercent * 100).round() : 0);

  Future<void> _onStartReading() async {
    if (_book == null || _checkpoints.isEmpty) return;
    await ProgressService.startBook(_book!.id, _checkpoints.first.id);
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BookReaderFlow(bookId: _book!.id),
      ),
    );
    // Refresh progress when returning from reader
    if (result == true || result == null) {
      _loadData();
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
    if (book == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Text(
            'Book not found',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Gather first few checkpoint titles for "What you'll learn"
    final learnItems = _checkpoints
        .take(4)
        .map((cp) => cp.title)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Cover placeholder
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title and author
                    Text(book.title, style: AppTypography.sectionHeading),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Metadata pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetadataPill(label: book.difficulty),
                        _MetadataPill(
                            label: '${book.estimatedMinutes} min'),
                        _MetadataPill(
                            label:
                                '${_checkpoints.length} checkpoints'),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Short description
                    if (book.shortDescription != null &&
                        book.shortDescription!.isNotEmpty) ...[
                      Text(book.shortDescription!,
                          style: AppTypography.body),
                      const SizedBox(height: 28),
                    ],
                    // Why this book matters
                    if (book.whyItMatters != null &&
                        book.whyItMatters!.isNotEmpty) ...[
                      Text('Why this book matters',
                          style: AppTypography.cardTitle),
                      const SizedBox(height: 8),
                      Text(book.whyItMatters!, style: AppTypography.body),
                      const SizedBox(height: 28),
                    ],
                    // What you'll learn
                    if (learnItems.isNotEmpty) ...[
                      Text("What you'll learn",
                          style: AppTypography.cardTitle),
                      const SizedBox(height: 12),
                      ...learnItems.map(
                        (item) => _BulletPoint(text: item),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onStartReading,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isInProgress
                        ? 'CONTINUE READING ($_progressPercent%)'
                        : 'START READING',
                    style: AppTypography.buttonLarge,
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

class _MetadataPill extends StatelessWidget {
  const _MetadataPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.body)),
        ],
      ),
    );
  }
}
