import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_books/features/onboarding/screens/welcome_screen.dart';

void main() {
  testWidgets('Welcome screen renders GET STARTED button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingWelcomeScreen(onGetStarted: () {}),
      ),
    );

    expect(find.text('GET STARTED'), findsOneWidget);
  });
}
