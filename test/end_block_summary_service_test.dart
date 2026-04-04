import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/dashboard/domain/models/block_review.dart';
import 'package:dotes/src/features/dashboard/domain/models/session_plan.dart';
import 'package:dotes/src/features/dashboard/domain/services/end_block_summary_service.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = EndBlockSummaryService();

  group('EndBlockSummaryService', () {
    test('completed on-track block returns summary', () {
      final summary = service.build(
        activeStartedCheckpoint: _startedCheckpoint(
          targetType: SessionPlanTargetType.deaths,
          heroBlockIds: const [28, 129],
        ),
        reviewedBlock: const BlockReview(
          blockStatus: BlockReviewStatus.completed,
          gamesLogged: 5,
          blockSize: 5,
          adherence: BlockReviewAdherence.stayedInsideBlock,
          targetResult: BlockReviewTargetResult.improved,
          overallOutcome: BlockReviewOutcome.onTrack,
        ),
        sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.deaths),
        followThrough: null,
      );

      expect(summary, isNotNull);
      expect(summary!.outcome, BlockReviewOutcome.onTrack);
      expect(summary.mainTargetResult, 'Improved');
      expect(summary.adherenceResult, 'Stayed in block');
      expect(
        summary.takeaway,
        'You stayed inside the block and deaths improved.',
      );
      expect(summary.nextStepSuggestion, 'Run the same block again.');
    });

    test('completed mixed block returns summary', () {
      final summary = service.build(
        activeStartedCheckpoint: _startedCheckpoint(
          targetType: SessionPlanTargetType.heroPool,
        ),
        reviewedBlock: const BlockReview(
          blockStatus: BlockReviewStatus.completed,
          gamesLogged: 5,
          blockSize: 5,
          adherence: BlockReviewAdherence.partialDrift,
          targetResult: BlockReviewTargetResult.flat,
          overallOutcome: BlockReviewOutcome.mixed,
        ),
        sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.heroPool),
        followThrough: null,
      );

      expect(summary, isNotNull);
      expect(summary!.outcome, BlockReviewOutcome.mixed);
      expect(summary.takeaway, 'The block finished, but the signal stayed mixed.');
    });

    test('completed off-track block returns summary', () {
      final summary = service.build(
        activeStartedCheckpoint: _startedCheckpoint(
          targetType: SessionPlanTargetType.comfortBlock,
          heroBlockIds: const [28, 129],
        ),
        reviewedBlock: const BlockReview(
          blockStatus: BlockReviewStatus.completed,
          gamesLogged: 5,
          blockSize: 5,
          adherence: BlockReviewAdherence.offBlock,
          targetResult: BlockReviewTargetResult.worse,
          overallOutcome: BlockReviewOutcome.offTrack,
        ),
        sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.comfortBlock),
        followThrough: null,
      );

      expect(summary, isNotNull);
      expect(summary!.outcome, BlockReviewOutcome.offTrack);
      expect(summary.takeaway, 'You drifted outside the planned hero block.');
    });

    test('incomplete block does not show summary', () {
      final summary = service.build(
        activeStartedCheckpoint: _startedCheckpoint(
          targetType: SessionPlanTargetType.heroPool,
        ),
        reviewedBlock: const BlockReview(
          blockStatus: BlockReviewStatus.inProgress,
          gamesLogged: 3,
          blockSize: 5,
          adherence: BlockReviewAdherence.partialDrift,
          targetResult: BlockReviewTargetResult.flat,
          overallOutcome: BlockReviewOutcome.mixed,
        ),
        sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.heroPool),
        followThrough: null,
      );

      expect(summary, isNull);
    });

    test(
      'good adherence with flat result: takeaway explains no improvement and next step keeps the block',
      () {
        final summary = service.build(
          activeStartedCheckpoint: _startedCheckpoint(
            targetType: SessionPlanTargetType.deaths,
            heroBlockIds: const [28, 129],
          ),
          reviewedBlock: const BlockReview(
            blockStatus: BlockReviewStatus.completed,
            gamesLogged: 5,
            blockSize: 5,
            adherence: BlockReviewAdherence.stayedInsideBlock,
            targetResult: BlockReviewTargetResult.flat,
            overallOutcome: BlockReviewOutcome.mixed,
          ),
          sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.deaths),
          followThrough: null,
        );

        expect(summary, isNotNull);
        expect(summary!.outcome, BlockReviewOutcome.mixed);
        expect(summary.adherenceResult, 'Stayed in block');
        expect(summary.mainTargetResult, 'Flat');
        expect(
          summary.takeaway,
          'You followed the block cleanly, but there is no clear improvement yet.',
        );
        // Player followed the plan so the right advice is to keep going.
        expect(summary.nextStepSuggestion, 'Run the same block again.');
      },
    );

    test(
      'good adherence with flat result: takeaway does not contain the word "improved"',
      () {
        final summary = service.build(
          activeStartedCheckpoint: _startedCheckpoint(
            targetType: SessionPlanTargetType.heroPool,
          ),
          reviewedBlock: const BlockReview(
            blockStatus: BlockReviewStatus.completed,
            gamesLogged: 5,
            blockSize: 5,
            adherence: BlockReviewAdherence.stayedInsideBlock,
            targetResult: BlockReviewTargetResult.flat,
            overallOutcome: BlockReviewOutcome.mixed,
          ),
          sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.heroPool),
          followThrough: null,
        );

        expect(summary, isNotNull);
        expect(
          summary!.takeaway.toLowerCase(),
          isNot(contains('improved')),
          reason: 'should not claim improvement when target result is flat',
        );
      },
    );

    test(
      'poor adherence with improved result: takeaway reflects drift, not improvement',
      () {
        final summary = service.build(
          activeStartedCheckpoint: _startedCheckpoint(
            targetType: SessionPlanTargetType.deaths,
            heroBlockIds: const [28, 129],
          ),
          reviewedBlock: const BlockReview(
            blockStatus: BlockReviewStatus.completed,
            gamesLogged: 5,
            blockSize: 5,
            adherence: BlockReviewAdherence.offBlock,
            targetResult: BlockReviewTargetResult.improved,
            overallOutcome: BlockReviewOutcome.mixed,
          ),
          sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.deaths),
          followThrough: null,
        );

        expect(summary, isNotNull);
        // Drift wording takes priority over the improved metric result.
        expect(
          summary!.takeaway,
          'You drifted outside the planned hero block.',
        );
        expect(
          summary.takeaway.toLowerCase(),
          isNot(contains('improved')),
          reason:
              'should not claim improvement when adherence was off block',
        );
      },
    );

    test('next-step suggestion mapping is deterministic', () {
      final started = _startedCheckpoint(
        targetType: SessionPlanTargetType.heroPool,
        heroBlockIds: const [28, 129],
      );

      final onTrack = service.build(
        activeStartedCheckpoint: started,
        reviewedBlock: const BlockReview(
          blockStatus: BlockReviewStatus.completed,
          gamesLogged: 5,
          blockSize: 5,
          adherence: BlockReviewAdherence.stayedInsideBlock,
          targetResult: BlockReviewTargetResult.improved,
          overallOutcome: BlockReviewOutcome.onTrack,
        ),
        sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.heroPool),
        followThrough: null,
      );
      final drift = service.build(
        activeStartedCheckpoint: started,
        reviewedBlock: const BlockReview(
          blockStatus: BlockReviewStatus.completed,
          gamesLogged: 5,
          blockSize: 5,
          adherence: BlockReviewAdherence.offBlock,
          targetResult: BlockReviewTargetResult.flat,
          overallOutcome: BlockReviewOutcome.mixed,
        ),
        sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.heroPool),
        followThrough: null,
      );
      final offTrack = service.build(
        activeStartedCheckpoint: started,
        reviewedBlock: const BlockReview(
          blockStatus: BlockReviewStatus.completed,
          gamesLogged: 5,
          blockSize: 5,
          adherence: BlockReviewAdherence.noBlockSet,
          targetResult: BlockReviewTargetResult.worse,
          overallOutcome: BlockReviewOutcome.offTrack,
        ),
        sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.heroPool),
        followThrough: null,
      );

      expect(onTrack!.nextStepSuggestion, 'Run the same block again.');
      expect(drift!.nextStepSuggestion, 'Tighten the hero block before restarting.');
      expect(offTrack!.nextStepSuggestion, 'Keep the role, change the hero pair.');
    });
  });
}

CoachingCheckpoint _startedCheckpoint({
  required SessionPlanTargetType targetType,
  List<int> heroBlockIds = const [],
}) {
  return CoachingCheckpoint(
    accountId: 86745912,
    savedAt: DateTime.utc(2025, 3, 20, 10),
    focusAction: 'Focus action',
    focusSourceLabel: 'Focus source',
    topInsightType: CoachingInsightType.heroPoolSpread,
    savedSessionPlan: CoachingCheckpointSessionPlan(
      queue: 'Carry only',
      heroBlock: 'Hero block',
      target: 'Target',
      reviewWindow: 'next 5 games',
      targetType: targetType,
      heroBlockHeroIds: heroBlockIds,
      heroBlockHeroLabels: heroBlockIds
          .map((heroId) => 'Hero $heroId')
          .toList(growable: false),
      roleBlockKey: 'carry',
      usesManualRoleSetup: true,
      usesManualHeroBlock: heroBlockIds.isNotEmpty,
    ),
    sample: const CoachingCheckpointSample(
      matchesAnalyzed: 10,
      wins: 5,
      losses: 5,
      winRate: 0.5,
      uniqueHeroesPlayed: 4,
      averageDeaths: 6.2,
      likelyRoleSummaryLabel: 'Carry',
      roleEstimateStrengthLabel: 'Strong estimate',
      hasClearRoleEstimate: true,
      primaryRoleKey: 'carry',
    ),
  );
}

SessionPlan _sessionPlan({required SessionPlanTargetType targetType}) {
  return SessionPlan(
    queue: 'Carry only',
    heroBlock: 'Hero block',
    target: 'Target',
    reviewWindow: 'next 5 games',
    targetType: targetType,
  );
}
