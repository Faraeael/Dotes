import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/checkpoints/domain/models/training_block_action.dart';
import 'package:dotes/src/features/checkpoints/domain/services/training_block_action_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TrainingBlockActionService();

  group('TrainingBlockActionService', () {
    test('starts a block when there is no active checkpoint yet', () {
      final control = service.build(
        activeCheckpoint: null,
        checkpointHistory: const [],
      );

      expect(control.actionType, TrainingBlockActionType.start);
      expect(control.blockStateLabel, 'No active block yet');
      expect(
        control.blockStateDetail,
        'Start the current session plan before you queue the next 5 games.',
      );
    });

    test('shows restart when an active checkpoint already exists', () {
      final control = service.build(
        activeCheckpoint: _checkpoint(savedAt: DateTime.utc(2025, 3, 21, 12)),
        checkpointHistory: const [],
      );

      expect(control.actionType, TrainingBlockActionType.restart);
      expect(control.blockStateLabel, 'Current block started on Mar 21, 2025');
      expect(
        control.blockStateDetail,
        'Restart only if you want to replace that start point with the current plan.',
      );
    });

    test('keeps the state calm when a recent save exists without an active block', () {
      final control = service.build(
        activeCheckpoint: null,
        checkpointHistory: [
          _checkpoint(savedAt: DateTime.utc(2025, 3, 22, 12)),
        ],
      );

      expect(control.actionType, TrainingBlockActionType.start);
      expect(control.blockStateLabel, 'No active block yet');
      expect(
        control.blockStateDetail,
        'Latest coaching state saved on Mar 22, 2025. Start a fresh 5-game block when you are ready to judge the next run.',
      );
    });
  });
}

CoachingCheckpoint _checkpoint({required DateTime savedAt}) {
  return CoachingCheckpoint(
    accountId: 86745912,
    savedAt: savedAt,
    focusAction: 'Focus action',
    focusSourceLabel: 'Focus source',
    topInsightType: null,
    sample: const CoachingCheckpointSample(
      matchesAnalyzed: 10,
      wins: 5,
      losses: 5,
      winRate: 0.5,
      uniqueHeroesPlayed: 4,
      averageDeaths: 5.5,
      likelyRoleSummaryLabel: 'Carry',
      roleEstimateStrengthLabel: 'Strong estimate',
      hasClearRoleEstimate: true,
      primaryRoleKey: 'carry',
    ),
  );
}
