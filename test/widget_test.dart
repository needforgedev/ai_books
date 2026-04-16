import 'package:flutter_test/flutter_test.dart';

import 'package:ai_books/app/app.dart';

void main() {
  testWidgets('App renders onboarding welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AiBooksApp());

    expect(find.text('GET STARTED'), findsOneWidget);
  });
}
