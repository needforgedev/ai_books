import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/features/onboarding/screens/welcome_screen.dart';
import 'package:ai_books/features/onboarding/screens/interests_screen.dart';
import 'package:ai_books/features/onboarding/screens/goals_screen.dart';
import 'package:ai_books/features/onboarding/screens/improve_screen.dart';
import 'package:ai_books/features/onboarding/screens/reading_comfort_screen.dart';
import 'package:ai_books/features/onboarding/screens/daily_time_screen.dart';
import 'package:ai_books/features/onboarding/screens/streak_screen.dart';
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
  static const int _totalPages = 8;

  // Collected data
  List<String> _interests = [];
  List<String> _goals = [];
  List<String> _improvements = [];
  String _readingComfort = '';
  int _dailyMinutes = 0;
  int _streakDays = 0;

  // Recommendation results
  BookEntry? _recommendedBook;
  // ignore: unused_field
  List<BookEntry> _alternateBooks = [];
  String _reasonText = '';

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

  void _nextPage() {
    _goToPage(_currentPage + 1);
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  Map<String, dynamic> _collectData() {
    return {
      'interests': _interests,
      'goals': _goals,
      'improvements': _improvements,
      'readingComfort': _readingComfort,
      'dailyMinutes': _dailyMinutes,
      'streakDays': _streakDays,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              // 0: Welcome
              OnboardingWelcomeScreen(
                onGetStarted: _nextPage,
              ),
              // 1: Interests
              InterestsScreen(
                onNext: (selected) {
                  _interests = selected;
                  _nextPage();
                },
              ),
              // 2: Goals
              GoalsScreen(
                onNext: (selected) {
                  _goals = selected;
                  _nextPage();
                },
              ),
              // 3: Improve
              ImproveScreen(
                onNext: (selected) {
                  _improvements = selected;
                  _nextPage();
                },
              ),
              // 4: Reading Comfort
              ReadingComfortScreen(
                onNext: (selected) {
                  _readingComfort = selected;
                  _nextPage();
                },
              ),
              // 5: Daily Time
              DailyTimeScreen(
                onNext: (minutes) {
                  _dailyMinutes = minutes;
                  _nextPage();
                },
              ),
              // 6: Streak
              StreakScreen(
                onNext: (days) async {
                  _streakDays = days;
                  // Run recommendation engine before showing the result
                  final result =
                      await RecommendationService.getRecommendations(
                    interests: _interests,
                    goals: _goals,
                    improvements: _improvements,
                    readingComfort: _readingComfort,
                  );
                  setState(() {
                    _recommendedBook = result['primary'] as BookEntry;
                    _alternateBooks =
                        List<BookEntry>.from(result['alternates'] as List);
                    _reasonText = result['reason'] as String;
                  });
                  _nextPage();
                },
              ),
              // 7: Recommendation
              RecommendationScreen(
                bookTitle: _recommendedBook?.title ?? 'Atomic Habits',
                bookAuthor: _recommendedBook?.author ?? 'James Clear',
                reasonText: _reasonText.isNotEmpty
                    ? _reasonText
                    : 'Because you picked Business + build discipline + beginner-friendly reading',
                onStartReading: () {
                  widget.onOnboardingComplete(_collectData());
                },
                onSeeOtherPicks: () {
                  // Placeholder — could open a bottom sheet or navigate
                },
              ),
            ],
          ),

          // Progress indicator (hidden on welcome screen)
          if (_currentPage > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: LinearProgressIndicator(
                      value: _currentPage / (_totalPages - 1),
                      minHeight: 2,
                      backgroundColor: AppColors.surfaceMuted,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Back button (hidden on welcome screen)
          if (_currentPage > 0)
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 20),
                  child: IconButton(
                    onPressed: _previousPage,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
