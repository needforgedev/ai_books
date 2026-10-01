import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/quiz_service.dart';

class QuizSessionScreen extends StatefulWidget {
  const QuizSessionScreen({super.key, required this.cards});

  final List<QuizCard> cards;

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  int _correct = 0;
  int _incorrect = 0;
  bool _revealed = false;
  bool? _wasCorrect;
  bool _sessionDone = false;
  int _earnedXP = 0;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late final AnimationController _feedbackAnim;
  late final Animation<double> _feedbackOpacity;

  QuizCard get _current => widget.cards[_index];

  @override
  void initState() {
    super.initState();
    _feedbackAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _feedbackOpacity = CurvedAnimation(
      parent: _feedbackAnim,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _feedbackAnim.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final input = _controller.text.trim().toLowerCase();
    final answer = _current.correctAnswer.trim().toLowerCase();
    final correct = input == answer;
    setState(() {
      _revealed = true;
      _wasCorrect = correct;
      if (correct) {
        _correct++;
      } else {
        _incorrect++;
      }
    });
    _feedbackAnim.forward(from: 0);
    QuizService.recordAttempt(_current.id!, correct);
    _focusNode.unfocus();
  }

  Future<void> _next() async {
    if (_index + 1 >= widget.cards.length) {
      final xp = await QuizService.logSession(
        cardsReviewed: widget.cards.length,
        cardsCorrect: _correct,
      );
      if (!mounted) return;
      setState(() {
        _earnedXP = xp;
        _sessionDone = true;
      });
      return;
    }
    setState(() {
      _index++;
      _revealed = false;
      _wasCorrect = null;
    });
    _controller.clear();
    _feedbackAnim.reset();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: _sessionDone ? _buildSummary() : _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    final card = _current;
    final feedbackColor =
        _wasCorrect == true ? AppColors.success : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_index + 1) / widget.cards.length,
                    backgroundColor: AppColors.surfaceMuted,
                    color: AppColors.primary,
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_index + 1}/${widget.cards.length}',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card with blank
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        size: 22,
                        color: AppColors.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        card.displayWithBlank,
                        style: AppTypography.displayItalic(18).copyWith(
                          color: AppColors.textPrimary,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Answer input
                if (!_revealed) ...[
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    style: AppTypography.body
                        .copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Type the missing word…',
                      hintStyle: AppTypography.body
                          .copyWith(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.borderSubtle),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) =>
                        _controller.text.trim().isNotEmpty ? _checkAnswer() : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _controller.text.trim().isNotEmpty
                          ? _checkAnswer
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.surfaceMuted,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Check',
                        style: AppTypography.button
                            .copyWith(color: AppColors.textOnPrimary),
                      ),
                    ),
                  ),
                ] else ...[
                  // Feedback panel
                  FadeTransition(
                    opacity: _feedbackOpacity,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: feedbackColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: feedbackColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _wasCorrect == true
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: feedbackColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _wasCorrect == true ? 'Correct!' : 'Not quite',
                                style: AppTypography.titleMedium.copyWith(
                                  color: feedbackColor,
                                ),
                              ),
                            ],
                          ),
                          if (_wasCorrect == false) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Answer: ${card.correctAnswer}',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _index + 1 >= widget.cards.length
                            ? 'See results'
                            : 'Next card',
                        style: AppTypography.button
                            .copyWith(color: AppColors.textOnPrimary),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final total = widget.cards.length;
    final pct = total == 0 ? 0 : (_correct / total * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text('Session complete', style: AppTypography.sectionHeading),
          const SizedBox(height: 8),
          Text(
            '$pct% accuracy',
            style: AppTypography.tileHeading.copyWith(
              fontSize: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SummaryStat(label: 'Correct', value: '$_correct', positive: true),
              const SizedBox(width: 16),
              _SummaryStat(
                  label: 'Wrong', value: '$_incorrect', positive: false),
              const SizedBox(width: 16),
              _SummaryStat(label: 'XP earned', value: '+$_earnedXP'),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Done',
                style: AppTypography.button
                    .copyWith(color: AppColors.textOnPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    this.positive,
  });

  final String label;
  final String value;
  final bool? positive;

  @override
  Widget build(BuildContext context) {
    final color = positive == null
        ? AppColors.primary
        : (positive! ? AppColors.success : AppColors.danger);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.tileHeading.copyWith(
              fontSize: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption
                .copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
