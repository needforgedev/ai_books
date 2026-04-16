import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/storage/database_helper.dart';
import 'package:ai_books/core/widgets/ai_book_card.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/domain/services/onboarding_service.dart';
import 'package:ai_books/domain/services/progress_service.dart';
import 'package:ai_books/features/book_detail/screens/book_detail_screen.dart';
import 'package:ai_books/features/home/widgets/continue_reading_card.dart';
import 'package:ai_books/features/library/screens/category_detail_screen.dart';

/// The main home screen with greeting, continue reading, recommendations,
/// and category chips.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  // User profile
  String _displayName = '';

  // Continue reading
  ReadingProgress? _currentProgress;
  BookEntry? _currentBook;
  int _totalCheckpoints = 0;

  // Recommended / featured books
  List<BookEntry> _featuredBooks = [];

  // Categories
  List<CategoryEntry> _categories = [];

  // Stats
  int _streakDays = 0;
  int _finishedBooks = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load all data in parallel
      final results = await Future.wait([
        OnboardingService.getUserProfile(), // 0
        ProgressService.getMostRecentProgress(), // 1
        ContentService.getFeaturedBooks(), // 2
        ContentService.getCategories(), // 3
        ProgressService.getFinishedBookCount(), // 4
        _getStreakDays(), // 5
      ]);

      final userProfile = results[0] as Map<String, dynamic>?;
      final progress = results[1] as ReadingProgress?;
      final featured = results[2] as List<BookEntry>;
      final categories = results[3] as List<CategoryEntry>;
      final finishedCount = results[4] as int;
      final streakDays = results[5] as int;

      // If no featured books, fall back to all books
      List<BookEntry> booksToShow = featured;
      if (booksToShow.isEmpty) {
        booksToShow = await ContentService.getAllBooks();
      }

      // Load continue-reading book details if progress exists
      BookEntry? currentBook;
      int totalCheckpoints = 0;
      if (progress != null) {
        final bookAndCheckpoints = await Future.wait([
          ContentService.getBook(progress.bookId),
          ContentService.getCheckpoints(progress.bookId),
        ]);
        currentBook = bookAndCheckpoints[0] as BookEntry?;
        final checkpoints = bookAndCheckpoints[1] as List<CheckpointEntry>;
        totalCheckpoints = checkpoints.length;
      }

      // Extract display name from profile
      String displayName = '';
      if (userProfile != null) {
        displayName =
            (userProfile['display_name'] as String?) ?? '';
      }

      if (!mounted) return;
      setState(() {
        _displayName = displayName;
        _currentProgress = progress;
        _currentBook = currentBook;
        _totalCheckpoints = totalCheckpoints;
        _featuredBooks = booksToShow;
        _categories = categories;
        _streakDays = streakDays;
        _finishedBooks = finishedCount;
        _isLoading = false;
      });
    } catch (e) {
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
    return result.first['count'] as int;
  }

  Color _parseThemeColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.accent;
    }
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
    if (_currentBook == null || _currentProgress == null) return;

    // Navigate to BookDetailScreen for now (BookReaderFlow not yet available)
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => BookDetailScreen(bookId: _currentBook!.id),
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
          themeColor: _parseThemeColor(category.themeColor),
        ),
      ),
    )
        .then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
          ),
        ),
      );
    }

    final greeting = _displayName.isNotEmpty
        ? 'HELLO ${_displayName.toUpperCase()}'
        : 'HELLO THERE !';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            // -- Header --
            Text(
              greeting,
              style: AppTypography.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatBadge(
                    label:
                        'Streak: $_streakDays day${_streakDays == 1 ? '' : 's'}'),
                const SizedBox(width: 8),
                _StatBadge(label: 'Books: $_finishedBooks'),
              ],
            ),
            const SizedBox(height: 24),

            // -- Continue Reading (only if in progress) --
            if (_currentProgress != null && _currentBook != null) ...[
              Text(
                'CONTINUE READING',
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ContinueReadingCard(
                bookTitle: _currentBook!.title,
                author: _currentBook!.author,
                currentCheckpoint:
                    _currentProgress!.completedCheckpointIds.length + 1,
                totalCheckpoints: _totalCheckpoints,
                progress: _currentProgress!.completionPercent,
                onTap: _navigateToReader,
              ),
              const SizedBox(height: 24),
            ],

            // -- Recommended For You --
            if (_featuredBooks.isNotEmpty) ...[
              Text(
                'RECOMMENDED',
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: _featuredBooks.length,
                  separatorBuilder: (context, i) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final book = _featuredBooks[index];
                    // Find category color for the book
                    Color coverColor = AppColors.accent;
                    for (final cat in _categories) {
                      if (cat.id == book.categoryId) {
                        coverColor = _parseThemeColor(cat.themeColor);
                        break;
                      }
                    }
                    return SizedBox(
                      width: 160,
                      child: AiBookCard(
                        title: book.title,
                        author: book.author,
                        coverColor: coverColor,
                        difficulty: book.difficulty,
                        estimatedMinutes: book.estimatedMinutes,
                        onTap: () => _navigateToBookDetail(book),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // -- Categories --
            if (_categories.isNotEmpty) ...[
              Text(
                'CATEGORIES',
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: _categories.length,
                  separatorBuilder: (context, i) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _CategoryChip(
                      label: category.title,
                      color: _parseThemeColor(category.themeColor),
                      onTap: () => _navigateToCategoryDetail(category),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small badge showing a stat (e.g. "Streak: 4 days").
class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Text(
        label,
        style: AppTypography.micro.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// A small colored chip representing a category.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.color,
    this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
