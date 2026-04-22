import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_books/core/widgets/progress_rail.dart';
import 'package:ai_books/app/theme/app_colors.dart';

void main() {
  testWidgets('ProgressRail renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.surface,
          body: Center(
            child: ProgressRail(total: 6, done: 3),
          ),
        ),
      ),
    );

    expect(find.byType(ProgressRail), findsOneWidget);
  });
}
