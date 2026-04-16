import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/ai_book_card.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/features/book_detail/screens/book_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Books';
  bool _hasQuery = false;
  List<BookEntry> _allBooks = [];
  List<BookEntry> _results = [];
  Map<String, CategoryEntry> _categoriesById = {};

  static const List<String> _filters = [
    'Books',
    'Authors',
    'Categories',
    'Goals',
  ];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadBooks() async {
    final books = await ContentService.getAllBooks();
    final categories = await ContentService.getCategories();
    final catMap = <String, CategoryEntry>{};
    for (final cat in categories) {
      catMap[cat.id] = cat;
    }
    if (!mounted) return;
    setState(() {
      _allBooks = books;
      _categoriesById = catMap;
    });
    _filterResults();
  }

  void _onSearchChanged() {
    final hasText = _searchController.text.isNotEmpty;
    if (hasText != _hasQuery) {
      setState(() => _hasQuery = hasText);
    }
    _filterResults();
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    final filtered = _allBooks.where((book) {
      switch (_selectedFilter) {
        case 'Authors':
          return book.author.toLowerCase().contains(query);
        case 'Categories':
          final cat = _categoriesById[book.categoryId];
          return cat != null &&
              cat.title.toLowerCase().contains(query);
        case 'Goals':
          return book.goalTags
              .any((tag) => tag.toLowerCase().contains(query));
        case 'Books':
        default:
          return book.title.toLowerCase().contains(query);
      }
    }).toList();

    setState(() => _results = filtered);
  }

  Color _coverColorForBook(BookEntry book) {
    final cat = _categoriesById[book.categoryId];
    if (cat != null) {
      // Parse hex color from category themeColor (e.g. "0xFF4A90D9")
      final colorValue = int.tryParse(cat.themeColor);
      if (colorValue != null) return Color(colorValue);
    }
    return AppColors.primary;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                controller: _searchController,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search books, authors, or topics',
                  hintStyle: AppTypography.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceInput,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Filter chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                      _filterResults();
                    },
                    labelStyle: AppTypography.caption.copyWith(
                      color: isSelected
                          ? AppColors.textOnPrimary
                          : AppColors.textSecondary,
                    ),
                    backgroundColor: AppColors.surfaceCard,
                    selectedColor: AppColors.primary,
                    checkmarkColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Results or empty state
            Expanded(
              child: _hasQuery ? _buildResults() : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_rounded,
            size: 56,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 12),
          Text(
            'Search for books, authors, or topics',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'No results found',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = _results[index];
        return AiBookCard(
          title: book.title,
          author: book.author,
          coverColor: _coverColorForBook(book),
          difficulty: book.difficulty,
          estimatedMinutes: book.estimatedMinutes,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookDetailScreen(bookId: book.id),
              ),
            );
          },
        );
      },
    );
  }
}
