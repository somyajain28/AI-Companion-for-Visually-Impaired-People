import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets(
    'AI Companion app loads',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const AICompanionApp(),
      );

      expect(
        find.text('AI Companion'),
        findsOneWidget,
      );
    },
  );
}
