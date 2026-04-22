import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/features/onboarding/screens/welcome_screen.dart';
import 'package:ai_books/features/onboarding/screens/name_input_screen.dart';
import 'package:ai_books/features/onboarding/screens/onboarding_question_screen.dart';
import 'package:ai_books/features/onboarding/screens/recommendation_screen.dart';
import 'package:ai_books/domain/models/book_entry.dart';
import 'package:ai_books/domain/services/recommendation_service.dart';

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
            onSeeOtherPicks: () {
              // Placeholder — could open a bottom sheet or navigate
            },
          ),
        ],
      ),
    );
  }
}
