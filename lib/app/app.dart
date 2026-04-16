import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'package:ai_books/features/onboarding/screens/onboarding_flow.dart';
import 'package:ai_books/app/main_shell.dart';

class AiBooksApp extends StatefulWidget {
  const AiBooksApp({super.key});

  @override
  State<AiBooksApp> createState() => _AiBooksAppState();
}

class _AiBooksAppState extends State<AiBooksApp> {
  bool _hasCompletedOnboarding = false;

  void _onOnboardingComplete(Map<String, dynamic> data) {
    // TODO: Save onboarding data to SQLite
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
      home: _hasCompletedOnboarding
          ? const MainShell()
          : OnboardingFlow(onOnboardingComplete: _onOnboardingComplete),
    );
  }
}
