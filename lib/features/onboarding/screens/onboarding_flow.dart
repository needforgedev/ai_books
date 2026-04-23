import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/book_cover.dart';
import 'package:ai_books/features/onboarding/screens/welcome_screen.dart';
import 'package:ai_books/features/onboarding/screens/name_input_screen.dart';
import 'package:ai_books/features/onboarding/screens/onboarding_question_screen.dart';
import 'package:ai_books/features/onboarding/screens/recommendation_screen.dart';
import 'package:ai_books/domain/models/book_entry.dart';
import 'package:ai_books/domain/services/recommendation_service.dart';
import 'package:ai_books/app/main_shell.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    super.key,
    required this.onOnboardingComplete,
  });

  final void Function(Map<String, dynamic> data) onOnboardingComplete;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 4 questions (Name, Interests, Goals, Comfort) + welcome + recommendation
  static const int _questionSteps = 4;

  // Collected data
  String _displayName = '';
  List<String> _interests = [];
  List<String> _goals = [];
  String _readingComfort = '';

  // Recommendation results
  BookEntry? _recommendedBook;
  List<BookEntry> _alternateBooks = [];
  String _reasonText = '';

  static const List<String> _interestOptions = [
    'Philosophy',
    'Psychology',
    'Self Growth',
    'Business',
    'Science',
    'History',
    'Spirituality',
    'Sci-Fi',
    'Sociology',
    'Mindfulness',
  ];

  static const List<String> _goalOptions = [
    'Build discipline',
    'Reduce overthinking',
    'Understand people',
    'Find purpose',
    'Improve mindset',
    'Think more clearly',
    'Get richer',
    'Feel calmer',
  ];

  static const List<String> _comfortOptions = [
    'Beginner',
    'Moderate',
    'Advanced',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() => _goToPage(_currentPage + 1);
  void _previousPage() {
    if (_currentPage > 0) _goToPage(_currentPage - 1);
  }

  Map<String, dynamic> _collectData() {
    return {
      'displayName': _displayName,
      'interests': _interests,
      'goals': _goals,
      // Keep keys for downstream compatibility
      'improvements': <String>[],
      'readingComfort': _readingComfort,
      'dailyMinutes': 0,
      'streakDays': 0,
    };
  }

  Future<void> _runRecommendationAndAdvance() async {
    final result = await RecommendationService.getRecommendations(
      interests: _interests,
      goals: _goals,
      improvements: const [],
      readingComfort: _readingComfort,
    );
    if (!mounted) return;
    setState(() {
      _recommendedBook = result['primary'] as BookEntry;
      _alternateBooks =
          List<BookEntry>.from(result['alternates'] as List);
      _reasonText = result['reason'] as String;
    });
    _nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          // 0: Welcome
          OnboardingWelcomeScreen(onGetStarted: _nextPage),

          // 1: Name input
          NameInputScreen(
            step: 1,
            totalSteps: _questionSteps,
            initial: _displayName,
            onBack: _previousPage,
            onNext: (name) {
              _displayName = name;
              _nextPage();
            },
          ),

          // 2: Interests (multi)
          OnboardingQuestionScreen(
            step: 2,
            totalSteps: _questionSteps,
            eyebrow: 'WHAT PULLS YOU IN',
            title: 'Which ideas do you keep coming back to?',
            options: _interestOptions,
            multi: true,
            initial: _interests,
            onBack: _previousPage,
            onNext: (selected) {
              _interests = selected;
              _nextPage();
            },
          ),

          // 3: Goals (multi)
          OnboardingQuestionScreen(
            step: 3,
            totalSteps: _questionSteps,
            eyebrow: 'WHAT WOULD MOVE THE NEEDLE',
            title: 'What do you want this year to change?',
            options: _goalOptions,
            multi: true,
            initial: _goals,
            onBack: _previousPage,
            onNext: (selected) {
              _goals = selected;
              _nextPage();
            },
          ),

          // 4: Reading comfort (single)
          OnboardingQuestionScreen(
            step: 4,
            totalSteps: _questionSteps,
            eyebrow: 'HOW YOU READ',
            title: 'Where are you on the reading spectrum?',
            options: _comfortOptions,
            multi: false,
            initial: _readingComfort.isEmpty ? const [] : [_readingComfort],
            onBack: _previousPage,
            onNext: (selected) async {
              _readingComfort = selected.isNotEmpty ? selected.first : '';
              await _runRecommendationAndAdvance();
            },
          ),

          // 5: Recommendation
          RecommendationScreen(
            book: _recommendedBook,
            reasonText: _reasonText,
            alternateCount: _alternateBooks.length,
            onStartReading: () {
              widget.onOnboardingComplete(_collectData());
            },
            onSeeOtherPicks: _showAlternates,
            onExplore: _onExploreLibrary,
          ),
        ],
      ),
    );
  }

  Future<void> _showAlternates() async {
    if (_alternateBooks.isEmpty) return;
    final picked = await showModalBottomSheet<BookEntry>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      isScrollControlled: true,
      builder: (_) => _AlternatePicksSheet(alternates: _alternateBooks),
    );
    if (picked != null && mounted) {
      setState(() {
        // Move current primary into alternates, promote picked to primary.
        final newAlternates = _alternateBooks
            .where((b) => b.id != picked.id)
            .toList();
        if (_recommendedBook != null) {
          newAlternates.insert(0, _recommendedBook!);
        }
        _recommendedBook = picked;
        _alternateBooks = newAlternates.take(2).toList();
      });
    }
  }

  /// Fired when the engine returned no primary book and the user taps
  /// "Explore library" — we complete onboarding anyway so the main shell
  /// opens, then MainShell routes the user to the Library tab.
  void _onExploreLibrary() {
    widget.onOnboardingComplete(_collectData());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      MainShell.goToTab(context, tab: MainShellTabs.library);
    });
  }
}

/// Bottom-sheet picker for alternate recommendations.
class _AlternatePicksSheet extends StatelessWidget {
  const _AlternatePicksSheet({required this.alternates});

  final List<BookEntry> alternates;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF101014),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Other picks for you',
            style: AppTypography.titleLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap one to make it your starter book.',
            style: AppTypography.caption.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 18),
          for (final book in alternates)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AlternateRow(
                book: book,
                onTap: () => Navigator.of(context).pop(book),
              ),
            ),
        ],
      ),
    );
  }
}

class _AlternateRow extends StatelessWidget {
  const _AlternateRow({required this.book, required this.onTap});

  final BookEntry book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = BookVisuals.forBook(book.id, categoryId: book.categoryId);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            BookCover(
              title: book.title,
              author: book.author,
              category: book.categoryId.replaceAll('_', ' '),
              palette: palette,
              width: 62,
              height: 94,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppTypography.titleMedium.copyWith(fontSize: 17),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.author,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '${book.estimatedMinutes} min',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '·',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        book.difficulty,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: palette.accent,
            ),
          ],
        ),
      ),
    );
  }
}
