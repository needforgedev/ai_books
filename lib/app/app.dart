import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';
import 'package:ai_books/features/onboarding/screens/onboarding_flow.dart';
import 'package:ai_books/features/onboarding/screens/splash_screen.dart';
import 'package:ai_books/app/main_shell.dart';
import 'package:ai_books/core/storage/database_helper.dart';
import 'package:ai_books/domain/services/onboarding_service.dart';

class AiBooksApp extends StatefulWidget {
  const AiBooksApp({super.key});

  @override
  State<AiBooksApp> createState() => _AiBooksAppState();
}

class _AiBooksAppState extends State<AiBooksApp> {
  bool _hasCompletedOnboarding = false;
  bool _isLoading = true;
  Object? _initError;

  // Minimum splash duration so the wordmark always lands.
  static const _minSplashDuration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final start = DateTime.now();
    try {
      await DatabaseHelper.instance.database;
      final completed = await DatabaseHelper.instance.isOnboardingComplete();
      final elapsed = DateTime.now().difference(start);
      final remaining = _minSplashDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }
      if (!mounted) return;
      setState(() {
        _hasCompletedOnboarding = completed;
        _isLoading = false;
        _initError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _initError = e;
      });
    }
  }

  void _retryInit() {
    setState(() {
      _isLoading = true;
      _initError = null;
    });
    _initDatabase();
  }

  Future<void> _onOnboardingComplete(Map<String, dynamic> data) async {
    await OnboardingService.saveOnboardingData(data);
    setState(() {
      _hasCompletedOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speedread',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _isLoading
          ? const SplashScreen()
          : _initError != null
              ? _InitErrorScreen(error: _initError!, onRetry: _retryInit)
              : _hasCompletedOnboarding
                  ? const MainShell()
                  : OnboardingFlow(onOnboardingComplete: _onOnboardingComplete),
    );
  }
}

class _InitErrorScreen extends StatelessWidget {
  const _InitErrorScreen({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppColors.danger,
                size: 40,
              ),
              const SizedBox(height: 18),
              Text(
                "Speedread couldn't start",
                style: AppTypography.sectionHeading,
              ),
              const SizedBox(height: 10),
              Text(
                'Something went wrong while preparing your library. '
                "This usually clears up on a retry. If it doesn't, "
                'reinstalling the app will reset the local database.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text('Try again', style: AppTypography.button),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Error: $error',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
