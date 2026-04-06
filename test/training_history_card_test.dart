import 'package:dotes/src/features/checkpoints/domain/models/checkpoint_save_status_summary.dart';
import 'package:dotes/src/features/dashboard/domain/models/training_history.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/training_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrainingHistoryCard', () {
    testWidgets('shows the checkpoint save status summary when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrainingHistoryCard(
              history: const TrainingHistory(
                entries: [],
                fallbackMessage:
                    'No completed cycles yet \u2014 finish your first 5-game block to see history here.',
                trend: TrainingHistoryTrend(
                  headline: 'No completed cycles yet',
                  detail:
                      'Finish your first full 5-game review cycle to start a long-term trend read.',
                  completedCycles: 0,
                  onTrackCount: 0,
                  mixedCount: 0,
                  offTrackCount: 0,
                  currentStreakCount: 0,
                  currentStreakOutcome: null,
                ),
              ),
              checkpointSaveStatusSummary: const CheckpointSaveStatusSummary(
                headline: 'No new matches since the last checkpoint.',
                detail:
                    'History updates only when the block is meaningfully new.',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Training history'), findsOneWidget);
      expect(find.text('No completed cycles yet'), findsOneWidget);
      expect(
        find.text('No new matches since the last checkpoint.'),
        findsOneWidget,
      );
      expect(
        find.text('History updates only when the block is meaningfully new.'),
        findsOneWidget,
      );
    });

    testWidgets('does not show a checkpoint status summary when absent', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrainingHistoryCard(
              history: const TrainingHistory(
                entries: [],
                fallbackMessage:
                    'No completed cycles yet \u2014 finish your first 5-game block to see history here.',
                trend: TrainingHistoryTrend(
                  headline: 'No completed cycles yet',
                  detail:
                      'Finish your first full 5-game review cycle to start a long-term trend read.',
                  completedCycles: 0,
                  onTrackCount: 0,
                  mixedCount: 0,
                  offTrackCount: 0,
                  currentStreakCount: 0,
                  currentStreakOutcome: null,
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('No new matches since the last checkpoint.'),
        findsNothing,
      );
    });
  });
}
