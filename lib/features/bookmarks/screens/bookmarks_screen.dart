import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({
    super.key,
    this.showEmptyState = false,
  });

  final bool showEmptyState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: showEmptyState ? _buildEmptyState() : _buildContent(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_outline_rounded,
            size: 64,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16),
          Text(
            'No saved items yet',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('SAVED', style: AppTypography.sectionHeading),
          const SizedBox(height: 28),
          // Quotes section
          Text('QUOTES', style: AppTypography.label),
          const SizedBox(height: 12),
          const _QuoteCard(
            quote:
                'Nothing in life is as important as you think it is, '
                'while you are thinking about it.',
            source: 'Thinking, Fast and Slow',
          ),
          const SizedBox(height: 10),
          const _QuoteCard(
            quote:
                'The person who says he knows what he thinks but cannot '
                'express it usually does not know what he thinks.',
            source: 'The Art of Clear Thinking',
          ),
          const SizedBox(height: 10),
          const _QuoteCard(
            quote:
                'We are what we repeatedly do. Excellence, then, is not '
                'an act, but a habit.',
            source: 'Atomic Habits',
          ),
          const SizedBox(height: 32),
          // Bookmarks section
          Text('BOOKMARKS', style: AppTypography.label),
          const SizedBox(height: 12),
          const _BookmarkTile(
            bookName: 'Thinking, Fast and Slow',
            checkpointName: 'The Two Systems',
          ),
          const _BookmarkTile(
            bookName: 'Atomic Habits',
            checkpointName: 'The 1% Rule',
          ),
          const _BookmarkTile(
            bookName: 'The Art of Clear Thinking',
            checkpointName: 'Cognitive Biases Overview',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.source,
  });

  final String quote;
  final String source;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"$quote"',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            source,
            style: AppTypography.captionBold,
          ),
        ],
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  const _BookmarkTile({
    required this.bookName,
    required this.checkpointName,
  });

  final String bookName;
  final String checkpointName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bookmark_rounded,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookName,
                  style: AppTypography.bodyEmphasis,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  checkpointName,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
