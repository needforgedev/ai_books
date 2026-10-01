import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/bookmark_service.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/domain/services/note_link_service.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  List<_LinkRow> _rows = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final links = await NoteLinkService.getAllLinks();
    if (links.isEmpty) {
      if (!mounted) return;
      setState(() {
        _rows = [];
        _isLoading = false;
      });
      return;
    }

    // Fetch all unique saved item ids
    final ids = <int>{};
    for (final l in links) {
      ids.add(l.fromSavedItemId);
      ids.add(l.toSavedItemId);
    }

    final db = await _savedItemsForIds(ids);
    final bookIds = db.values.map((i) => i.sourceBookId).toSet();
    final bookTitles = <String, String>{};
    for (final id in bookIds) {
      final book = await ContentService.getBook(id);
      if (book != null) bookTitles[id] = book.title;
    }

    final rows = links.map((link) {
      final from = db[link.fromSavedItemId];
      final to = db[link.toSavedItemId];
      if (from == null || to == null) return null;
      return _LinkRow(
        link: link,
        fromItem: from,
        toItem: to,
        fromBookTitle: bookTitles[from.sourceBookId] ?? 'Unknown',
        toBookTitle: bookTitles[to.sourceBookId] ?? 'Unknown',
      );
    }).whereType<_LinkRow>().toList();

    if (!mounted) return;
    setState(() {
      _rows = rows;
      _isLoading = false;
    });
  }

  Future<Map<int, SavedItem>> _savedItemsForIds(Set<int> ids) async {
    final all = await BookmarkService.getAllSaved();
    final map = <int, SavedItem>{};
    for (final item in all) {
      if (item.id != null && ids.contains(item.id)) {
        map[item.id!] = item;
      }
    }
    return map;
  }

  Future<void> _deleteLink(NoteLink link) async {
    if (link.id == null) return;
    await NoteLinkService.deleteLink(link.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hub_outlined,
              size: 56,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No connections yet',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Long-press a saved note to link it\nto another note.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      itemCount: _rows.length,
      itemBuilder: (_, i) => _LinkCard(
        row: _rows[i],
        onDelete: () => _deleteLink(_rows[i].link),
      ),
    );
  }
}

class _LinkRow {
  const _LinkRow({
    required this.link,
    required this.fromItem,
    required this.toItem,
    required this.fromBookTitle,
    required this.toBookTitle,
  });

  final NoteLink link;
  final SavedItem fromItem;
  final SavedItem toItem;
  final String fromBookTitle;
  final String toBookTitle;
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.row, required this.onDelete});

  final _LinkRow row;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          _NoteSnippet(
            text: row.fromItem.savedText ?? '',
            bookTitle: row.fromBookTitle,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const _ConnectorLine(),
                if (row.link.label != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      row.link.label!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.link_off_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _NoteSnippet(
            text: row.toItem.savedText ?? '',
            bookTitle: row.toBookTitle,
            isBottom: true,
          ),
        ],
      ),
    );
  }
}

class _NoteSnippet extends StatelessWidget {
  const _NoteSnippet({
    required this.text,
    required this.bookTitle,
    this.isBottom = false,
  });

  final String text;
  final String bookTitle;
  final bool isBottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.vertical(
          top: isBottom ? Radius.zero : const Radius.circular(16),
          bottom: isBottom ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bookTitle,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectorLine extends StatelessWidget {
  const _ConnectorLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 1,
          height: 20,
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.link_rounded,
          size: 14,
          color: AppColors.primary.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}
