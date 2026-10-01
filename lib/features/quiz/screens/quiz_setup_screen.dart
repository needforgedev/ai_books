import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/domain/models/models.dart';
import 'package:ai_books/domain/services/quiz_service.dart';
import 'package:ai_books/features/quiz/screens/quiz_session_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  bool _isLoading = true;
  List<QuizCard> _dueCards = [];
  int _totalCards = 0;
  double _accuracy = 0;
  int _lifetimeXP = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final due = await QuizService.getDueCards();
    final total = await QuizService.getTotalCardCount();
    final acc = await QuizService.getAllTimeAccuracy();
    final xp = await QuizService.getLifetimeXP();
    if (!mounted) return;
    setState(() {
      _dueCards = due;
      _totalCards = total;
      _accuracy = acc;
      _lifetimeXP = xp;
      _isLoading = false;
    });
  }

  Future<void> _startSession() async {
    if (_dueCards.isEmpty) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => QuizSessionScreen(cards: _dueCards),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Quiz yourself', style: AppTypography.titleLarge),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StatsRow(
                  dueCount: _dueCards.length,
                  totalCards: _totalCards,
                  accuracy: _accuracy,
                  lifetimeXP: _lifetimeXP,
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStartButton(),
              ),
              if (_dueCards.isEmpty && _totalCards > 0) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'All cards reviewed. Come back later!',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final enabled = _dueCards.isNotEmpty;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? _startSession : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.surfaceMuted,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          enabled
              ? 'Start session  ·  ${_dueCards.length} card${_dueCards.length == 1 ? '' : 's'}'
              : 'No cards due right now',
          style: AppTypography.button.copyWith(
            color:
                enabled ? AppColors.textOnPrimary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.dueCount,
    required this.totalCards,
    required this.accuracy,
    required this.lifetimeXP,
  });

  final int dueCount;
  final int totalCards;
  final double accuracy;
  final int lifetimeXP;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(label: 'Due now', value: '$dueCount'),
        const SizedBox(width: 12),
        _StatBox(label: 'Total cards', value: '$totalCards'),
        const SizedBox(width: 12),
        _StatBox(
          label: 'Accuracy',
          value: totalCards == 0
              ? '—'
              : '${(accuracy * 100).round()}%',
        ),
        const SizedBox(width: 12),
        _StatBox(label: 'XP earned', value: '$lifetimeXP'),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.tileHeading.copyWith(
                fontSize: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
