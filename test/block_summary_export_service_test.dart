import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/dashboard/domain/models/block_review.dart';
import 'package:dotes/src/features/dashboard/domain/models/end_block_summary.dart';
import 'package:dotes/src/features/dashboard/domain/models/session_plan.dart';
import 'package:dotes/src/features/dashboard/domain/services/block_summary_export_service.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = BlockSummaryExportService();

  group('BlockSummaryExportService', () {
    test('builds deterministic export content from completed summary', () {
      final result = service.build(
        completedSummary: const EndBlockSummary(
          outcome: BlockReviewOutcome.onTrack,
          mainTargetResult: 'Improved',
          adherenceResult: 'Stayed in block',
          takeaway: 'You stayed inside the block and deaths improved.',
          nextStepSuggestion: 'Run the same block again.',
        ),
        activeStartedCheckpoint: _checkpoint(savedAt: DateTime.utc(2025, 3, 20, 10)),
        importedPlayer: _player(
          personaName: 'Player',
          matches: [
            _match(1, DateTime.utc(2025, 3, 20, 11)),
            _match(2, DateTime.utc(2025, 3, 20, 12)),
            _match(3, DateTime.utc(2025, 3, 20, 13)),
            _match(4, DateTime.utc(2025, 3, 20, 14)),
            _match(5, DateTime.utc(2025, 3, 20, 15)),
          ],
        ),
      );

      expect(result, isNotNull);
      expect(result!.playerLabel, 'Player (Account 86745912)');
      expect(result.completionDateLabel, 'Mar 20, 2025');
      expect(result.outcome, 'On track');
      expect(result.mainTargetResult, 'Improved');
      expect(result.adherenceResult, 'Stayed in block');
      expect(
        result.shareText,
        [
          'Training block summary',
          'Player: Player (Account 86745912)',
          'Completed: Mar 20, 2025',
          'Outcome: On track',
          'Target result: Improved',
          'Adherence: Stayed in block',
          'Takeaway: You stayed inside the block and deaths improved.',
          'Next step: Run the same block again.',
        ].join('\n'),
      );
    });

    test('uses fallback labels when player or block window are unavailable', () {
      final result = service.build(
        completedSummary: const EndBlockSummary(
          outcome: BlockReviewOutcome.mixed,
          mainTargetResult: 'Flat',
          adherenceResult: 'Some drift',
          takeaway: 'The block finished, but the signal stayed mixed.',
          nextStepSuggestion: 'Keep the role, change the hero pair.',
        ),
        activeStartedCheckpoint: _checkpoint(
          savedAt: DateTime.utc(2025, 3, 21, 10),
          accountId: 999001,
        ),
        importedPlayer: null,
      );

      expect(result, isNotNull);
      expect(result!.playerLabel, 'Account 999001');
      expect(result.completionDateLabel, 'Mar 21, 2025');
    });

    test('returns null when required summary context is missing', () {
      final result = service.build(
        completedSummary: null,
        activeStartedCheckpoint: _checkpoint(savedAt: DateTime.utc(2025, 3, 20, 10)),
        importedPlayer: _player(personaName: 'Player', matches: const []),
      );

      expect(result, isNull);
    });
  });
}

CoachingCheckpoint _checkpoint({
  required DateTime savedAt,
  int accountId = 86745912,
}) {
  return CoachingCheckpoint(
    accountId: accountId,
    savedAt: savedAt,
    focusAction: 'Focus action',
    focusSourceLabel: 'Focus source',
    topInsightType: CoachingInsightType.heroPoolSpread,
    savedSessionPlan: const CoachingCheckpointSessionPlan(
      queue: 'Carry only',
      heroBlock: 'Hero block',
      target: 'Target',
      reviewWindow: 'next 5 games',
      targetType: SessionPlanTargetType.heroPool,
      heroBlockHeroIds: [28, 129],
      heroBlockHeroLabels: ['Slardar', 'Mars'],
      roleBlockKey: 'carry',
      usesManualRoleSetup: true,
      usesManualHeroBlock: true,
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

ImportedPlayerData _player({
  required String personaName,
  required List<RecentMatch> matches,
}) {
  return ImportedPlayerData(
    profile: PlayerProfileSummary(
      accountId: 86745912,
      personaName: personaName,
      avatarUrl: '',
      leaderboardRank: null,
    ),
    recentMatches: matches.reversed.toList(growable: false),
  );
}

RecentMatch _match(int id, DateTime startedAt) {
  return RecentMatch(
    matchId: id,
    heroId: 28,
    startedAt: startedAt,
    duration: const Duration(minutes: 35),
    kills: 8,
    deaths: 5,
    assists: 12,
    didWin: true,
    goldPerMin: 560,
    xpPerMin: 580,
    lastHits: 180,
    lane: 1,
    laneRole: 1,
    isRoaming: false,
    partySize: 1,
  );
}
