import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/dashboard/domain/models/comfort_core_summary.dart';
import 'package:dotes/src/features/dashboard/domain/services/dashboard_verdict_service.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:dotes/src/features/insights/domain/models/next_games_focus.dart';
import 'package:dotes/src/features/progress/domain/models/focus_follow_through_check.dart';
import 'package:dotes/src/features/progress/domain/models/progress_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = DashboardVerdictService();

  group('DashboardVerdictService', () {
    test('returns a strong negative signal only', () {
      final verdict = service.build(
        insights: [
          _insight(
            type: CoachingInsightType.heroPoolSpread,
            severity: CoachingInsightSeverity.high,
          ),
        ],
        nextGamesFocus: const NextGamesFocus(
          title: 'Next 5 games focus',
          action: 'Limit the next 5 games to 2 heroes.',
          sourceLabel: 'Hero pool spread',
          sourceType: CoachingInsightType.heroPoolSpread,
        ),
        comfortCore: _comfortCore(ComfortCoreConclusionType.noClearCore),
        progressCheck: const ProgressCheck.tooSmall(
          fallbackMessage: 'Need at least 10 recent matches.',
        ),
        followThroughCheck: const FocusFollowThroughCheck.waiting(
          fallbackMessage: 'No previous coaching checkpoint yet.',
        ),
        previousCheckpoint: null,
      );

      expect(
        verdict.biggestLeak?.message,
        'Your recent pool is still too wide.',
      );
      expect(verdict.biggestEdge, isNull);
      expect(verdict.fallbackMessage, isNull);
      expect(verdict.confidenceLabel, 'Conservative read');
      expect(
        verdict.reasonLabel,
        'This verdict is based on your strongest recent-match signal and stays conservative when the sample is broad.',
      );
    });

    test('returns a strong positive signal only', () {
      final verdict = service.build(
        insights: const [],
        nextGamesFocus: const NextGamesFocus(
          title: 'Next 5 games focus',
          action: 'Play your next 5 games on Slardar and Mars.',
          sourceLabel: 'Comfort hero dependence',
          sourceType: CoachingInsightType.comfortHeroDependence,
          heroBlock: NextGamesFocusHeroBlock(
            heroIds: [28, 129],
            heroLabels: ['Slardar', 'Mars'],
            wins: 4,
            losses: 1,
          ),
        ),
        comfortCore: null,
        progressCheck: null,
        followThroughCheck: FocusFollowThroughCheck.ready(
          status: FocusFollowThroughStatus.onTrack,
          detail:
              'You stayed inside the Slardar + Mars block in 4 of the last 5 games.',
          checkpointSavedAt: DateTime.utc(2025, 3, 21),
          previousFocusLabel: 'Slardar + Mars block',
          comparisonLabel:
              'Compared against your last saved focus on staying inside the Slardar + Mars block.',
        ),
        previousCheckpoint: _checkpoint(
          focusHeroBlock: const CoachingCheckpointHeroBlock(
            heroIds: [28, 129],
            heroLabels: ['Slardar', 'Mars'],
            wins: 4,
            losses: 1,
          ),
        ),
      );

      expect(
        verdict.biggestEdge?.message,
        'You stayed inside the last recommended hero block.',
      );
      expect(verdict.biggestLeak, isNull);
      expect(verdict.fallbackMessage, isNull);
    });

    test('returns both leak and edge when both are present', () {
      final verdict = service.build(
        insights: [
          _insight(
            type: CoachingInsightType.heroPoolSpread,
            severity: CoachingInsightSeverity.high,
          ),
        ],
        nextGamesFocus: const NextGamesFocus(
          title: 'Next 5 games focus',
          action:
              'Stay inside your top 2 hero block until the trend stabilizes.',
          sourceLabel: 'Comfort hero dependence',
          sourceType: CoachingInsightType.comfortHeroDependence,
        ),
        comfortCore: _comfortCore(ComfortCoreConclusionType.successInsideCore),
        progressCheck: const ProgressCheck.ready(
          blockSize: 5,
          comparisons: [
            ProgressMetricComparison(
              label: 'Win rate',
              direction: ProgressDirection.up,
              currentValueLabel: '60%',
              previousValueLabel: '40%',
            ),
          ],
        ),
        followThroughCheck: null,
        previousCheckpoint: null,
      );

      expect(
        verdict.biggestLeak?.message,
        'Your recent pool is still too wide.',
      );
      expect(
        verdict.biggestEdge?.message,
        'Your best results are inside a small comfort core.',
      );
      expect(verdict.fallbackMessage, isNull);
    });

    test('returns a calm fallback for weak or noisy samples', () {
      final verdict = service.build(
        insights: [
          _insight(
            type: CoachingInsightType.limitedConfidence,
            severity: CoachingInsightSeverity.low,
          ),
        ],
        nextGamesFocus: const NextGamesFocus(
          title: 'Next 5 games focus',
          action:
              'Play 5 more games on one role and a 2-hero block before judging this sample.',
          sourceLabel: 'Limited confidence',
          sourceType: CoachingInsightType.limitedConfidence,
        ),
        comfortCore: _comfortCore(ComfortCoreConclusionType.tinySample),
        progressCheck: const ProgressCheck.tooSmall(
          fallbackMessage: 'Need at least 10 recent matches.',
        ),
        followThroughCheck: const FocusFollowThroughCheck.waiting(
          fallbackMessage: 'Need a bigger block before judging follow-through.',
        ),
        previousCheckpoint: null,
      );

      expect(verdict.biggestLeak, isNull);
      expect(verdict.biggestEdge, isNull);
      expect(
        verdict.fallbackMessage,
        'Current sample is still too noisy for a strong verdict.',
      );
      expect(verdict.confidenceLabel, 'Limited confidence');
      expect(
        verdict.reasonLabel,
        'Current sample is still noisy, so the verdict is directional rather than final.',
      );
    });

    test('keeps verdict selection deterministic', () {
      final firstPass = service.build(
        insights: [
          _insight(
            type: CoachingInsightType.heroPoolSpread,
            severity: CoachingInsightSeverity.high,
          ),
        ],
        nextGamesFocus: const NextGamesFocus(
          title: 'Next 5 games focus',
          action:
              'Stay inside your top 2 hero block until the trend stabilizes.',
          sourceLabel: 'Comfort hero dependence',
          sourceType: CoachingInsightType.comfortHeroDependence,
        ),
        comfortCore: _comfortCore(ComfortCoreConclusionType.successInsideCore),
        progressCheck: const ProgressCheck.ready(
          blockSize: 5,
          comparisons: [
            ProgressMetricComparison(
              label: 'Win rate',
              direction: ProgressDirection.up,
              currentValueLabel: '60%',
              previousValueLabel: '40%',
            ),
          ],
        ),
        followThroughCheck: null,
        previousCheckpoint: null,
      );
      final secondPass = service.build(
        insights: [
          _insight(
            type: CoachingInsightType.heroPoolSpread,
            severity: CoachingInsightSeverity.high,
          ),
        ],
        nextGamesFocus: const NextGamesFocus(
          title: 'Next 5 games focus',
          action:
              'Stay inside your top 2 hero block until the trend stabilizes.',
          sourceLabel: 'Comfort hero dependence',
          sourceType: CoachingInsightType.comfortHeroDependence,
        ),
        comfortCore: _comfortCore(ComfortCoreConclusionType.successInsideCore),
        progressCheck: const ProgressCheck.ready(
          blockSize: 5,
          comparisons: [
            ProgressMetricComparison(
              label: 'Win rate',
              direction: ProgressDirection.up,
              currentValueLabel: '60%',
              previousValueLabel: '40%',
            ),
          ],
        ),
        followThroughCheck: null,
        previousCheckpoint: null,
      );

      expect(firstPass.biggestLeak?.message, secondPass.biggestLeak?.message);
      expect(firstPass.biggestEdge?.message, secondPass.biggestEdge?.message);
    });
  });
}

CoachingInsight _insight({
  required CoachingInsightType type,
  required CoachingInsightSeverity severity,
}) {
  return CoachingInsight(
    type: type,
    title: 'Signal',
    explanation: 'Explanation',
    severity: severity,
    confidence: CoachingInsightConfidence.high,
  );
}

ComfortCoreSummary _comfortCore(ComfortCoreConclusionType conclusionType) {
  return ComfortCoreSummary(
    conclusionType: conclusionType,
    conclusion: 'Conclusion',
    totalMatches: conclusionType == ComfortCoreConclusionType.tinySample
        ? 4
        : 7,
    minimumMatches: 5,
    topHeroes: const [
      ComfortCoreHeroUsage(heroId: 28, matches: 3),
      ComfortCoreHeroUsage(heroId: 129, matches: 2),
    ],
    topHeroWins: 4,
    topHeroLosses: 1,
    otherHeroWins: 0,
    otherHeroLosses: 2,
  );
}

CoachingCheckpoint _checkpoint({CoachingCheckpointHeroBlock? focusHeroBlock}) {
  return CoachingCheckpoint(
    accountId: 86745912,
    savedAt: DateTime.utc(2025, 3, 21),
    focusAction: 'Focus action',
    focusSourceLabel: 'Comfort hero dependence',
    topInsightType: CoachingInsightType.comfortHeroDependence,
    focusHeroBlock: focusHeroBlock,
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
