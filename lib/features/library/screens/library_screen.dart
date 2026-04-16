import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/ai_category_card.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/features/library/screens/category_detail_screen.dart';

/// The library screen showing all available categories.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<CategoryEntry> _categories = [];
  Map<String, int> _bookCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await ContentService.getCategories();
    final counts = <String, int>{};
    for (final cat in categories) {
      counts[cat.id] = await ContentService.getBookCount(cat.id);
    }
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _bookCounts = counts;
      _isLoading = false;
    });
  }

  Color _parseHexColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'EXPLORE',
                style: AppTypography.sectionHeading,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _categories.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final color = _parseHexColor(cat.themeColor);
                          return AiCategoryCard(
                            title: cat.title,
                            description: cat.description,
                            themeColor: color,
                            bookCount: _bookCounts[cat.id] ?? 0,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryDetailScreen(
                                    categoryId: cat.id,
                                    categoryTitle: cat.title,
                                    categoryDescription: cat.description,
                                    themeColor: color,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
