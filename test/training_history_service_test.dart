import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/dashboard/domain/models/training_history.dart';
import 'package:dotes/src/features/dashboard/domain/services/training_history_service.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TrainingHistoryService();

  group('TrainingHistoryService', () {
    test('builds multiple recent coaching cycles in deterministic order', () {
      final history = service.build([
        _checkpoint(
          savedAt: DateTime.utc(2025, 3, 20),
          focusSourceLabel: 'Early death risk',
          topInsightType: CoachingInsightType.earlyDeathRisk,
          averageDeaths: 7.2,
        ),
        _checkpoint(
          savedAt: DateTime.utc(2025, 3, 21),
          focusSourceLabel: 'Hero pool spread',
          topInsightType: CoachingInsightType.heroPoolSpread,
          uniqueHeroesPlayed: 3,
          averageDeaths: 5.8,
        ),
        _checkpoint(
          savedAt: DateTime.utc(2025, 3, 22),
          focusSourceLabel: 'Weak recent trend',
          topInsightType: CoachingInsightType.weakRecentTrend,
          uniqueHeroesPlayed: 5,
          averageDeaths: 6.1,
        ),
      ]);

      expect(history.hasEntries, isTrue);
      expect(history.entries, hasLength(2));
      expect(history.entries.first.focusLabel, 'Hero pool spread');
      expect(
        history.entries.first.resultSummary,
        'Hero pool widened instead of narrowing.',
      );
      expect(history.entries.last.focusLabel, 'Early death risk');
      expect(
        history.entries.last.resultSummary,
        'Deaths improved from 7.2 to 5.8.',
      );
    });

    test('generates named hero-block summaries', () {
      final history = service.build([
        _checkpoint(
          savedAt: DateTime.utc(2025, 3, 20),
          focusSourceLabel: 'Comfort hero dependence',
          topInsightType: CoachingInsightType.comfortHeroDependence,
          focusHeroBlock: const CoachingCheckpointHeroBlock(
            heroIds: [28, 129],
            heroLabels: ['Slardar', 'Mars'],
            wins: 3,
            losses: 2,
          ),
        ),
        _checkpoint(
          savedAt: DateTime.utc(2025, 3, 21),
          focusSourceLabel: 'Comfort hero dependence',
          topInsightType: CoachingInsightType.comfortHeroDependence,
          recentMatchesWindow: const [
            CoachingCheckpointMatchSummary(heroId: 28, didWin: true),
            CoachingCheckpointMatchSummary(heroId: 129, didWin: true),
            CoachingCheckpointMatchSummary(heroId: 28, didWin: false),
            CoachingCheckpointMatchSummary(heroId: 53, didWin: false),
            CoachingCheckpointMatchSummary(heroId: 129, didWin: true),
          ],
        ),
      ]);

      expect(history.entries, hasLength(1));
      expect(history.entries.first.outcome, TrainingCycleOutcome.onTrack);
      expect(
        history.entries.first.resultSummary,
        'Stayed inside Slardar + Mars in 4 of 5 games.',
      );
    });

    test('returns a calm fallback when no completed history exists', () {
      final history = service.build([
        _checkpoint(
          savedAt: DateTime.utc(2025, 3, 20),
          focusSourceLabel: 'Limited confidence',
          topInsightType: CoachingInsightType.limitedConfidence,
          matchesAnalyzed: 4,
        ),
      ]);

      expect(history.entries, isEmpty);
      expect(
        history.fallbackMessage,
        'No completed cycles yet \u2014 finish your first 5-game block to see history here.',
      );
    });

    test('populates deathsAverage and winRatePercent when matchesAnalyzed >= 5',
        () {
      final history = service.build([
        _checkpoint(
          savedAt: DateTime.utc(2025, 3, 20),
          focusSourceLabel: 'Early death risk',
          topInsightType: CoachingInsightType.earlyDeathRisk,
          averageDeaths: 7.2,
          matchesAnalyzed: 10,
          wins: 6,
        ),
        _checkpoint(
          savedAt: DateTime.utc(2025, 3, 21),
          focusSourceLabel: 'Early death risk',
          topInsightType: CoachingInsightType.earlyDeathRisk,
          averageDeaths: 5.8,
          matchesAnalyzed: 10,
          wins: 7,
        ),
      ]);

      expect(history.entries, hasLength(1));
      expect(history.entries.first.deathsAverage, closeTo(5.8, 0.001));
      expect(history.entries.first.winRatePercent, closeTo(70.0, 0.001));
    });

    test('deathsAverage and winRatePercent are null when matchesAnalyzed < 5',
        () {
      final history = service.build([
        _checkpoint(
          savedAt: DateTime.utc(2025, 3, 20),
          focusSourceLabel: 'Limited confidence',
          topInsightType: CoachingInsightType.limitedConfidence,
          matchesAnalyzed: 4,
          wins: 2,
          losses: 2,
          averageDeaths: 6.0,
        ),
        _checkpoint(
          savedAt: DateTime.utc(2025, 3, 21),
          focusSourceLabel: 'Limited confidence',
          topInsightType: CoachingInsightType.limitedConfidence,
          matchesAnalyzed: 4,
          wins: 3,
          losses: 1,
          averageDeaths: 5.0,
        ),
      ]);

      expect(history.entries, hasLength(1));
      expect(history.entries.first.deathsAverage, isNull);
      expect(history.entries.first.winRatePercent, isNull);
    });

    test('keeps output deterministic for the same checkpoint list', () {
      final checkpoints = [
        _checkpoint(
          savedAt: DateTime.utc(2025, 3, 20),
          focusSourceLabel: 'Early death risk',
          topInsightType: CoachingInsightType.earlyDeathRisk,
          averageDeaths: 7.2,
        ),
        _checkpoint(
          savedAt: DateTime.utc(2025, 3, 21),
          focusSourceLabel: 'Hero pool spread',
          topInsightType: CoachingInsightType.heroPoolSpread,
          uniqueHeroesPlayed: 3,
          averageDeaths: 5.8,
        ),
      ];

      final firstPass = service.build(checkpoints);
      final secondPass = service.build(checkpoints);

      expect(
        firstPass.entries.first.focusLabel,
        secondPass.entries.first.focusLabel,
      );
      expect(
        firstPass.entries.first.resultSummary,
        secondPass.entries.first.resultSummary,
      );
      expect(firstPass.entries.first.outcome, secondPass.entries.first.outcome);
    });
  });
}

CoachingCheckpoint _checkpoint({
  required DateTime savedAt,
  required String focusSourceLabel,
  required CoachingInsightType topInsightType,
  CoachingCheckpointHeroBlock? focusHeroBlock,
  int matchesAnalyzed = 10,
  int wins = 5,
  int losses = 5,
  int uniqueHeroesPlayed = 4,
  double averageDeaths = 6.5,
  List<CoachingCheckpointMatchSummary> recentMatchesWindow = const [
    CoachingCheckpointMatchSummary(heroId: 28, didWin: true),
    CoachingCheckpointMatchSummary(heroId: 129, didWin: false),
    CoachingCheckpointMatchSummary(heroId: 53, didWin: true),
    CoachingCheckpointMatchSummary(heroId: 54, didWin: false),
    CoachingCheckpointMatchSummary(heroId: 55, didWin: true),
  ],
}) {
  return CoachingCheckpoint(
    accountId: 86745912,
    savedAt: savedAt,
    focusAction: 'Focus action',
    focusSourceLabel: focusSourceLabel,
    topInsightType: topInsightType,
    focusHeroBlock: focusHeroBlock,
    sample: CoachingCheckpointSample(
      matchesAnalyzed: matchesAnalyzed,
      wins: wins,
      losses: losses,
      winRate: matchesAnalyzed == 0 ? 0 : wins / matchesAnalyzed,
      uniqueHeroesPlayed: uniqueHeroesPlayed,
      averageDeaths: averageDeaths,
      likelyRoleSummaryLabel: 'Core role leaning',
      roleEstimateStrengthLabel: 'Moderate estimate',
      hasClearRoleEstimate: true,
      primaryRoleKey: 'carry',
      recentMatchesWindow: recentMatchesWindow,
    ),
  );
}
