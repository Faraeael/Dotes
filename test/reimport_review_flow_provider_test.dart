import 'package:dotes/src/features/checkpoints/application/coaching_checkpoint_providers.dart';
import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/dashboard/application/block_review_provider.dart';
import 'package:dotes/src/features/dashboard/application/end_block_summary_provider.dart';
import 'package:dotes/src/features/dashboard/application/session_plan_provider.dart';
import 'package:dotes/src/features/dashboard/domain/models/block_review.dart';
import 'package:dotes/src/features/dashboard/domain/models/session_plan.dart';
import 'package:dotes/src/features/player_import/application/imported_player_provider.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('re-import review providers', () {
    test(
      'completed 5-game re-import produces block review and end summary',
      () {
        final container = ProviderContainer(
          overrides: [
            sessionPlanProvider.overrideWithValue(
              const SessionPlan(
                queue: 'Offlane only',
                heroBlock: 'Slardar + Mars',
                target: 'stay inside the block',
                reviewWindow: 'next 5 games',
                targetType: SessionPlanTargetType.comfortBlock,
                heroBlockHeroIds: [28, 129],
                roleBlockKey: 'offlane',
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(previousCoachingCheckpointProvider.notifier).state =
            _startedCheckpoint();
        container.read(importedPlayerProvider.notifier).state =
            _completedReimport();

        final review = container.read(blockReviewProvider);
        final summary = container.read(endBlockSummaryProvider);

        expect(review, isNotNull);
        expect(review!.blockStatus, BlockReviewStatus.completed);
        expect(review.adherence, BlockReviewAdherence.stayedInsideBlock);
        expect(review.targetResult, BlockReviewTargetResult.improved);
        expect(review.overallOutcome, BlockReviewOutcome.onTrack);

        expect(summary, isNotNull);
        expect(
          summary!.takeaway,
          'You stayed inside the block and comfort results improved.',
        );
        expect(summary.nextStepSuggestion, 'Run the same block again.');
      },
    );

    test('incomplete re-import keeps block review live and summary hidden', () {
      final container = ProviderContainer(
        overrides: [
          sessionPlanProvider.overrideWithValue(
            const SessionPlan(
              queue: 'Offlane only',
              heroBlock: 'Slardar + Mars',
              target: 'stay inside the block',
              reviewWindow: 'next 5 games',
              targetType: SessionPlanTargetType.comfortBlock,
              heroBlockHeroIds: [28, 129],
              roleBlockKey: 'offlane',
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(previousCoachingCheckpointProvider.notifier).state =
          _startedCheckpoint();
      container.read(importedPlayerProvider.notifier).state =
          _incompleteReimport();

      final review = container.read(blockReviewProvider);
      final summary = container.read(endBlockSummaryProvider);

      expect(review, isNotNull);
      expect(review!.blockStatus, BlockReviewStatus.inProgress);
      expect(review.gamesLogged, 4);
      expect(summary, isNull);
    });
  });
}

ImportedPlayerData _completedReimport() {
  return ImportedPlayerData(
    profile: _profile(),
    recentMatches: [
      _matchAt(110, 28, true, DateTime.utc(2025, 4, 6)),
      _matchAt(109, 129, true, DateTime.utc(2025, 4, 5)),
      _matchAt(108, 28, false, DateTime.utc(2025, 4, 4)),
      _matchAt(107, 129, true, DateTime.utc(2025, 4, 3)),
      _matchAt(106, 28, true, DateTime.utc(2025, 4, 2)),
      _matchAt(105, 53, false, DateTime.utc(2025, 3, 31)),
      _matchAt(104, 29, true, DateTime.utc(2025, 3, 30)),
    ],
  );
}

ImportedPlayerData _incompleteReimport() {
  return ImportedPlayerData(
    profile: _profile(),
    recentMatches: [
      _matchAt(109, 28, true, DateTime.utc(2025, 4, 5)),
      _matchAt(108, 129, true, DateTime.utc(2025, 4, 4)),
      _matchAt(107, 28, false, DateTime.utc(2025, 4, 3)),
      _matchAt(106, 129, true, DateTime.utc(2025, 4, 2)),
      _matchAt(105, 53, false, DateTime.utc(2025, 3, 31)),
      _matchAt(104, 29, true, DateTime.utc(2025, 3, 30)),
    ],
  );
}

PlayerProfileSummary _profile() {
  return const PlayerProfileSummary(
    accountId: 86745912,
    personaName: 'Block Tester',
    avatarUrl: '',
    leaderboardRank: null,
  );
}

RecentMatch _matchAt(int matchId, int heroId, bool didWin, DateTime startedAt) {
  return RecentMatch(
    matchId: matchId,
    heroId: heroId,
    startedAt: startedAt,
    duration: const Duration(minutes: 32),
    kills: didWin ? 8 : 4,
    deaths: didWin ? 4 : 7,
    assists: didWin ? 12 : 8,
    didWin: didWin,
    partySize: 1,
  );
}

CoachingCheckpoint _startedCheckpoint() {
  return CoachingCheckpoint(
    accountId: 86745912,
    savedAt: DateTime.utc(2025, 4, 1),
    focusAction: 'Stay inside the Slardar + Mars block.',
    focusSourceLabel: 'Comfort hero dependence',
    topInsightType: null,
    savedSessionPlan: const CoachingCheckpointSessionPlan(
      queue: 'Offlane only',
      heroBlock: 'Slardar + Mars',
      target: 'stay inside the block',
      reviewWindow: 'next 5 games',
      targetType: SessionPlanTargetType.comfortBlock,
      heroBlockHeroIds: [28, 129],
      heroBlockHeroLabels: ['Slardar', 'Mars'],
      roleBlockKey: 'offlane',
      usesManualRoleSetup: false,
      usesManualHeroBlock: false,
    ),
    sample: const CoachingCheckpointSample(
      matchesAnalyzed: 10,
      wins: 5,
      losses: 5,
      winRate: 0.5,
      uniqueHeroesPlayed: 4,
      averageDeaths: 5.8,
      likelyRoleSummaryLabel: 'Offlane',
      roleEstimateStrengthLabel: 'Strong estimate',
      hasClearRoleEstimate: true,
      primaryRoleKey: 'offlane',
      recentMatchesWindow: [
        CoachingCheckpointMatchSummary(matchId: 105, heroId: 53, didWin: false),
        CoachingCheckpointMatchSummary(matchId: 104, heroId: 29, didWin: true),
        CoachingCheckpointMatchSummary(matchId: 103, heroId: 28, didWin: true),
        CoachingCheckpointMatchSummary(
          matchId: 102,
          heroId: 129,
          didWin: false,
        ),
        CoachingCheckpointMatchSummary(matchId: 101, heroId: 30, didWin: true),
      ],
    ),
  );
}
