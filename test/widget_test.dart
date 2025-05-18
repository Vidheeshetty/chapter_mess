
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chapter_mess/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChapterApp());

    // Verify that our splash screen starts initially.
    expect(find.text('Connect with people who matter'), findsOneWidget);
  });
}