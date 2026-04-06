import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/dashboard/domain/models/block_review.dart';
import 'package:dotes/src/features/dashboard/domain/models/comfort_core_summary.dart';
import 'package:dotes/src/features/dashboard/domain/models/session_plan.dart';
import 'package:dotes/src/features/hero_detail/domain/models/hero_detail.dart';
import 'package:dotes/src/features/hero_detail/domain/services/hero_detail_service.dart';
import 'package:dotes/src/features/meta_reference/domain/models/hero_meta_reference.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = HeroDetailService();

  group('HeroDetailService', () {
    test('marks a hero inside the comfort core', () {
      final detail = service.build(
        heroId: 28,
        allMatches: _sampleMatches(),
        heroLabelFor: _heroLabelFor,
        comfortCore: _comfortCoreSummary(),
      );

      expect(detail.heroName, 'Slardar');
      expect(detail.tags, contains(HeroDetailTag.comfortCore));
      expect(
        detail.coachingRead,
        'This hero is currently part of your comfort core.',
      );
      expect(
        detail.rationaleLines,
        contains(
          'Recent wins still point back to this hero as part of your comfort core.',
        ),
      );
      expect(detail.trainingDecision, HeroTrainingDecision.goodBackupHero);
    });

    test('marks a hero outside the comfort core', () {
      final detail = service.build(
        heroId: 18,
        allMatches: _sampleMatches(),
        heroLabelFor: _heroLabelFor,
        comfortCore: _comfortCoreSummary(),
        sessionPlan: _sessionPlan(heroIds: const [28, 129]),
      );

      expect(detail.tags, contains(HeroDetailTag.outsideCurrentPlan));
      expect(detail.tags, isNot(contains(HeroDetailTag.comfortCore)));
      expect(
        detail.coachingRead,
        'Results on this hero are weaker than your top block.',
      );
      expect(
        detail.rationaleLines,
        contains('This hero sits outside the current named block for now.'),
      );
      expect(
        detail.rationaleLines,
        contains(
          'Its recent results are trailing the heroes carrying your current block.',
        ),
      );
      expect(detail.trainingDecision, HeroTrainingDecision.testLaterNotNow);
    });

    test('marks a hero inside the current session plan', () {
      final detail = service.build(
        heroId: 28,
        allMatches: _planOnlyMatches(),
        heroLabelFor: _heroLabelFor,
        sessionPlan: _sessionPlan(heroIds: const [28, 129]),
      );

      expect(detail.tags, contains(HeroDetailTag.inCurrentPlan));
      expect(detail.tags, isNot(contains(HeroDetailTag.comfortCore)));
      expect(
        detail.coachingRead,
        'This hero is currently in your session plan.',
      );
      expect(
        detail.rationaleLines,
        contains('This hero is already inside your current named block.'),
      );
      expect(detail.trainingDecision, HeroTrainingDecision.keepInBlock);
    });

    test('falls back conservatively for a tiny hero sample', () {
      final detail = service.build(
        heroId: 18,
        allMatches: _tinySampleMatches(),
        heroLabelFor: _heroLabelFor,
        sessionPlan: _sessionPlan(heroIds: const [18]),
      );

      expect(detail.matchesInSample, 2);
      expect(detail.coachingRead, 'Too little recent data for a strong read.');
      expect(
        detail.rationaleLines.first,
        'Only 2 recent games on this hero, so the read stays conservative.',
      );
      expect(detail.trainingDecision, HeroTrainingDecision.tooLittleData);
      expect(detail.averageDeaths, closeTo(4.5, 0.001));
    });

    test('marks when a hero was in the last named block', () {
      final detail = service.build(
        heroId: 28,
        allMatches: _postCheckpointMatches(),
        heroLabelFor: _heroLabelFor,
        previousCheckpoint: _checkpoint(
          focusHeroBlock: const CoachingCheckpointHeroBlock(
            heroIds: [28, 129],
            heroLabels: ['Slardar', 'Mars'],
            wins: 3,
            losses: 2,
          ),
          recentMatchesWindow: const [
            CoachingCheckpointMatchSummary(heroId: 28, didWin: false),
            CoachingCheckpointMatchSummary(heroId: 28, didWin: true),
          ],
        ),
        blockReview: _blockReview(),
      );

      expect(detail.blockContext, isNotNull);
      expect(
        detail.blockContext!.lastPlanStatus,
        HeroLastPlanStatus.inLastNamedBlock,
      );
      expect(detail.blockContext!.reviewedBlockAppearances, 2);
      expect(
        detail.rationaleLines,
        contains(
          'The last started block used this hero in 2 of 5 review games.',
        ),
      );
    });

    test('marks when a hero was not in the last named block', () {
      final detail = service.build(
        heroId: 18,
        allMatches: _postCheckpointMatches(),
        heroLabelFor: _heroLabelFor,
        previousCheckpoint: _checkpoint(
          focusHeroBlock: const CoachingCheckpointHeroBlock(
            heroIds: [28, 129],
            heroLabels: ['Slardar', 'Mars'],
            wins: 3,
            losses: 2,
          ),
          recentMatchesWindow: const [
            CoachingCheckpointMatchSummary(heroId: 18, didWin: false),
            CoachingCheckpointMatchSummary(heroId: 18, didWin: true),
          ],
        ),
        blockReview: _blockReview(),
      );

      expect(
        detail.blockContext!.lastPlanStatus,
        HeroLastPlanStatus.outsideLastNamedBlock,
      );
      expect(detail.blockContext!.reviewedBlockAppearances, 1);
    });

    test('judges hero improvement when enough history exists', () {
      final detail = service.build(
        heroId: 28,
        allMatches: _postCheckpointMatches(),
        heroLabelFor: _heroLabelFor,
        previousCheckpoint: _checkpoint(
          recentMatchesWindow: const [
            CoachingCheckpointMatchSummary(heroId: 28, didWin: false),
            CoachingCheckpointMatchSummary(heroId: 28, didWin: true),
          ],
        ),
        blockReview: _blockReview(),
      );

      expect(detail.blockContext!.trendStatus, HeroBlockTrendStatus.improved);
      expect(detail.blockContext!.baselineWinRatePercentage, 50);
      expect(detail.blockContext!.reviewedBlockWinRatePercentage, 100);
      expect(
        detail.blockContext!.trendDetail,
        'Win rate moved from 50% before the block to 100% in the review window.',
      );
    });

    test('uses a calm fallback when hero history is too small', () {
      final detail = service.build(
        heroId: 28,
        allMatches: _postCheckpointMatches(),
        heroLabelFor: _heroLabelFor,
        previousCheckpoint: _checkpoint(
          recentMatchesWindow: const [
            CoachingCheckpointMatchSummary(heroId: 28, didWin: true),
          ],
        ),
        blockReview: _blockReview(),
      );

      expect(
        detail.blockContext!.trendStatus,
        HeroBlockTrendStatus.notEnoughHistory,
      );
      expect(detail.blockContext!.baselineWinRatePercentage, 100);
      expect(detail.blockContext!.reviewedBlockWinRatePercentage, 100);
      expect(
        detail.blockContext!.trendDetail,
        'Need at least 2 baseline and 2 block games on this hero.',
      );
    });

    test('builds a strong meta reference read when personal state agrees', () {
      final detail = service.build(
        heroId: 129,
        allMatches: _sampleMatches(),
        heroLabelFor: _heroLabelFor,
        currentSupportedPatchLabel: '7.41a',
        comfortCore: _comfortCoreSummary(),
        metaReference: const HeroMetaReference(
          heroId: 129,
          patchLabel: '7.41a',
          tier: HeroMetaTier.top,
          roleLabel: 'Offlane initiator',
          coreItemDirection: 'Blink into BKB and control',
        ),
      );

      expect(detail.metaSummary.hasReference, isTrue);
      expect(detail.metaSummary.reference!.patchLabel, '7.41a');
      expect(detail.metaSummary.isFresh, isTrue);
      expect(
        detail.metaSummary.interpretation,
        'This hero currently matches the high-level meta.',
      );
    });

    test('uses a calm fallback when no meta reference is available', () {
      final detail = service.build(
        heroId: 777,
        allMatches: _metaFallbackMatches(),
        heroLabelFor: _heroLabelFor,
        currentSupportedPatchLabel: '7.41a',
      );

      expect(detail.metaSummary.hasReference, isFalse);
      expect(
        detail.metaSummary.fallbackMessage,
        'No local meta reference is seeded for this hero yet.',
      );
      expect(
        detail.metaSummary.interpretation,
        'Lean on your own coaching sample for this hero right now.',
      );
    });

    test('calls out when comfort and meta pull in different directions', () {
      final detail = service.build(
        heroId: 28,
        allMatches: _sampleMatches(),
        heroLabelFor: _heroLabelFor,
        currentSupportedPatchLabel: '7.41a',
        comfortCore: _comfortCoreSummary(),
        metaReference: const HeroMetaReference(
          heroId: 28,
          patchLabel: '7.41a',
          tier: HeroMetaTier.niche,
          roleLabel: 'Offlane initiator',
          coreItemDirection: 'Blink into BKB or utility',
        ),
      );

      expect(detail.tags, contains(HeroDetailTag.comfortCore));
      expect(
        detail.metaSummary.interpretation,
        'This hero is more comfort-driven than meta-driven right now.',
      );
    });

    test('downgrades the interpretation when meta is outdated', () {
      final detail = service.build(
        heroId: 129,
        allMatches: _sampleMatches(),
        heroLabelFor: _heroLabelFor,
        currentSupportedPatchLabel: '7.41b',
        comfortCore: _comfortCoreSummary(),
        metaReference: const HeroMetaReference(
          heroId: 129,
          patchLabel: '7.41a',
          tier: HeroMetaTier.top,
          roleLabel: 'Offlane initiator',
          coreItemDirection: 'Blink into BKB and control',
        ),
      );

      expect(detail.metaSummary.isStale, isTrue);
      expect(
        detail.metaSummary.staleWarning,
        'Patch 7.41a is behind supported patch 7.41b.',
      );
      expect(
        detail.metaSummary.interpretation,
        'Lean on your own sample until the local patch reference is refreshed.',
      );
    });
  });
}

List<RecentMatch> _sampleMatches() {
  return [
    _match(matchId: 1, heroId: 28, didWin: true, daysAgo: 1),
    _match(matchId: 2, heroId: 28, didWin: true, daysAgo: 2),
    _match(matchId: 3, heroId: 28, didWin: false, daysAgo: 3),
    _match(matchId: 4, heroId: 129, didWin: true, daysAgo: 4),
    _match(matchId: 5, heroId: 129, didWin: true, daysAgo: 5),
    _match(matchId: 6, heroId: 129, didWin: false, daysAgo: 6),
    _match(matchId: 7, heroId: 18, didWin: false, daysAgo: 7),
    _match(matchId: 8, heroId: 18, didWin: true, daysAgo: 8),
    _match(matchId: 9, heroId: 18, didWin: false, daysAgo: 9),
  ];
}

List<RecentMatch> _planOnlyMatches() {
  return [
    _match(matchId: 1, heroId: 28, didWin: true, daysAgo: 1),
    _match(matchId: 2, heroId: 28, didWin: false, daysAgo: 2),
    _match(matchId: 3, heroId: 28, didWin: true, daysAgo: 3),
    _match(matchId: 4, heroId: 18, didWin: false, daysAgo: 4),
    _match(matchId: 5, heroId: 18, didWin: true, daysAgo: 5),
    _match(matchId: 6, heroId: 18, didWin: false, daysAgo: 6),
  ];
}

List<RecentMatch> _tinySampleMatches() {
  return [
    _match(matchId: 1, heroId: 18, didWin: true, daysAgo: 1, deaths: 4),
    _match(matchId: 2, heroId: 18, didWin: false, daysAgo: 2, deaths: 5),
    _match(matchId: 3, heroId: 28, didWin: true, daysAgo: 3),
    _match(matchId: 4, heroId: 129, didWin: true, daysAgo: 4),
  ];
}

List<RecentMatch> _postCheckpointMatches() {
  return [
    _matchAt(
      matchId: 10,
      heroId: 53,
      didWin: true,
      startedAt: DateTime.utc(2026, 3, 20, 9),
    ),
    _matchAt(
      matchId: 11,
      heroId: 18,
      didWin: false,
      startedAt: DateTime.utc(2026, 3, 20, 11),
    ),
    _matchAt(
      matchId: 12,
      heroId: 28,
      didWin: true,
      startedAt: DateTime.utc(2026, 3, 20, 12),
    ),
    _matchAt(
      matchId: 13,
      heroId: 129,
      didWin: false,
      startedAt: DateTime.utc(2026, 3, 20, 13),
    ),
    _matchAt(
      matchId: 14,
      heroId: 28,
      didWin: true,
      startedAt: DateTime.utc(2026, 3, 20, 14),
    ),
    _matchAt(
      matchId: 15,
      heroId: 53,
      didWin: true,
      startedAt: DateTime.utc(2026, 3, 20, 15),
    ),
    _matchAt(
      matchId: 16,
      heroId: 28,
      didWin: false,
      startedAt: DateTime.utc(2026, 3, 20, 16),
    ),
  ];
}

List<RecentMatch> _metaFallbackMatches() {
  return [
    _match(matchId: 21, heroId: 777, didWin: true, daysAgo: 1),
    _match(matchId: 22, heroId: 777, didWin: false, daysAgo: 2),
    _match(matchId: 23, heroId: 777, didWin: true, daysAgo: 3),
    _match(matchId: 24, heroId: 28, didWin: true, daysAgo: 4),
    _match(matchId: 25, heroId: 129, didWin: false, daysAgo: 5),
  ];
}

String _heroLabelFor(int heroId) {
  return switch (heroId) {
    28 => 'Slardar',
    129 => 'Mars',
    18 => 'Sven',
    777 => 'Hero 777',
    _ => 'Hero $heroId',
  };
}

ComfortCoreSummary _comfortCoreSummary() {
  return const ComfortCoreSummary(
    conclusionType: ComfortCoreConclusionType.successInsideCore,
    conclusion: 'Most of your recent success is inside a small comfort core.',
    totalMatches: 9,
    minimumMatches: 5,
    topHeroes: [
      ComfortCoreHeroUsage(heroId: 28, matches: 3),
      ComfortCoreHeroUsage(heroId: 129, matches: 3),
    ],
    topHeroWins: 4,
    topHeroLosses: 2,
    otherHeroWins: 1,
    otherHeroLosses: 2,
  );
}

SessionPlan _sessionPlan({required List<int> heroIds}) {
  return SessionPlan(
    queue: 'Carry only',
    heroBlock: heroIds.map(_heroLabelFor).join(' + '),
    target: 'stay inside the block',
    reviewWindow: 'next 5 games',
    targetType: SessionPlanTargetType.comfortBlock,
    heroBlockHeroIds: heroIds,
  );
}

BlockReview _blockReview() {
  return const BlockReview(
    blockStatus: BlockReviewStatus.completed,
    gamesLogged: 5,
    blockSize: 5,
    adherence: BlockReviewAdherence.stayedInsideBlock,
    targetResult: BlockReviewTargetResult.improved,
    overallOutcome: BlockReviewOutcome.onTrack,
  );
}

CoachingCheckpoint _checkpoint({
  CoachingCheckpointHeroBlock? focusHeroBlock,
  List<CoachingCheckpointMatchSummary> recentMatchesWindow = const [],
}) {
  return CoachingCheckpoint(
    accountId: 86745912,
    savedAt: DateTime.utc(2026, 3, 20, 10),
    focusAction: 'Focus action',
    focusSourceLabel: 'Focus source',
    topInsightType: null,
    focusHeroBlock: focusHeroBlock,
    sample: CoachingCheckpointSample(
      matchesAnalyzed: 10,
      wins: 6,
      losses: 4,
      winRate: 0.6,
      uniqueHeroesPlayed: 4,
      averageDeaths: 5.4,
      likelyRoleSummaryLabel: 'Carry',
      roleEstimateStrengthLabel: 'Strong estimate',
      hasClearRoleEstimate: true,
      primaryRoleKey: 'carry',
      recentMatchesWindow: recentMatchesWindow,
    ),
  );
}

RecentMatch _match({
  required int matchId,
  required int heroId,
  required bool didWin,
  required int daysAgo,
  int kills = 6,
  int deaths = 4,
  int assists = 8,
}) {
  return RecentMatch(
    matchId: matchId,
    heroId: heroId,
    startedAt: DateTime(2026, 3, 31, 18).subtract(Duration(days: daysAgo)),
    duration: const Duration(minutes: 34),
    kills: kills,
    deaths: deaths,
    assists: assists,
    didWin: didWin,
    partySize: 1,
  );
}

RecentMatch _matchAt({
  required int matchId,
  required int heroId,
  required bool didWin,
  required DateTime startedAt,
}) {
  return RecentMatch(
    matchId: matchId,
    heroId: heroId,
    startedAt: startedAt,
    duration: const Duration(minutes: 34),
    kills: 6,
    deaths: 4,
    assists: 8,
    didWin: didWin,
    partySize: 1,
  );
}
