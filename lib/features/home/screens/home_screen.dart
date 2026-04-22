import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/storage/database_helper.dart';
import 'package:ai_books/core/widgets/book_cover.dart';
import 'package:ai_books/core/widgets/progress_rail.dart';
import 'package:ai_books/core/widgets/radial_glow.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/domain/services/onboarding_service.dart';
import 'package:ai_books/domain/services/progress_service.dart';
import 'package:ai_books/features/book_detail/screens/book_detail_screen.dart';
import 'package:ai_books/features/library/screens/category_detail_screen.dart';
import 'package:ai_books/features/library/screens/library_screen.dart';
import 'package:ai_books/features/reader/screens/book_reader_flow.dart';

/// The main home screen — cinematic dark redesign.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  String _displayName = '';

  ReadingProgress? _currentProgress;
  BookEntry? _currentBook;
  CheckpointEntry? _currentCheckpoint;
  int _totalCheckpoints = 0;

  BookEntry? _bestForYou;
  CategoryEntry? _bestForYouCategory;

  List<BookEntry> _upNext = [];

  List<CategoryEntry> _categories = [];

  int _streakDays = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        OnboardingService.getUserProfile(), // 0
        ProgressService.getMostRecentProgress(), // 1
        ContentService.getFeaturedBooks(), // 2
        ContentService.getCategories(), // 3
        ContentService.getAllBooks(), // 4
        _getStreakDays(), // 5
      ]);

      final userProfile = results[0] as Map<String, dynamic>?;
      final progress = results[1] as ReadingProgress?;
      final featured = results[2] as List<BookEntry>;
      final categories = results[3] as List<CategoryEntry>;
      final allBooks = results[4] as List<BookEntry>;
      final streakDays = results[5] as int;

      BookEntry? currentBook;
      CheckpointEntry? currentCheckpoint;
      int totalCheckpoints = 0;
      if (progress != null) {
        currentBook = await ContentService.getBook(progress.bookId);
        final checkpoints =
            await ContentService.getCheckpoints(progress.bookId);
        totalCheckpoints = checkpoints.length;
        if (progress.currentCheckpointId != null) {
          for (final c in checkpoints) {
            if (c.id == progress.currentCheckpointId) {
              currentCheckpoint = c;
              break;
            }
          }
        }
        currentCheckpoint ??=
            checkpoints.isNotEmpty ? checkpoints.first : null;
      }

      // "Best for you" — first featured book that isn't the continue-reading book
      BookEntry? bestForYou;
      final candidatePool =
          featured.isNotEmpty ? featured : allBooks;
      for (final b in candidatePool) {
        if (b.id != currentBook?.id) {
          bestForYou = b;
          break;
        }
      }

      CategoryEntry? bestForYouCategory;
      if (bestForYou != null) {
        for (final c in categories) {
          if (c.id == bestForYou.categoryId) {
            bestForYouCategory = c;
            break;
          }
        }
      }

      // "Up next" — all books excluding continue-reading + best-for-you
      final excludedIds = <String>{
        if (currentBook != null) currentBook.id,
        if (bestForYou != null) bestForYou.id,
      };
      final upNext = allBooks
          .where((b) => !excludedIds.contains(b.id))
          .take(8)
          .toList();

      String displayName = '';
      if (userProfile != null) {
        displayName = (userProfile['display_name'] as String?) ?? '';
      }

      if (!mounted) return;
      setState(() {
        _displayName = displayName;
        _currentProgress = progress;
        _currentBook = currentBook;
        _currentCheckpoint = currentCheckpoint;
        _totalCheckpoints = totalCheckpoints;
        _bestForYou = bestForYou;
        _bestForYouCategory = bestForYouCategory;
        _upNext = upNext;
        _categories = categories;
        _streakDays = streakDays;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<int> _getStreakDays() async {
    final db = await DatabaseHelper.instance.database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM streak_records');
    return (result.first['count'] as int?) ?? 0;
  }

  void _navigateToBookDetail(BookEntry book) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => BookDetailScreen(bookId: book.id),
      ),
    )
        .then((_) => _loadData());
  }

  void _navigateToReader() {
    final book = _currentBook;
    if (book == null) return;
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => BookReaderFlow(bookId: book.id),
      ),
    )
        .then((_) => _loadData());
  }

  void _navigateToCategoryDetail(CategoryEntry category) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => CategoryDetailScreen(
          categoryId: category.id,
          categoryTitle: category.title,
          categoryDescription: category.description,
          themeColor: BookVisuals.categoryAccent(category.id),
        ),
      ),
    )
        .then((_) => _loadData());
  }

  void _openLibrary() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LibraryScreen()),
    );
  }

  String _dayOfWeek() {
    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    return days[DateTime.now().weekday - 1];
  }

  String _categoryLabel(String id) {
    for (final c in _categories) {
      if (c.id == id) return c.title;
    }
    return id.replaceAll('_', ' ');
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

    final greeting = _displayName.trim().isNotEmpty
        ? 'Welcome back, ${_displayName.trim()}'
        : 'Welcome back';

    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            // ===== Top bar =====
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dayOfWeek(),
                        style: AppTypography.eyebrow,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        greeting,
                        style: AppTypography.tileHeading,
                      ),
                    ],
                  ),
                ),
                _StreakPill(days: _streakDays),
              ],
            ),
            const SizedBox(height: 28),

            // ===== Continue Reading =====
            if (_currentProgress != null && _currentBook != null) ...[
              _ContinueReadingCard(
                book: _currentBook!,
                checkpoint: _currentCheckpoint,
                total: _totalCheckpoints,
                done: _currentProgress!.completedCheckpointIds.length,
                onTap: _navigateToReader,
                categoryLabel: _categoryLabel(_currentBook!.categoryId),
              ),
              const SizedBox(height: 28),
            ],

            // ===== Best for you =====
            if (_bestForYou != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Best for you',
                      style: AppTypography.titleLarge,
                    ),
                  ),
                  Text(
                    'TAILORED',
                    style: AppTypography.eyebrow.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _BestForYouCard(
                book: _bestForYou!,
                category: _bestForYouCategory,
                onTap: () => _navigateToBookDetail(_bestForYou!),
              ),
              const SizedBox(height: 28),
            ],

            // ===== Up next =====
            if (_upNext.isNotEmpty) ...[
              Text('Up next', style: AppTypography.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Based on your current spine',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 290,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: _upNext.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final book = _upNext[index];
                    final palette = BookVisuals.forBook(
                      book.id,
                      categoryId: book.categoryId,
                    );
                    return SizedBox(
                      width: 130,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BookCover(
                            title: book.title,
                            author: book.author,
                            category: _categoryLabel(book.categoryId),
                            palette: palette,
                            width: 130,
                            height: 195,
                            onTap: () => _navigateToBookDetail(book),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            book.title,
                            style: AppTypography.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${book.estimatedMinutes} min · ${book.difficulty.toLowerCase()}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
            ],

            // ===== Categories grid =====
            if (_categories.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text('Categories', style: AppTypography.titleLarge),
                  ),
                  GestureDetector(
                    onTap: _openLibrary,
                    child: Text(
                      'See all →',
                      style: AppTypography.link,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _CategoriesGrid(
                categories: _categories.take(4).toList(),
                onTap: _navigateToCategoryDetail,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0x14FF7A36),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.flame.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.flame,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$days',
            style: AppTypography.captionBold.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({
    required this.book,
    required this.checkpoint,
    required this.total,
    required this.done,
    required this.onTap,
    required this.categoryLabel,
  });

  final BookEntry book;
  final CheckpointEntry? checkpoint;
  final int total;
  final int done;
  final VoidCallback onTap;
  final String categoryLabel;

  @override
  Widget build(BuildContext context) {
    final palette = BookVisuals.forBook(book.id, categoryId: book.categoryId);
    final accent = palette.accent;
    final currentIndex = done < total ? done + 1 : total;
    final cpTitle = checkpoint?.title ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              palette.bg,
              AppColors.surfaceCard,
            ],
          ),
          border: Border.all(
            color: accent.withValues(alpha: 0.30),
            width: 0.5,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -60,
              right: -60,
              child: IgnorePointer(
                child: RadialGlow(color: accent, size: 220, opacity: 0.35),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(
                  title: book.title,
                  author: book.author,
                  category: categoryLabel,
                  palette: palette,
                  width: 90,
                  height: 135,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONTINUE',
                        style: AppTypography.eyebrow.copyWith(color: accent),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        book.title,
                        style: AppTypography.subHeading,
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
                      const SizedBox(height: 14),
                      Text(
                        'Checkpoint $currentIndex of $total${cpTitle.isNotEmpty ? "  ·  $cpTitle" : ""}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      ProgressRail(
                        total: total == 0 ? 1 : total,
                        done: done,
                        accent: accent,
                        vertical: false,
                        thickness: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BestForYouCard extends StatelessWidget {
  const _BestForYouCard({
    required this.book,
    required this.category,
    required this.onTap,
  });

  final BookEntry book;
  final CategoryEntry? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = BookVisuals.forBook(book.id, categoryId: book.categoryId);
    final catAccent = BookVisuals.categoryAccent(book.categoryId);
    final catLabel = category?.title ?? book.categoryId.replaceAll('_', ' ');
    final hook = book.introHook ?? book.shortDescription ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(
              title: book.title,
              author: book.author,
              category: catLabel,
              palette: palette,
              width: 96,
              height: 144,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    catLabel.toUpperCase(),
                    style: AppTypography.eyebrow.copyWith(color: catAccent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    style: AppTypography.subHeading,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hook.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      hook,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    '${book.estimatedMinutes} min · ${_checkpointCount(book)} checkpoints',
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

  int _checkpointCount(BookEntry book) => 6;
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({required this.categories, required this.onTap});

  final List<CategoryEntry> categories;
  final void Function(CategoryEntry) onTap;

  static const List<String> _glyphs = ['◐', '◈', '✦', '❋'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(categories.length, (i) {
            final cat = categories[i];
            final accent = BookVisuals.categoryAccent(cat.id);
            final glyph = _glyphs[i % _glyphs.length];
            return SizedBox(
              width: tileWidth,
              child: _CategoryTile(
                category: cat,
                accent: accent,
                glyph: glyph,
                onTap: () => onTap(cat),
              ),
            );
          }),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.accent,
    required this.glyph,
    required this.onTap,
  });

  final CategoryEntry category;
  final Color accent;
  final String glyph;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 124,
        padding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: const Alignment(-0.6, -1.0),
            end: const Alignment(0.6, 1.0),
            colors: [
              accent.withValues(alpha: 0.18 / 1),
              const Color(0x05FFFFFF),
            ],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.22)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: IgnorePointer(
                child: RadialGlow(color: accent, size: 140, opacity: 0.25),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      glyph,
                      style: AppTypography.tileHeading.copyWith(
                        color: accent,
                        shadows: [
                          Shadow(
                            color: accent.withValues(alpha: 0.6),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'CATEGORY',
                      style: AppTypography.eyebrow.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: AppTypography.titleMedium.copyWith(fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.description,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
