import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/quiz_service.dart';

/// Bottom sheet that lets the user tap a word in their saved quote to
/// create a fill-in-the-blank quiz card.
class CreateQuizCardSheet extends StatefulWidget {
  const CreateQuizCardSheet({super.key, required this.item});

  final SavedItem item;

  static Future<bool> show(BuildContext context, SavedItem item) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateQuizCardSheet(item: item),
    );
    return created == true;
  }

  @override
  State<CreateQuizCardSheet> createState() => _CreateQuizCardSheetState();
}

class _CreateQuizCardSheetState extends State<CreateQuizCardSheet> {
  int? _selectedWordIndex;
  bool _saving = false;

  String get _text => widget.item.savedText ?? '';

  List<String> get _words => _text.split(' ');

  String get _preview {
    if (_selectedWordIndex == null) return _text;
    final words = List<String>.from(_words);
    words[_selectedWordIndex!] = '______';
    return words.join(' ');
  }

  int _wordOffset(int wordIndex) {
    final words = _words;
    int offset = 0;
    for (int i = 0; i < wordIndex; i++) {
      offset += words[i].length + 1; // +1 for space
    }
    return offset;
  }

  Future<void> _save() async {
    if (_selectedWordIndex == null || widget.item.id == null) return;
    setState(() => _saving = true);

    final words = _words;
    final word = words[_selectedWordIndex!];
    final start = _wordOffset(_selectedWordIndex!);

    await QuizService.createCard(
      savedItemId: widget.item.id!,
      fullText: _text,
      blankStart: start,
      blankLength: word.length,
      correctAnswer: word,
    );

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 20),
              Text('Make a quiz card', style: AppTypography.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Tap the word you want to blank out.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 20),
              // Word chips
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(_words.length, (i) {
                    final selected = _selectedWordIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedWordIndex = selected ? null : i;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          _words[i],
                          style: AppTypography.body.copyWith(
                            color: selected
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              if (_selectedWordIndex != null) ...[
                const SizedBox(height: 16),
                Text(
                  'PREVIEW',
                  style: AppTypography.eyebrow
                      .copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    _preview,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedWordIndex == null || _saving
                      ? null
                      : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.surfaceMuted,
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
                          _selectedWordIndex == null
                              ? 'Pick a word first'
                              : 'Save card',
                          style: AppTypography.button.copyWith(
                            color: _selectedWordIndex == null
                                ? AppColors.textTertiary
                                : AppColors.textOnPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
