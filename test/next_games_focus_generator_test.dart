import 'package:dotes/src/features/dashboard/domain/models/comfort_core_summary.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:dotes/src/features/insights/domain/services/next_games_focus_generator.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/roles/domain/models/player_role.dart';
import 'package:dotes/src/features/roles/domain/models/role_confidence.dart';
import 'package:dotes/src/features/roles/domain/models/sample_role_summary.dart';
import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = NextGamesFocusGenerator();

  group('NextGamesFocusGenerator', () {
    test('names real heroes when the comfort core is strong enough', () {
      final focus = generator.generate(
        [_comfortInsight()],
        _clearRoleSummary(),
        comfortCore: _comfortCore(
          conclusionType: ComfortCoreConclusionType.successInsideCore,
          topHeroes: const [
            ComfortCoreHeroUsage(heroId: 28, matches: 3),
            ComfortCoreHeroUsage(heroId: 129, matches: 2),
          ],
        ),
        heroLabelFor: _heroLabelFor,
      );

      expect(focus.sourceType, CoachingInsightType.comfortHeroDependence);
      expect(focus.action, 'Play your next 5 games on Slardar and Mars.');
      expect(focus.heroBlock, isNotNull);
      expect(focus.heroBlock!.heroIds, [28, 129]);
      expect(focus.heroBlock!.heroLabels, ['Slardar', 'Mars']);
      expect(focus.heroBlock!.wins, 4);
      expect(focus.heroBlock!.losses, 1);
    });

    test('falls back to generic wording when the comfort core is weak', () {
      final focus = generator.generate(
        [_comfortInsight()],
        _clearRoleSummary(),
        comfortCore: _comfortCore(
          conclusionType: ComfortCoreConclusionType.noClearCore,
          topHeroes: const [
            ComfortCoreHeroUsage(heroId: 28, matches: 2),
            ComfortCoreHeroUsage(heroId: 129, matches: 2),
          ],
        ),
        heroLabelFor: _heroLabelFor,
      );

      expect(focus.sourceType, CoachingInsightType.comfortHeroDependence);
      expect(
        focus.action,
        'Play all 5 Carry games on your top 1-2 comfort heroes and compare the results there.',
      );
      expect(focus.heroBlock, isNull);
    });

    test('keeps the tiny sample fallback when the comfort core is not ready', () {
      final focus = generator.generate(
        [_limitedConfidenceInsight()],
        _roleSummary(readType: SampleRoleReadType.smallSample),
        comfortCore: _comfortCore(
          conclusionType: ComfortCoreConclusionType.tinySample,
          topHeroes: const [],
        ),
        heroLabelFor: _heroLabelFor,
      );

      expect(focus.sourceType, CoachingInsightType.limitedConfidence);
      expect(
        focus.action,
        'Play 5 more games on one role and a 2-hero block before judging this sample.',
      );
      expect(focus.confidenceLabel, 'Low confidence');
      expect(focus.reasonLabel, 'Sample is still thin.');
      expect(focus.heroBlock, isNull);
    });

    test('keeps output deterministic for the same comfort summary', () {
      final comfortCore = _comfortCore(
        conclusionType: ComfortCoreConclusionType.successInsideCore,
        topHeroes: const [
          ComfortCoreHeroUsage(heroId: 28, matches: 3),
          ComfortCoreHeroUsage(heroId: 129, matches: 2),
        ],
      );

      final firstPass = generator.generate(
        [_comfortInsight()],
        _clearRoleSummary(),
        comfortCore: comfortCore,
        heroLabelFor: _heroLabelFor,
      );
      final secondPass = generator.generate(
        [_comfortInsight()],
        _clearRoleSummary(),
        comfortCore: comfortCore,
        heroLabelFor: _heroLabelFor,
      );

      expect(firstPass.action, secondPass.action);
      expect(firstPass.sourceLabel, secondPass.sourceLabel);
      expect(firstPass.heroBlock!.heroIds, secondPass.heroBlock!.heroIds);
    });

    test('auto mode leaves the current automatic focus behavior unchanged', () {
      final focus = generator.generate(
        [_limitedConfidenceInsight()],
        _roleSummary(readType: SampleRoleReadType.smallSample),
        comfortCore: _comfortCore(
          conclusionType: ComfortCoreConclusionType.tinySample,
          topHeroes: const [],
        ),
        heroLabelFor: _heroLabelFor,
        trainingPreferences: const TrainingPreferences(
          coachingMode: TrainingCoachingMode.followAppRead,
          preferredRole: TrainingRolePreference.mid,
          lockedHeroIds: [28, 129],
        ),
      );

      expect(
        focus.action,
        'Play 5 more games on one role and a 2-hero block before judging this sample.',
      );
      expect(focus.heroBlock, isNull);
    });

    test('manual hero block sharpens focus when manual setup is active', () {
      final focus = generator.generate(
        [_limitedConfidenceInsight()],
        _roleSummary(readType: SampleRoleReadType.smallSample),
        comfortCore: _comfortCore(
          conclusionType: ComfortCoreConclusionType.tinySample,
          topHeroes: const [],
        ),
        recentMatches: [
          RecentMatch(
            matchId: 1,
            heroId: 28,
            startedAt: DateTime.utc(2025, 3, 20),
            duration: Duration(minutes: 30),
            kills: 5,
            deaths: 4,
            assists: 8,
            didWin: true,
            partySize: 1,
          ),
          RecentMatch(
            matchId: 2,
            heroId: 129,
            startedAt: DateTime.utc(2025, 3, 21),
            duration: Duration(minutes: 31),
            kills: 4,
            deaths: 5,
            assists: 10,
            didWin: false,
            partySize: 1,
          ),
        ],
        heroLabelFor: _heroLabelFor,
        trainingPreferences: const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          preferredRole: TrainingRolePreference.mid,
          lockedHeroIds: [28, 129],
        ),
      );

      expect(
        focus.action,
        'Play 5 more Mid games on Slardar and Mars before judging this sample.',
      );
      expect(focus.heroBlock, isNotNull);
      expect(focus.heroBlock!.heroIds, [28, 129]);
      expect(focus.heroBlock!.wins, 1);
      expect(focus.heroBlock!.losses, 1);
    });

    test('uses the role summary reason when there is no strong signal yet', () {
      final focus = generator.generate(
        const [],
        _roleSummary(readType: SampleRoleReadType.smallSample),
      );

      expect(focus.confidenceLabel, 'Conservative read');
      expect(
        focus.reasonLabel,
        'This sample is still small, so the current role estimate can move quickly over the next few matches.',
      );
    });

    test('steady coaching style softens the next-games focus wording', () {
      final focus = generator.generate(
        [_limitedConfidenceInsight()],
        _roleSummary(readType: SampleRoleReadType.smallSample),
        comfortCore: _comfortCore(
          conclusionType: ComfortCoreConclusionType.tinySample,
          topHeroes: const [],
        ),
        trainingPreferences: const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          coachingStyle: TrainingCoachingStyle.steady,
        ),
      );

      expect(
        focus.action,
        'Keep the next block steady with 5 more games on one role and a 2-hero block before judging this sample.',
      );
    });

    test('direct coaching style shortens the next-games focus wording', () {
      final focus = generator.generate(
        [_comfortInsight()],
        _clearRoleSummary(),
        comfortCore: _comfortCore(
          conclusionType: ComfortCoreConclusionType.successInsideCore,
          topHeroes: const [
            ComfortCoreHeroUsage(heroId: 28, matches: 3),
            ComfortCoreHeroUsage(heroId: 129, matches: 2),
          ],
        ),
        heroLabelFor: _heroLabelFor,
        trainingPreferences: const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          coachingStyle: TrainingCoachingStyle.direct,
        ),
      );

      expect(focus.action, 'Run the next block on Slardar and Mars.');
    });
  });
}

CoachingInsight _comfortInsight() {
  return const CoachingInsight(
    type: CoachingInsightType.comfortHeroDependence,
    title: 'Comfort hero dependence',
    explanation: 'Comfort core is doing the heavy lifting.',
    severity: CoachingInsightSeverity.medium,
    confidence: CoachingInsightConfidence.high,
  );
}

CoachingInsight _limitedConfidenceInsight() {
  return const CoachingInsight(
    type: CoachingInsightType.limitedConfidence,
    title: 'Limited confidence',
    explanation: 'Sample is still thin.',
    severity: CoachingInsightSeverity.low,
    confidence: CoachingInsightConfidence.low,
  );
}

ComfortCoreSummary _comfortCore({
  required ComfortCoreConclusionType conclusionType,
  required List<ComfortCoreHeroUsage> topHeroes,
}) {
  return ComfortCoreSummary(
    conclusionType: conclusionType,
    conclusion: 'Conclusion',
    totalMatches: conclusionType == ComfortCoreConclusionType.tinySample
        ? 4
        : 7,
    minimumMatches: 5,
    topHeroes: topHeroes,
    topHeroWins: 4,
    topHeroLosses: 1,
    otherHeroWins: 0,
    otherHeroLosses: 2,
  );
}

String _heroLabelFor(int heroId) {
  return switch (heroId) {
    28 => 'Slardar',
    129 => 'Mars',
    _ => 'Hero $heroId',
  };
}

SampleRoleSummary _clearRoleSummary() {
  return _roleSummary(
    primaryRole: PlayerRole.carry,
    confidence: RoleConfidence.high,
    readType: SampleRoleReadType.clear,
    distribution: const {
      PlayerRole.carry: 5,
      PlayerRole.mid: 1,
      PlayerRole.offlane: 1,
      PlayerRole.softSupport: 0,
      PlayerRole.hardSupport: 0,
      PlayerRole.unknown: 0,
    },
  );
}

SampleRoleSummary _roleSummary({
  PlayerRole primaryRole = PlayerRole.unknown,
  RoleConfidence confidence = RoleConfidence.low,
  SampleRoleReadType readType = SampleRoleReadType.mixedRoles,
  Map<PlayerRole, int>? distribution,
}) {
  return SampleRoleSummary(
    primaryRole: primaryRole,
    primaryRoleConfidence: confidence,
    readType: readType,
    roleDistribution:
        distribution ??
        const {
          PlayerRole.carry: 0,
          PlayerRole.mid: 0,
          PlayerRole.offlane: 0,
          PlayerRole.softSupport: 0,
          PlayerRole.hardSupport: 0,
          PlayerRole.unknown: 6,
        },
  );
}
