import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/ai_category_card.dart';

/// The library screen showing all available categories.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

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
                child: ListView(
                  children: [
                    AiCategoryCard(
                      title: 'Science',
                      description: 'Discover how the universe works',
                      themeColor: const Color(0xFF4A90D9),
                      bookCount: 5,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    AiCategoryCard(
                      title: 'Business',
                      description: 'Decisions, systems, execution',
                      themeColor: const Color(0xFF34C759),
                      bookCount: 4,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    AiCategoryCard(
                      title: 'Personal Development',
                      description: 'Grow your mindset and habits',
                      themeColor: const Color(0xFFFF9500),
                      bookCount: 6,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
