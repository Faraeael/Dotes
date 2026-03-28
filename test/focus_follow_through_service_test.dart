import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:dotes/src/features/progress/domain/models/focus_follow_through_check.dart';
import 'package:dotes/src/features/progress/domain/services/focus_follow_through_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = FocusFollowThroughService();

  group('FocusFollowThroughService', () {
    test('returns on track when deaths improve against the last checkpoint focus', () {
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
        'Average deaths are down since the last checkpoint.',
      );
    });

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
      expect(
        followThroughCheck.detail,
        'Hero usage looks steady since the last checkpoint.',
      );
    });

    test('returns off track when the sample gets broader than the last stable-block checkpoint', () {
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
      expect(followThroughCheck.previousFocusLabel, 'Specialization recommendation');
      expect(
        followThroughCheck.comparisonLabel,
        'Compared against your last saved focus on narrowing to one role and a small hero block.',
      );
      expect(
        followThroughCheck.detail,
        'Since the last checkpoint, the sample is broader on heroes and less consistent on role pattern.',
      );
    });

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
}) {
  return CoachingCheckpoint(
    accountId: 86745912,
    savedAt: DateTime.utc(2025, 3, 21),
    focusAction: 'Focus action',
    focusSourceLabel: focusSourceLabel,
    topInsightType: topInsightType,
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
    ),
  );
}

CoachingCheckpointSample _sample({
  int matchesAnalyzed = 10,
  int uniqueHeroesPlayed = 5,
  double averageDeaths = 6.5,
  bool hasClearRoleEstimate = true,
  String? primaryRoleKey = 'carry',
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
  );
}
