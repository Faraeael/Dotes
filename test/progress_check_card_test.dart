import 'package:dotes/src/features/progress/domain/models/focus_follow_through_check.dart';
import 'package:dotes/src/features/progress/domain/models/progress_check.dart';
import 'package:dotes/src/features/progress/presentation/widgets/progress_check_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgressCheckCard', () {
    testWidgets('shows the no-checkpoint fallback without checkpoint context', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgressCheckCard(
              progressCheck: const ProgressCheck.tooSmall(
                fallbackMessage:
                    'Need at least 10 recent matches before this progress check becomes useful.',
              ),
              followThroughCheck: const FocusFollowThroughCheck.waiting(
                fallbackMessage: 'No previous coaching checkpoint yet.',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Since last checkpoint'), findsOneWidget);
      expect(
        find.text('No previous coaching checkpoint yet.'),
        findsOneWidget,
      );
      expect(find.textContaining('Previous focus:'), findsNothing);
    });

    testWidgets('shows checkpoint explanation context when available', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgressCheckCard(
              progressCheck: const ProgressCheck.ready(
                blockSize: 5,
                comparisons: [],
              ),
              followThroughCheck: FocusFollowThroughCheck.ready(
                status: FocusFollowThroughStatus.onTrack,
                detail: 'Average deaths are down since the last checkpoint.',
                checkpointSavedAt: DateTime.utc(2025, 3, 21, 6, 30),
                previousFocusLabel: 'Early death risk',
                comparisonLabel:
                    'Compared against your last saved focus on reducing deaths.',
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('Saved '), findsOneWidget);
      expect(find.text('Previous focus: Early death risk'), findsOneWidget);
      expect(
        find.text(
          'Compared against your last saved focus on reducing deaths.',
        ),
        findsOneWidget,
      );
    });
  });
}
