import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:dotes/src/features/progress/domain/models/focus_follow_through_check.dart';
import 'package:dotes/src/features/progress/domain/services/focus_follow_through_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = FocusFollowThroughService();

  group('FocusFollowThroughService', () {
    test(
      'returns on track when deaths improve against the last checkpoint focus',
      () {
        final followThroughCheck = service.build(
          previousCheckpoint: _checkpoint(
            topInsightType: CoachingInsightType.earlyDeathRisk,
            focusSourceLabel: 'Early death risk',
            averageDeaths: 7.4,
          ),
          currentSample: _sample(averageDeaths: 5.8),
        );

        expect(followThroughCheck.status, FocusFollowThroughStatus.onTrack);
        expect(followThroughCheck.previousFocusLabel, 'Early death risk');
        expect(
          followThroughCheck.comparisonLabel,
          'Compared against your last saved focus on reducing deaths.',
        );
        expect(
          followThroughCheck.detail,
          'Average deaths dropped from 7.4 to 5.8.',
        );
      },
    );

    test('returns mixed when hero-pool follow-through is flat', () {
      final followThroughCheck = service.build(
        previousCheckpoint: _checkpoint(
          topInsightType: CoachingInsightType.heroPoolSpread,
          focusSourceLabel: 'Hero pool spread',
          uniqueHeroesPlayed: 4,
        ),
        currentSample: _sample(uniqueHeroesPlayed: 4),
      );

      expect(followThroughCheck.status, FocusFollowThroughStatus.mixed);
      expect(followThroughCheck.previousFocusLabel, 'Hero pool spread');
      expect(
        followThroughCheck.comparisonLabel,
        'Compared against your last saved focus on narrowing your hero pool.',
      );
      expect(followThroughCheck.detail, 'Your hero pool stayed at 4 heroes.');
    });

    test('judges named hero-block focus as on track when the player stays inside it', () {
      final followThroughCheck = service.build(
        previousCheckpoint: _checkpoint(
          topInsightType: CoachingInsightType.comfortHeroDependence,
          focusSourceLabel: 'Comfort hero dependence',
          focusHeroBlock: _heroBlock(
            heroIds: const [28, 129],
            heroLabels: const ['Slardar', 'Mars'],
            wins: 3,
            losses: 2,
          ),
        ),
        currentSample: _sample(
          recentMatchesWindow: const [
            CoachingCheckpointMatchSummary(heroId: 28, didWin: true),
            CoachingCheckpointMatchSummary(heroId: 129, didWin: true),
            CoachingCheckpointMatchSummary(heroId: 28, didWin: false),
            CoachingCheckpointMatchSummary(heroId: 53, didWin: false),
            CoachingCheckpointMatchSummary(heroId: 129, didWin: true),
          ],
        ),
      );

      expect(followThroughCheck.status, FocusFollowThroughStatus.onTrack);
      expect(followThroughCheck.previousFocusLabel, 'Slardar + Mars block');
      expect(
        followThroughCheck.comparisonLabel,
        'Compared against your last saved focus on staying inside the Slardar + Mars block.',
      );
      expect(
        followThroughCheck.detail,
        'You stayed inside the Slardar + Mars block in 4 of the last 5 games. Results there improved from 60% to 75%.',
      );
    });

    test('judges named hero-block focus as mixed when the player partially drifts outside', () {
      final followThroughCheck = service.build(
        previousCheckpoint: _checkpoint(
          topInsightType: CoachingInsightType.comfortHeroDependence,
          focusSourceLabel: 'Comfort hero dependence',
          focusHeroBlock: _heroBlock(
            heroIds: const [28, 129],
            heroLabels: const ['Slardar', 'Mars'],
            wins: 3,
            losses: 2,
          ),
        ),
        currentSample: _sample(
          recentMatchesWindow: const [
            CoachingCheckpointMatchSummary(heroId: 28, didWin: true),
            CoachingCheckpointMatchSummary(heroId: 129, didWin: false),
            CoachingCheckpointMatchSummary(heroId: 53, didWin: true),
            CoachingCheckpointMatchSummary(heroId: 54, didWin: false),
            CoachingCheckpointMatchSummary(heroId: 28, didWin: true),
          ],
        ),
      );

      expect(followThroughCheck.status, FocusFollowThroughStatus.mixed);
      expect(
        followThroughCheck.detail,
        'You stayed inside the Slardar + Mars block in 3 of the last 5 games. That is too much drift to judge the trend cleanly.',
      );
    });

    test('judges named hero-block focus as off track when the player fully drifts outside', () {
      final followThroughCheck = service.build(
        previousCheckpoint: _checkpoint(
          topInsightType: CoachingInsightType.comfortHeroDependence,
          focusSourceLabel: 'Comfort hero dependence',
          focusHeroBlock: _heroBlock(
            heroIds: const [28, 129],
            heroLabels: const ['Slardar', 'Mars'],
            wins: 3,
            losses: 2,
          ),
        ),
        currentSample: _sample(
          recentMatchesWindow: const [
            CoachingCheckpointMatchSummary(heroId: 53, didWin: true),
            CoachingCheckpointMatchSummary(heroId: 54, didWin: false),
            CoachingCheckpointMatchSummary(heroId: 55, didWin: false),
            CoachingCheckpointMatchSummary(heroId: 56, didWin: true),
            CoachingCheckpointMatchSummary(heroId: 57, didWin: false),
          ],
        ),
      );

      expect(followThroughCheck.status, FocusFollowThroughStatus.offTrack);
      expect(
        followThroughCheck.detail,
        'You drifted outside the last recommended hero block.',
      );
    });

    test(
      'returns off track when the sample gets broader than the last stable-block checkpoint',
      () {
        final followThroughCheck = service.build(
          previousCheckpoint: _checkpoint(
            topInsightType: CoachingInsightType.specializationRecommendation,
            focusSourceLabel: 'Specialization recommendation',
            uniqueHeroesPlayed: 3,
            primaryRoleKey: 'carry',
            hasClearRoleEstimate: true,
          ),
          currentSample: _sample(
            uniqueHeroesPlayed: 6,
            primaryRoleKey: null,
            hasClearRoleEstimate: false,
          ),
        );

        expect(followThroughCheck.status, FocusFollowThroughStatus.offTrack);
        expect(
          followThroughCheck.previousFocusLabel,
          'Specialization recommendation',
        );
        expect(
          followThroughCheck.comparisonLabel,
          'Compared against your last saved focus on narrowing to one role and a small hero block.',
        );
        expect(
          followThroughCheck.detail,
          'Your hero pool widened from 3 heroes to 6 heroes, but your role pattern looks less consistent.',
        );
      },
    );

    test('returns a calm fallback when the checkpoint sample is too small', () {
      final followThroughCheck = service.build(
        previousCheckpoint: _checkpoint(
          matchesAnalyzed: 4,
          topInsightType: CoachingInsightType.limitedConfidence,
          focusSourceLabel: 'Limited confidence',
        ),
        currentSample: _sample(matchesAnalyzed: 10),
      );

      expect(followThroughCheck.isReady, isFalse);
      expect(followThroughCheck.previousFocusLabel, 'Limited confidence');
      expect(
        followThroughCheck.comparisonLabel,
        'Compared against your last saved focus on building a clearer sample before judging results.',
      );
      expect(
        followThroughCheck.fallbackMessage,
        'Need a bigger block before judging follow-through.',
      );
    });

    test('keeps generic hero-pool judgment when no previous hero-specific block was stored', () {
      final followThroughCheck = service.build(
        previousCheckpoint: _checkpoint(
          topInsightType: CoachingInsightType.comfortHeroDependence,
          focusSourceLabel: 'Comfort hero dependence',
          uniqueHeroesPlayed: 4,
        ),
        currentSample: _sample(uniqueHeroesPlayed: 4),
      );

      expect(followThroughCheck.status, FocusFollowThroughStatus.mixed);
      expect(
        followThroughCheck.comparisonLabel,
        'Compared against your last saved focus on leaning into your comfort heroes.',
      );
      expect(followThroughCheck.detail, 'Your hero pool stayed at 4 heroes.');
    });

    test('uses different explanation lines for different focus sources', () {
      final deathsCheck = service.build(
        previousCheckpoint: _checkpoint(
          topInsightType: CoachingInsightType.earlyDeathRisk,
          focusSourceLabel: 'Early death risk',
        ),
        currentSample: _sample(),
      );
      final heroPoolCheck = service.build(
        previousCheckpoint: _checkpoint(
          topInsightType: CoachingInsightType.heroPoolSpread,
          focusSourceLabel: 'Hero pool spread',
        ),
        currentSample: _sample(),
      );
      final specializationCheck = service.build(
        previousCheckpoint: _checkpoint(
          topInsightType: CoachingInsightType.specializationRecommendation,
          focusSourceLabel: 'Specialization recommendation',
        ),
        currentSample: _sample(),
      );

      expect(
        deathsCheck.comparisonLabel,
        'Compared against your last saved focus on reducing deaths.',
      );
      expect(
        heroPoolCheck.comparisonLabel,
        'Compared against your last saved focus on narrowing your hero pool.',
      );
      expect(
        specializationCheck.comparisonLabel,
        'Compared against your last saved focus on narrowing to one role and a small hero block.',
      );
      expect(deathsCheck.comparisonLabel, isNot(heroPoolCheck.comparisonLabel));
      expect(
        heroPoolCheck.comparisonLabel,
        isNot(specializationCheck.comparisonLabel),
      );
    });
  });
}

CoachingCheckpoint _checkpoint({
  CoachingInsightType? topInsightType,
  String focusSourceLabel = 'Focus source',
  int matchesAnalyzed = 10,
  int uniqueHeroesPlayed = 5,
  double averageDeaths = 6.5,
  bool hasClearRoleEstimate = true,
  String? primaryRoleKey = 'carry',
  CoachingCheckpointHeroBlock? focusHeroBlock,
  List<CoachingCheckpointMatchSummary> recentMatchesWindow = const [],
}) {
  return CoachingCheckpoint(
    accountId: 86745912,
    savedAt: DateTime.utc(2025, 3, 21),
    focusAction: 'Focus action',
    focusSourceLabel: focusSourceLabel,
    topInsightType: topInsightType,
    focusHeroBlock: focusHeroBlock,
    sample: CoachingCheckpointSample(
      matchesAnalyzed: matchesAnalyzed,
      wins: 4,
      losses: matchesAnalyzed - 4,
      winRate: matchesAnalyzed == 0 ? 0 : 4 / matchesAnalyzed,
      uniqueHeroesPlayed: uniqueHeroesPlayed,
      averageDeaths: averageDeaths,
      likelyRoleSummaryLabel: hasClearRoleEstimate
          ? 'Core role leaning'
          : 'Mixed / still estimating',
      roleEstimateStrengthLabel: hasClearRoleEstimate
          ? 'Moderate estimate'
          : 'Low-confidence estimate',
      hasClearRoleEstimate: hasClearRoleEstimate,
      primaryRoleKey: primaryRoleKey,
      recentMatchesWindow: recentMatchesWindow,
    ),
  );
}

CoachingCheckpointSample _sample({
  int matchesAnalyzed = 10,
  int uniqueHeroesPlayed = 5,
  double averageDeaths = 6.5,
  bool hasClearRoleEstimate = true,
  String? primaryRoleKey = 'carry',
  List<CoachingCheckpointMatchSummary> recentMatchesWindow = const [
    CoachingCheckpointMatchSummary(heroId: 28, didWin: true),
    CoachingCheckpointMatchSummary(heroId: 129, didWin: false),
    CoachingCheckpointMatchSummary(heroId: 28, didWin: true),
    CoachingCheckpointMatchSummary(heroId: 53, didWin: false),
    CoachingCheckpointMatchSummary(heroId: 129, didWin: true),
  ],
}) {
  return CoachingCheckpointSample(
    matchesAnalyzed: matchesAnalyzed,
    wins: 5,
    losses: matchesAnalyzed - 5,
    winRate: matchesAnalyzed == 0 ? 0 : 5 / matchesAnalyzed,
    uniqueHeroesPlayed: uniqueHeroesPlayed,
    averageDeaths: averageDeaths,
    likelyRoleSummaryLabel: hasClearRoleEstimate
        ? 'Core role leaning'
        : 'Mixed / still estimating',
    roleEstimateStrengthLabel: hasClearRoleEstimate
        ? 'Moderate estimate'
        : 'Low-confidence estimate',
    hasClearRoleEstimate: hasClearRoleEstimate,
    primaryRoleKey: primaryRoleKey,
    recentMatchesWindow: recentMatchesWindow,
  );
}

CoachingCheckpointHeroBlock _heroBlock({
  required List<int> heroIds,
  required List<String> heroLabels,
  required int wins,
  required int losses,
}) {
  return CoachingCheckpointHeroBlock(
    heroIds: heroIds,
    heroLabels: heroLabels,
    wins: wins,
    losses: losses,
  );
}
