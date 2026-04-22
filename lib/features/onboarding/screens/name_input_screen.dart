import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';

/// First onboarding step — ask for the user's name.
class NameInputScreen extends StatefulWidget {
  const NameInputScreen({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.initial,
    required this.onNext,
    this.onBack,
  });

  final int step;
  final int totalSteps;
  final String initial;
  final ValueChanged<String> onNext;
  final VoidCallback? onBack;

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
    _focusNode = FocusNode();
    _hasText = widget.initial.trim().isNotEmpty;
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) {
        setState(() => _hasText = has);
      }
    });
    // Auto-focus the field on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onNext(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // ===== Top bar =====
              Row(
                children: [
                  if (widget.onBack != null)
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0x0FFFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary,
                          size: 16,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  const SizedBox(width: 12),
                  // Progress segments
                  Expanded(
                    child: Row(
                      children: List.generate(widget.totalSteps, (i) {
                        final filled = i < widget.step;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 3,
                            decoration: BoxDecoration(
                              color: filled
                                  ? AppColors.primary
                                  : const Color(0x1AFFFFFF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.step}/${widget.totalSteps}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              // ===== Eyebrow + Title =====
              Text(
                'GETTING TO KNOW YOU',
                style: AppTypography.eyebrow.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 14),
              RichText(
                text: TextSpan(
                  style: AppTypography.tileHeading,
                  children: [
                    const TextSpan(text: "What's "),
                    TextSpan(
                      text: 'your',
                      style: AppTypography.displayItalic(28,
                          color: AppColors.primary),
                    ),
                    const TextSpan(text: ' name?'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We'll greet you on the home screen each time you open the app.",
                style: AppTypography.body.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 36),
              // ===== Name input =====
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x0AFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : const Color(0x1AFFFFFF),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  cursorColor: AppColors.primary,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Your name',
                    hintStyle: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.4,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 22,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // ===== CTA =====
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _hasText ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    disabledBackgroundColor: const Color(0x14FFFFFF),
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
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
