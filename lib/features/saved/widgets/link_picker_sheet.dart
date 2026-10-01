import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/bookmark_service.dart';
import 'package:ai_books/domain/services/content_service.dart';
import 'package:ai_books/domain/services/note_link_service.dart';

const _kLabels = ['Same idea', 'Builds on', 'Contradicts', ''];

class LinkPickerSheet extends StatefulWidget {
  const LinkPickerSheet({super.key, required this.sourceItem});

  final SavedItem sourceItem;

  /// Returns true if a link was created.
  static Future<bool> show(BuildContext context, SavedItem item) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LinkPickerSheet(sourceItem: item),
    );
    return created == true;
  }

  @override
  State<LinkPickerSheet> createState() => _LinkPickerSheetState();
}

class _LinkPickerSheetState extends State<LinkPickerSheet> {
  List<SavedItem> _allItems = [];
  Map<String, String> _bookTitles = {};
  List<SavedItem> _filtered = [];
  SavedItem? _selected;
  String _label = '';
  bool _isLoading = true;
  bool _saving = false;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_filter);
  }

  @override
  void dispose() {
    _search.removeListener(_filter);
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final all = await BookmarkService.getAllSaved();
    // Exclude the source item itself
    final others =
        all.where((i) => i.id != widget.sourceItem.id && i.savedText != null && i.savedText!.isNotEmpty).toList();

    final bookIds = others.map((i) => i.sourceBookId).toSet();
    final titles = <String, String>{};
    for (final id in bookIds) {
      final book = await ContentService.getBook(id);
      if (book != null) titles[id] = book.title;
    }

    if (!mounted) return;
    setState(() {
      _allItems = others;
      _filtered = others;
      _bookTitles = titles;
      _isLoading = false;
    });
  }

  void _filter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = _allItems.where((i) {
        final text = (i.savedText ?? '').toLowerCase();
        final title = (_bookTitles[i.sourceBookId] ?? '').toLowerCase();
        return text.contains(q) || title.contains(q);
      }).toList();
    });
  }

  Future<void> _save() async {
    if (_selected == null ||
        widget.sourceItem.id == null ||
        _selected!.id == null) {
      return;
    }
    setState(() => _saving = true);
    await NoteLinkService.createLink(
      fromId: widget.sourceItem.id!,
      toId: _selected!.id!,
      label: _label.isEmpty ? null : _label,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Link to another note', style: AppTypography.titleLarge),
                  const SizedBox(height: 14),
                  // Search
                  TextField(
                    controller: _search,
                    style: AppTypography.body
                        .copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search notes…',
                      hintStyle: AppTypography.body
                          .copyWith(color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textTertiary, size: 20),
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // List
            Flexible(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : _filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No other notes found',
                              style: AppTypography.body.copyWith(
                                  color: AppColors.textTertiary),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          shrinkWrap: true,
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final item = _filtered[i];
                            final bookTitle =
                                _bookTitles[item.sourceBookId] ?? 'Unknown';
                            final isSelected = _selected?.id == item.id;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selected = isSelected ? null : item),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                          .withValues(alpha: 0.12)
                                      : AppColors.surfaceCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                            .withValues(alpha: 0.5)
                                        : AppColors.borderSubtle,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.savedText ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.body.copyWith(
                                        color: isSelected
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
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
                              ),
                            );
                          },
                        ),
            ),
            if (_selected != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RELATIONSHIP  (optional)',
                      style: AppTypography.eyebrow
                          .copyWith(color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: _kLabels.map((l) {
                        final label = l.isEmpty ? 'No label' : l;
                        final active = _label == l;
                        return GestureDetector(
                          onTap: () => setState(() => _label = l),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: active
                                    ? AppColors.primary
                                    : AppColors.borderSubtle,
                              ),
                            ),
                            child: Text(
                              label,
                              style: AppTypography.caption.copyWith(
                                color: active
                                    ? AppColors.textOnPrimary
                                    : AppColors.textSecondary,
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _selected == null || _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.surfaceMuted,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _selected == null ? 'Select a note first' : 'Link notes',
                          style: AppTypography.button.copyWith(
                            color: _selected == null
                                ? AppColors.textTertiary
                                : AppColors.textOnPrimary,
                          ),
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
