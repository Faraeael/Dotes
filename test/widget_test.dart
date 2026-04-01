// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dotes/src/app/app.dart';

void main() {
  testWidgets('shows the player import screen on launch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: DotesApp()));

    expect(find.text('Account ID'), findsOneWidget);
    expect(find.text('Import account'), findsAtLeastNWidgets(2));
    expect(find.text('Import player'), findsOneWidget);
    expect(
      find.text(
        'First import: get the read and session plan. Later import: review the finished block.',
      ),
      findsOneWidget,
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect((appBar.title as Text).data, 'Import account');
  });
}
