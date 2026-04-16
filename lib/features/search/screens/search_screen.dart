import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/ai_book_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Books';
  bool _hasQuery = false;

  static const List<String> _filters = [
    'Books',
    'Authors',
    'Categories',
    'Goals',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final hasText = _searchController.text.isNotEmpty;
      if (hasText != _hasQuery) {
        setState(() => _hasQuery = hasText);
      }
    });
  }

  @override
  void dispose() {
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
    final results = [
      _BookResult(
        title: 'Thinking, Fast and Slow',
        author: 'Daniel Kahneman',
        color: AppColors.scienceColor,
        difficulty: 'Intermediate',
        minutes: 18,
      ),
      _BookResult(
        title: 'Atomic Habits',
        author: 'James Clear',
        color: AppColors.personalDevColor,
        difficulty: 'Beginner',
        minutes: 12,
      ),
      _BookResult(
        title: 'The Lean Startup',
        author: 'Eric Ries',
        color: AppColors.businessColor,
        difficulty: 'Beginner',
        minutes: 15,
      ),
      _BookResult(
        title: 'Sapiens',
        author: 'Yuval Noah Harari',
        color: AppColors.scienceColor.withValues(alpha: 0.7),
        difficulty: 'Intermediate',
        minutes: 20,
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = results[index];
        return AiBookCard(
          title: book.title,
          author: book.author,
          coverColor: book.color,
          difficulty: book.difficulty,
          estimatedMinutes: book.minutes,
          onTap: () {},
        );
      },
    );
  }
}

class _BookResult {
  const _BookResult({
    required this.title,
    required this.author,
    required this.color,
    required this.difficulty,
    required this.minutes,
  });

  final String title;
  final String author;
  final Color color;
  final String difficulty;
  final int minutes;
}
