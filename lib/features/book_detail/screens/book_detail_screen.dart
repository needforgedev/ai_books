import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/book_cover.dart';
import 'package:ai_books/core/widgets/radial_glow.dart';
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
  CategoryEntry? _category;
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
    CategoryEntry? category;
    if (book != null) {
      category = await ContentService.getCategory(book.categoryId);
    }
    final checkpoints = await ContentService.getCheckpoints(widget.bookId);
    final progress = await ProgressService.getProgress(widget.bookId);
    if (!mounted) return;
    setState(() {
      _book = book;
      _category = category;
      _checkpoints = checkpoints;
      _progress = progress;
      _isLoading = false;
    });
  }

  int get _doneCount => _progress?.completedCheckpointIds.length ?? 0;
  bool get _isStarted => _doneCount > 0;

  Future<void> _onStartReading() async {
    final book = _book;
    if (book == null || _checkpoints.isEmpty) return;
    await ProgressService.startBook(book.id, _checkpoints.first.id);
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => BookReaderFlow(bookId: book.id)),
    );
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

    final palette = BookVisuals.forBook(book.id, categoryId: book.categoryId);
    final accent = palette.accent;
    final categoryLabel = _category?.title ??
        book.categoryId.replaceAll('_', ' ');
    final currentId = _progress?.currentCheckpointId;
    final doneIds = _progress?.completedCheckpointIds.toSet() ?? <String>{};

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Atmospheric glow behind hero
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            height: 420,
            child: IgnorePointer(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            palette.bg.withValues(alpha: 0.88),
                            AppColors.surface,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.0, -0.4),
                    child: RadialGlow(color: accent, size: 360, opacity: 0.35),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar: back + bookmark
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      _CircleIcon(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      _CircleIcon(
                        icon: Icons.bookmark_outline_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    children: [
                      // Cover centered
                      Center(
                        child: BookCover(
                          title: book.title,
                          author: book.author,
                          category: categoryLabel,
                          palette: palette,
                          width: 170,
                          height: 254,
                          withRail: _isStarted,
                          doneCount: _doneCount,
                          totalCheckpoints: _checkpoints.length,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          categoryLabel.toUpperCase(),
                          style: AppTypography.eyebrow.copyWith(color: accent),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        book.title,
                        style: AppTypography.bookTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'by ${book.author}',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${book.estimatedMinutes} min  ·  ${_checkpoints.length} checkpoints  ·  ${book.difficulty}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      // Why this book
                      if (book.whyItMatters != null &&
                          book.whyItMatters!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0x08FFFFFF),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WHY THIS BOOK',
                                style: AppTypography.eyebrow
                                    .copyWith(color: accent),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                book.whyItMatters!,
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 18,
                                  height: 1.35,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                      // The spine
                      Text('The spine', style: AppTypography.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        '${_checkpoints.length} checkpoints · climb at your pace',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Spine(
                        checkpoints: _checkpoints,
                        doneIds: doneIds,
                        currentId: currentId,
                        accent: accent,
                        paletteBg: palette.bg,
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sticky bottom CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.surface.withValues(alpha: 0),
                    AppColors.surface,
                    AppColors.surface,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onStartReading,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        _isStarted ? 'Continue reading' : 'Start reading',
                        style: AppTypography.buttonLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0x0FFFFFFF),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _Spine extends StatelessWidget {
  const _Spine({
    required this.checkpoints,
    required this.doneIds,
    required this.currentId,
    required this.accent,
    required this.paletteBg,
  });

  final List<CheckpointEntry> checkpoints;
  final Set<String> doneIds;
  final String? currentId;
  final Color accent;
  final Color paletteBg;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(checkpoints.length, (i) {
        final cp = checkpoints[i];
        final isDone = doneIds.contains(cp.id);
        final isCurrent = currentId == cp.id && !isDone;
        final isLast = i == checkpoints.length - 1;

        // Next connector: colored if this node is done
        final connectorColor = isDone
            ? accent
            : const Color(0x1AFFFFFF);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Node(
                      isDone: isDone,
                      isCurrent: isCurrent,
                      accent: accent,
                      paletteBg: paletteBg,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: connectorColor,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        cp.title,
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 16,
                          color: isDone
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: AppColors.textMuted,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 6),
                        Text(
                          'YOU ARE HERE',
                          style: AppTypography.eyebrow.copyWith(
                            color: accent,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.isDone,
    required this.isCurrent,
    required this.accent,
    required this.paletteBg,
  });

  final bool isDone;
  final bool isCurrent;
  final Color accent;
  final Color paletteBg;

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.45),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 14,
          color: AppColors.textOnPrimary,
        ),
      );
    }

    if (isCurrent) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: paletteBg,
          shape: BoxShape.circle,
          border: Border.all(color: accent, width: 2),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.55),
              blurRadius: 14,
            ),
          ],
        ),
      );
    }

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
    );
  }
}
