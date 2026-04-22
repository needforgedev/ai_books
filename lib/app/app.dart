import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
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

  // Minimum splash duration so the wordmark always lands.
  static const _minSplashDuration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final start = DateTime.now();
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
    });
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
          : _hasCompletedOnboarding
              ? const MainShell()
              : OnboardingFlow(onOnboardingComplete: _onOnboardingComplete),
    );
  }
}
