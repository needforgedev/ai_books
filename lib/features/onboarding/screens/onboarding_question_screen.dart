import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

class OnboardingQuestionScreen extends StatefulWidget {
  const OnboardingQuestionScreen({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.eyebrow,
    required this.title,
    required this.options,
    required this.multi,
    required this.initial,
    required this.onNext,
    this.onBack,
  });

  final int step;
  final int totalSteps;
  final String eyebrow;
  final String title;
  final List<String> options;
  final bool multi;
  final List<String> initial;
  final void Function(List<String>) onNext;
  final VoidCallback? onBack;

  @override
  State<OnboardingQuestionScreen> createState() =>
      _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState extends State<OnboardingQuestionScreen> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial.toSet();
  }

  void _toggle(String option) {
    setState(() {
      if (widget.multi) {
        if (_selected.contains(option)) {
          _selected.remove(option);
        } else {
          _selected.add(option);
        }
      } else {
        _selected
          ..clear()
          ..add(option);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selected.isNotEmpty;
    final accent = AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Header row: back + progress + step count
              Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: widget.onBack,
                    enabled: widget.onBack != null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SegmentedProgress(
                      total: widget.totalSteps,
                      current: widget.step,
                      accent: accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.step}/${widget.totalSteps}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Body (scrollable)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.eyebrow.toUpperCase(),
                        style: AppTypography.eyebrow.copyWith(color: accent),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.title,
                        style: AppTypography.tileHeading,
                      ),
                      const SizedBox(height: 28),
                      if (widget.multi)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: widget.options.map((option) {
                            final selected = _selected.contains(option);
                            return _PillChip(
                              label: option,
                              selected: selected,
                              accent: accent,
                              onTap: () => _toggle(option),
                            );
                          }).toList(),
                        )
                      else
                        Column(
                          children: widget.options.map((option) {
                            final selected = _selected.contains(option);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _OptionCard(
                                label: option,
                                selected: selected,
                                accent: accent,
                                onTap: () => _toggle(option),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: hasSelection
                      ? () => widget.onNext(_selected.toList())
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: AppColors.textOnPrimary,
                    disabledBackgroundColor: const Color(0x1AFFFFFF),
                    disabledForegroundColor: AppColors.textMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Continue', style: AppTypography.buttonLarge),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0x0FFFFFFF),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? AppColors.textPrimary
              : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _SegmentedProgress extends StatelessWidget {
  const _SegmentedProgress({
    required this.total,
    required this.current,
    required this.accent,
  });

  final int total;
  final int current;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: Row(
        children: List.generate(total, (i) {
          final filled = i < current;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
              decoration: BoxDecoration(
                color: filled ? accent : const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? accent : const Color(0x0FFFFFFF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? accent : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(
            color: selected ? AppColors.textOnPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.12)
              : const Color(0x0FFFFFFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.titleLarge,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? accent : Colors.transparent,
                border: Border.all(
                  color: selected ? accent : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.textOnPrimary,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
