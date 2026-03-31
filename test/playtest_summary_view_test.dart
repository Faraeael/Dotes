import 'package:dotes/src/features/tester_feedback/domain/models/playtest_summary.dart';
import 'package:dotes/src/features/tester_feedback/domain/models/tester_feedback.dart';
import 'package:dotes/src/features/tester_feedback/presentation/widgets/playtest_summary_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaytestSummaryView', () {
    testWidgets('multiple accounts shown correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaytestSummaryView(
              summary: const PlaytestSummary(
                activeFilter: null,
                clearCount: 1,
                somewhatClearCount: 1,
                confusingCount: 0,
                emptyMessage: 'No local playtest notes yet.',
                entries: [
                  PlaytestSummaryEntry(
                    accountId: 86745912,
                    playerLabel: 'Week 1 Player',
                    accountLabel: 'Account 86745912',
                    rating: TesterFeedbackRating.clear,
                    ratingLabel: 'Clear',
                    note: 'The session plan was easy to follow.',
                    savedAtLabel: '2026-03-31 08:30 UTC',
                  ),
                  PlaytestSummaryEntry(
                    accountId: 2222,
                    playerLabel: 'Second Tester',
                    accountLabel: 'Account 2222',
                    rating: TesterFeedbackRating.somewhatClear,
                    ratingLabel: 'Somewhat clear',
                    note: 'Verdict was helpful after a second read.',
                    savedAtLabel: null,
                  ),
                ],
              ),
              onFilterChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Week 1 Player'), findsOneWidget);
      expect(find.text('Account 86745912'), findsOneWidget);
      expect(find.text('Second Tester'), findsOneWidget);
      expect(find.text('Verdict was helpful after a second read.'), findsOneWidget);
    });

    testWidgets('empty-state fallback renders cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaytestSummaryView(
              summary: const PlaytestSummary(
                activeFilter: TesterFeedbackRating.confusing,
                clearCount: 0,
                somewhatClearCount: 0,
                confusingCount: 0,
                emptyMessage: 'No notes marked Confusing yet.',
                entries: [],
              ),
              onFilterChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('No notes marked Confusing yet.'), findsOneWidget);
      expect(find.text('Clear 0'), findsOneWidget);
      expect(find.text('Somewhat clear 0'), findsOneWidget);
      expect(find.text('Confusing 0'), findsOneWidget);
    });
  });
}
