import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'package:ai_books/features/onboarding/screens/onboarding_flow.dart';
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

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    await DatabaseHelper.instance.database;
    final completed = await DatabaseHelper.instance.isOnboardingComplete();
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
      title: 'AI Books',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _isLoading
          ? const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.white24,
                ),
              ),
            )
          : _hasCompletedOnboarding
              ? const MainShell()
              : OnboardingFlow(onOnboardingComplete: _onOnboardingComplete),
    );
  }
}
