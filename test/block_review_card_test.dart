import 'package:dotes/src/features/dashboard/domain/models/block_review.dart';
import 'package:dotes/src/features/dashboard/domain/models/end_block_summary.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/block_review_card.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/end_block_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BlockReviewCard labels', () {
    testWidgets('uses Adherence and Target result as tile labels', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BlockReviewCard(
                review: BlockReview(
                  blockStatus: BlockReviewStatus.completed,
                  gamesLogged: 5,
                  blockSize: 5,
                  adherence: BlockReviewAdherence.stayedInsideBlock,
                  targetResult: BlockReviewTargetResult.flat,
                  overallOutcome: BlockReviewOutcome.mixed,
                ),
              ),
            ),
          ),
        ),
      );

      // Adherence replaces the old "Discipline" label.
      expect(find.text('Adherence'), findsOneWidget);
      expect(find.text('Discipline'), findsNothing);

      // Target result replaces the old ambiguous "Target" label.
      expect(find.text('Target result'), findsOneWidget);
      expect(find.text('Target'), findsNothing);
    });

    testWidgets(
      'flat-but-clean case: shows Stayed in block, Flat, and Mixed badge',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: BlockReviewCard(
                  review: BlockReview(
                    blockStatus: BlockReviewStatus.completed,
                    gamesLogged: 5,
                    blockSize: 5,
                    adherence: BlockReviewAdherence.stayedInsideBlock,
                    targetResult: BlockReviewTargetResult.flat,
                    overallOutcome: BlockReviewOutcome.mixed,
                  ),
                ),
              ),
            ),
          ),
        );

        // Adherence value: followed the plan.
        expect(find.text('Stayed in block'), findsOneWidget);
        // Target result value: metric did not move.
        expect(find.text('Flat'), findsOneWidget);
        // Overall outcome: not on track because the metric is flat.
        expect(find.text('Mixed'), findsAtLeastNWidgets(1));
        // Must not claim on track when only adherence was clean.
        expect(find.text('On track'), findsNothing);
      },
    );

    testWidgets(
      'adherence-only win does not look like a performance win',
      (tester) async {
        // Player stayed in block but metric result is flat → overall is mixed.
        // The word "Improved" must not appear anywhere in the card.
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: BlockReviewCard(
                  review: BlockReview(
                    blockStatus: BlockReviewStatus.completed,
                    gamesLogged: 5,
                    blockSize: 5,
                    adherence: BlockReviewAdherence.stayedInsideBlock,
                    targetResult: BlockReviewTargetResult.flat,
                    overallOutcome: BlockReviewOutcome.mixed,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Improved'), findsNothing);
        expect(find.text('On track'), findsNothing);
      },
    );
  });

  group('EndBlockSummaryCard labels', () {
    testWidgets('uses Target result as tile label instead of Main target', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EndBlockSummaryCard(
                summary: EndBlockSummary(
                  outcome: BlockReviewOutcome.mixed,
                  mainTargetResult: 'Flat',
                  adherenceResult: 'Stayed in block',
                  takeaway:
                      'You followed the block cleanly, but there is no clear improvement yet.',
                  nextStepSuggestion: 'Run the same block again.',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Target result'), findsOneWidget);
      expect(find.text('Main target'), findsNothing);
    });

    testWidgets(
      'flat-but-clean end summary: takeaway does not contain "improved"',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EndBlockSummaryCard(
                  summary: EndBlockSummary(
                    outcome: BlockReviewOutcome.mixed,
                    mainTargetResult: 'Flat',
                    adherenceResult: 'Stayed in block',
                    takeaway:
                        'You followed the block cleanly, but there is no clear improvement yet.',
                    nextStepSuggestion: 'Run the same block again.',
                  ),
                ),
              ),
            ),
          ),
        );

        // The takeaway visible on screen must mention no clear improvement.
        expect(
          find.textContaining('no clear improvement'),
          findsOneWidget,
        );
        // The outcome tile and badge must show Mixed, not On track.
        expect(find.text('Mixed'), findsAtLeastNWidgets(1));
        expect(find.text('On track'), findsNothing);
      },
    );
  });
}
