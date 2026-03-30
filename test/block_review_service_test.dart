import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/dashboard/domain/models/block_review.dart';
import 'package:dotes/src/features/dashboard/domain/models/session_plan.dart';
import 'package:dotes/src/features/dashboard/domain/services/block_review_service.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/progress/domain/models/focus_follow_through_check.dart';
import 'package:dotes/src/features/progress/domain/models/progress_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = BlockReviewService();

  group('BlockReviewService', () {
    test('returns a completed block with good adherence', () {
      final review = service.build(
        previousCheckpoint: _checkpoint(
          savedAt: DateTime.utc(2025, 3, 20, 10),
          topInsightType: CoachingInsightType.comfortHeroDependence,
          focusHeroBlock: const CoachingCheckpointHeroBlock(
            heroIds: [28, 129],
            heroLabels: ['Slardar', 'Mars'],
            wins: 3,
            losses: 2,
          ),
        ),
        currentImport: _importedPlayer(
          matches: [
            _match(
              matchId: 1,
              startedAt: DateTime.utc(2025, 3, 20, 11),
              heroId: 28,
              didWin: true,
            ),
            _match(
              matchId: 2,
              startedAt: DateTime.utc(2025, 3, 20, 12),
              heroId: 129,
              didWin: true,
            ),
            _match(
              matchId: 3,
              startedAt: DateTime.utc(2025, 3, 20, 13),
              heroId: 28,
              didWin: false,
            ),
            _match(
              matchId: 4,
              startedAt: DateTime.utc(2025, 3, 20, 14),
              heroId: 53,
              didWin: false,
            ),
            _match(
              matchId: 5,
              startedAt: DateTime.utc(2025, 3, 20, 15),
              heroId: 129,
              didWin: true,
            ),
          ],
        ),
        sessionPlan: _sessionPlan(
          targetType: SessionPlanTargetType.comfortBlock,
          heroBlockHeroIds: const [28, 129],
        ),
        followThroughCheck: FocusFollowThroughCheck.ready(
          status: FocusFollowThroughStatus.onTrack,
          detail: 'Detail',
          checkpointSavedAt: DateTime.utc(2025, 3, 20, 10),
          previousFocusLabel: 'Slardar + Mars block',
          comparisonLabel: 'Compared against your last saved block.',
        ),
        progressCheck: null,
      );

      expect(review.blockStatus, BlockReviewStatus.completed);
      expect(review.gamesLoggedLabel, '5 of 5');
      expect(review.adherence, BlockReviewAdherence.stayedInsideBlock);
      expect(review.targetResult, BlockReviewTargetResult.improved);
      expect(review.overallOutcome, BlockReviewOutcome.onTrack);
    });

    test('returns a completed block with drift', () {
      final review = service.build(
        previousCheckpoint: _checkpoint(
          savedAt: DateTime.utc(2025, 3, 20, 10),
          topInsightType: CoachingInsightType.comfortHeroDependence,
          focusHeroBlock: const CoachingCheckpointHeroBlock(
            heroIds: [28, 129],
            heroLabels: ['Slardar', 'Mars'],
            wins: 3,
            losses: 2,
          ),
        ),
        currentImport: _importedPlayer(
          matches: [
            _match(
              matchId: 1,
              startedAt: DateTime.utc(2025, 3, 20, 11),
              heroId: 53,
              didWin: false,
            ),
            _match(
              matchId: 2,
              startedAt: DateTime.utc(2025, 3, 20, 12),
              heroId: 54,
              didWin: false,
            ),
            _match(
              matchId: 3,
              startedAt: DateTime.utc(2025, 3, 20, 13),
              heroId: 55,
              didWin: true,
            ),
            _match(
              matchId: 4,
              startedAt: DateTime.utc(2025, 3, 20, 14),
              heroId: 28,
              didWin: true,
            ),
            _match(
              matchId: 5,
              startedAt: DateTime.utc(2025, 3, 20, 15),
              heroId: 56,
              didWin: false,
            ),
          ],
        ),
        sessionPlan: _sessionPlan(
          targetType: SessionPlanTargetType.comfortBlock,
          heroBlockHeroIds: const [28, 129],
        ),
        followThroughCheck: FocusFollowThroughCheck.ready(
          status: FocusFollowThroughStatus.offTrack,
          detail: 'Detail',
          checkpointSavedAt: DateTime.utc(2025, 3, 20, 10),
          previousFocusLabel: 'Slardar + Mars block',
          comparisonLabel: 'Compared against your last saved block.',
        ),
        progressCheck: null,
      );

      expect(review.blockStatus, BlockReviewStatus.completed);
      expect(review.adherence, BlockReviewAdherence.offBlock);
      expect(review.targetResult, BlockReviewTargetResult.flat);
      expect(review.overallOutcome, BlockReviewOutcome.offTrack);
    });

    test('returns an incomplete block when fewer than 5 games are available', () {
      final review = service.build(
        previousCheckpoint: _checkpoint(
          savedAt: DateTime.utc(2025, 3, 20, 10),
          topInsightType: CoachingInsightType.heroPoolSpread,
        ),
        currentImport: _importedPlayer(
          matches: [
            _match(
              matchId: 1,
              startedAt: DateTime.utc(2025, 3, 20, 11),
              heroId: 28,
              didWin: true,
            ),
            _match(
              matchId: 2,
              startedAt: DateTime.utc(2025, 3, 20, 12),
              heroId: 129,
              didWin: false,
            ),
            _match(
              matchId: 3,
              startedAt: DateTime.utc(2025, 3, 20, 13),
              heroId: 53,
              didWin: true,
            ),
          ],
        ),
        sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.heroPool),
        followThroughCheck: const FocusFollowThroughCheck.waiting(
          fallbackMessage: 'Need a bigger block before judging follow-through.',
        ),
        progressCheck: null,
      );

      expect(review.blockStatus, BlockReviewStatus.inProgress);
      expect(review.gamesLoggedLabel, '3 of 5');
      expect(review.adherence, BlockReviewAdherence.noBlockSet);
      expect(review.overallOutcome, BlockReviewOutcome.mixed);
    });

    test('marks the target result as improved when deaths drop', () {
      final review = service.build(
        previousCheckpoint: _checkpoint(
          savedAt: DateTime.utc(2025, 3, 20, 10),
          topInsightType: CoachingInsightType.earlyDeathRisk,
          averageDeaths: 7.4,
        ),
        currentImport: _importedPlayer(
          matches: [
            _match(
              matchId: 1,
              startedAt: DateTime.utc(2025, 3, 20, 11),
              heroId: 28,
              deaths: 5,
              didWin: true,
            ),
            _match(
              matchId: 2,
              startedAt: DateTime.utc(2025, 3, 20, 12),
              heroId: 129,
              deaths: 6,
              didWin: false,
            ),
            _match(
              matchId: 3,
              startedAt: DateTime.utc(2025, 3, 20, 13),
              heroId: 28,
              deaths: 5,
              didWin: true,
            ),
            _match(
              matchId: 4,
              startedAt: DateTime.utc(2025, 3, 20, 14),
              heroId: 53,
              deaths: 6,
              didWin: true,
            ),
            _match(
              matchId: 5,
              startedAt: DateTime.utc(2025, 3, 20, 15),
              heroId: 129,
              deaths: 5,
              didWin: true,
            ),
          ],
        ),
        sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.deaths),
        followThroughCheck: null,
        progressCheck: const ProgressCheck.ready(
          blockSize: 5,
          comparisons: [
            ProgressMetricComparison(
              label: 'Deaths',
              direction: ProgressDirection.down,
              currentValueLabel: '5.4',
              previousValueLabel: '7.4',
            ),
          ],
        ),
      );

      expect(review.targetResult, BlockReviewTargetResult.improved);
      expect(review.overallOutcome, BlockReviewOutcome.onTrack);
    });

    test('marks the target result as worse when the pool widens', () {
      final review = service.build(
        previousCheckpoint: _checkpoint(
          savedAt: DateTime.utc(2025, 3, 20, 10),
          topInsightType: CoachingInsightType.heroPoolSpread,
          uniqueHeroesPlayed: 3,
        ),
        currentImport: _importedPlayer(
          matches: [
            _match(
              matchId: 1,
              startedAt: DateTime.utc(2025, 3, 20, 11),
              heroId: 28,
            ),
            _match(
              matchId: 2,
              startedAt: DateTime.utc(2025, 3, 20, 12),
              heroId: 129,
            ),
            _match(
              matchId: 3,
              startedAt: DateTime.utc(2025, 3, 20, 13),
              heroId: 53,
            ),
            _match(
              matchId: 4,
              startedAt: DateTime.utc(2025, 3, 20, 14),
              heroId: 54,
            ),
            _match(
              matchId: 5,
              startedAt: DateTime.utc(2025, 3, 20, 15),
              heroId: 55,
            ),
          ],
        ),
        sessionPlan: _sessionPlan(targetType: SessionPlanTargetType.heroPool),
        followThroughCheck: const FocusFollowThroughCheck.waiting(
          fallbackMessage: 'Need a bigger block before judging follow-through.',
        ),
        progressCheck: const ProgressCheck.ready(
          blockSize: 5,
          comparisons: [
            ProgressMetricComparison(
              label: 'Hero pool',
              direction: ProgressDirection.wider,
              currentValueLabel: '5 heroes',
              previousValueLabel: '3 heroes',
            ),
          ],
        ),
      );

      expect(review.blockStatus, BlockReviewStatus.completed);
      expect(review.targetResult, BlockReviewTargetResult.worse);
      expect(review.overallOutcome, BlockReviewOutcome.offTrack);
    });
  });
}

CoachingCheckpoint _checkpoint({
  required DateTime savedAt,
  CoachingInsightType? topInsightType,
  CoachingCheckpointHeroBlock? focusHeroBlock,
  int uniqueHeroesPlayed = 4,
  double averageDeaths = 6.5,
  double winRate = 0.5,
  String likelyRoleSummaryLabel = 'Core role leaning',
}) {
  final wins = (winRate * 10).round();

  return CoachingCheckpoint(
    accountId: 86745912,
    savedAt: savedAt,
    focusAction: 'Focus action',
    focusSourceLabel: 'Focus source',
    topInsightType: topInsightType,
    focusHeroBlock: focusHeroBlock,
    sample: CoachingCheckpointSample(
      matchesAnalyzed: 10,
      wins: wins,
      losses: 10 - wins,
      winRate: winRate,
      uniqueHeroesPlayed: uniqueHeroesPlayed,
      averageDeaths: averageDeaths,
      likelyRoleSummaryLabel: likelyRoleSummaryLabel,
      roleEstimateStrengthLabel: 'Moderate estimate',
      hasClearRoleEstimate: true,
      primaryRoleKey: 'carry',
    ),
  );
}

ImportedPlayerData _importedPlayer({
  required List<RecentMatch> matches,
}) {
  return ImportedPlayerData(
    profile: const PlayerProfileSummary(
      accountId: 86745912,
      personaName: 'Player',
      avatarUrl: '',
      leaderboardRank: null,
    ),
    recentMatches: matches.reversed.toList(growable: false),
  );
}

RecentMatch _match({
  required int matchId,
  required DateTime startedAt,
  required int heroId,
  bool didWin = true,
  int deaths = 5,
}) {
  return RecentMatch(
    matchId: matchId,
    heroId: heroId,
    startedAt: startedAt,
    duration: const Duration(minutes: 35),
    kills: 8,
    deaths: deaths,
    assists: 12,
    didWin: didWin,
    goldPerMin: 560,
    xpPerMin: 580,
    lastHits: 180,
    lane: 1,
    laneRole: 1,
    isRoaming: false,
    partySize: 1,
  );
}

SessionPlan _sessionPlan({
  required SessionPlanTargetType targetType,
  List<int> heroBlockHeroIds = const [],
  String? roleBlockKey,
}) {
  return SessionPlan(
    queue: 'Carry only',
    heroBlock: heroBlockHeroIds.isEmpty ? '2 heroes max' : 'Slardar + Mars',
    target: 'Target',
    reviewWindow: 'next 5 games',
    targetType: targetType,
    heroBlockHeroIds: heroBlockHeroIds,
    roleBlockKey: roleBlockKey,
  );
}
