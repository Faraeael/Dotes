import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:dotes/src/features/insights/domain/services/coaching_insights_analyzer.dart';
import 'package:dotes/src/features/insights/domain/services/next_games_focus_generator.dart';
import 'package:dotes/src/features/player_import/domain/models/imported_player_data.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/roles/domain/models/player_role.dart';
import 'package:dotes/src/features/roles/domain/models/role_confidence.dart';
import 'package:dotes/src/features/roles/domain/models/sample_role_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const analyzer = CoachingInsightsAnalyzer();
  const focusGenerator = NextGamesFocusGenerator();

  group('CoachingInsightsAnalyzer', () {
    test('returns limited confidence for small samples', () {
      final insights = analyzer.analyze(
        _playerData([
          _match(heroId: 1, didWin: true),
          _match(heroId: 1, didWin: false),
          _match(heroId: 2, didWin: true),
        ]),
        _roleSummary(readType: SampleRoleReadType.smallSample),
      );

      expect(insights, hasLength(1));
      expect(insights.first.type, CoachingInsightType.limitedConfidence);
      expect(insights.first.confidence, CoachingInsightConfidence.low);
      expect(
        focusGenerator.generate(
          insights,
          _roleSummary(readType: SampleRoleReadType.smallSample),
        ).action,
        contains('5 more games'),
      );
    });

    test('detects hero pool spread in a wide recent sample', () {
      final insights = analyzer.analyze(
        _playerData([
          _match(heroId: 1),
          _match(heroId: 2),
          _match(heroId: 3),
          _match(heroId: 4),
          _match(heroId: 5),
          _match(heroId: 6),
          _match(heroId: 1),
          _match(heroId: 2),
        ]),
        _roleSummary(
          primaryRole: PlayerRole.carry,
          confidence: RoleConfidence.medium,
          readType: SampleRoleReadType.clear,
          distribution: const {
            PlayerRole.carry: 5,
            PlayerRole.mid: 1,
            PlayerRole.offlane: 1,
            PlayerRole.softSupport: 1,
            PlayerRole.hardSupport: 0,
            PlayerRole.unknown: 0,
          },
        ),
      );

      expect(
        insights.any(
          (insight) => insight.type == CoachingInsightType.heroPoolSpread,
        ),
        isTrue,
      );
      expect(
        insights.any(
          (insight) =>
              insight.type == CoachingInsightType.specializationRecommendation,
        ),
        isFalse,
      );
    });

    test('detects weak recent trend from low win rate', () {
      final insights = analyzer.analyze(
        _playerData([
          _match(didWin: false),
          _match(didWin: false),
          _match(didWin: false),
          _match(didWin: false),
          _match(didWin: true),
          _match(didWin: false),
        ]),
        _clearRoleSummary(),
      );

      final weakTrend = insights.firstWhere(
        (insight) => insight.type == CoachingInsightType.weakRecentTrend,
      );

      expect(weakTrend.severity, CoachingInsightSeverity.high);
      expect(weakTrend.explanation, contains('17%'));
    });

    test('detects comfort hero dependence when wins cluster on two heroes', () {
      final insights = analyzer.analyze(
        _playerData([
          _match(heroId: 1, didWin: true),
          _match(heroId: 1, didWin: true),
          _match(heroId: 1, didWin: false),
          _match(heroId: 2, didWin: true),
          _match(heroId: 2, didWin: true),
          _match(heroId: 3, didWin: false),
          _match(heroId: 4, didWin: false),
        ]),
        _clearRoleSummary(),
      );

      expect(
        insights.any(
          (insight) =>
              insight.type == CoachingInsightType.comfortHeroDependence,
        ),
        isTrue,
      );
    });

    test('detects early death risk from repeated high-death matches', () {
      final insights = analyzer.analyze(
        _playerData([
          _match(deaths: 9),
          _match(deaths: 8),
          _match(deaths: 10),
          _match(deaths: 7),
          _match(deaths: 9),
          _match(deaths: 8),
        ]),
        _clearRoleSummary(),
      );

      expect(
        insights.any(
          (insight) => insight.type == CoachingInsightType.earlyDeathRisk,
        ),
        isTrue,
      );
    });

    test('returns deterministic ordering for mixed signals', () {
      final sample = _playerData([
        _match(heroId: 1, didWin: false, deaths: 9),
        _match(heroId: 2, didWin: false, deaths: 8),
        _match(heroId: 3, didWin: false, deaths: 10),
        _match(heroId: 4, didWin: true, deaths: 9),
        _match(heroId: 5, didWin: false, deaths: 8),
        _match(heroId: 6, didWin: false, deaths: 7),
        _match(heroId: 1, didWin: false, deaths: 9),
        _match(heroId: 2, didWin: false, deaths: 8),
      ]);
      final roleSummary = _clearRoleSummary();

      final firstPass = analyzer.analyze(sample, roleSummary);
      final secondPass = analyzer.analyze(sample, roleSummary);

      expect(
        firstPass.map((insight) => insight.type).toList(),
        secondPass.map((insight) => insight.type).toList(),
      );
      expect(
        firstPass.take(3).map((insight) => insight.type).toList(),
        [
          CoachingInsightType.weakRecentTrend,
          CoachingInsightType.earlyDeathRisk,
          CoachingInsightType.heroPoolSpread,
        ],
      );
    });

    test('uses the top insight to generate the next 5 games focus', () {
      final insights = analyzer.analyze(
        _playerData([
          _match(heroId: 1, didWin: false, deaths: 9),
          _match(heroId: 2, didWin: false, deaths: 8),
          _match(heroId: 3, didWin: false, deaths: 10),
          _match(heroId: 4, didWin: true, deaths: 9),
          _match(heroId: 5, didWin: false, deaths: 8),
          _match(heroId: 6, didWin: false, deaths: 7),
          _match(heroId: 1, didWin: false, deaths: 9),
          _match(heroId: 2, didWin: false, deaths: 8),
        ]),
        _clearRoleSummary(),
      );

      final focus = focusGenerator.generate(insights, _clearRoleSummary());

      expect(focus.sourceType, CoachingInsightType.weakRecentTrend);
      expect(focus.action, 'Stay on Carry for all 5 games and keep the hero block to 2 picks.');
    });

    test('returns a stable fallback focus when no insights fire', () {
      final insights = analyzer.analyze(
        _playerData([
          _match(heroId: 1, didWin: true, deaths: 4),
          _match(heroId: 1, didWin: false, deaths: 5),
          _match(heroId: 2, didWin: false, deaths: 4),
          _match(heroId: 2, didWin: false, deaths: 5),
          _match(heroId: 3, didWin: true, deaths: 4),
          _match(heroId: 3, didWin: false, deaths: 4),
          _match(heroId: 4, didWin: true, deaths: 4),
        ]),
        _clearRoleSummary(),
      );

      final focus = focusGenerator.generate(insights, _clearRoleSummary());

      expect(insights, isEmpty);
      expect(focus.sourceType, isNull);
      expect(focus.sourceLabel, 'No strong signal yet');
      expect(
        focus.action,
        'Play the next 5 games on Carry and no more than 2 heroes.',
      );
    });

    test('adds specialization recommendation for broad mixed samples', () {
      final insights = analyzer.analyze(
        _playerData([
          _match(heroId: 1),
          _match(heroId: 2),
          _match(heroId: 3),
          _match(heroId: 4),
          _match(heroId: 5),
          _match(heroId: 6),
          _match(heroId: 1),
          _match(heroId: 2),
        ]),
        _roleSummary(
          readType: SampleRoleReadType.mixedRoles,
          distribution: const {
            PlayerRole.carry: 2,
            PlayerRole.mid: 2,
            PlayerRole.offlane: 2,
            PlayerRole.softSupport: 1,
            PlayerRole.hardSupport: 1,
            PlayerRole.unknown: 0,
          },
        ),
      );

      expect(
        insights.any(
          (insight) =>
              insight.type == CoachingInsightType.specializationRecommendation,
        ),
        isTrue,
      );
      expect(
        insights.any(
          (insight) => insight.type == CoachingInsightType.heroPoolSpread,
        ),
        isFalse,
      );
    });

    test('does not add specialization recommendation in tiny samples', () {
      final insights = analyzer.analyze(
        _playerData([
          _match(heroId: 1),
          _match(heroId: 2),
          _match(heroId: 3),
          _match(heroId: 4),
        ]),
        _roleSummary(readType: SampleRoleReadType.smallSample),
      );

      expect(insights, hasLength(1));
      expect(insights.first.type, CoachingInsightType.limitedConfidence);
      expect(
        insights.any(
          (insight) =>
              insight.type == CoachingInsightType.specializationRecommendation,
        ),
        isFalse,
      );
    });

    test('uses specialization recommendation to generate focus', () {
      final insights = analyzer.analyze(
        _playerData([
          _match(heroId: 1, didWin: true),
          _match(heroId: 2, didWin: false),
          _match(heroId: 3, didWin: true),
          _match(heroId: 4, didWin: false),
          _match(heroId: 5, didWin: true),
          _match(heroId: 6, didWin: false),
          _match(heroId: 1, didWin: true),
          _match(heroId: 2, didWin: false),
        ]),
        _roleSummary(
          readType: SampleRoleReadType.mixedRoles,
          distribution: const {
            PlayerRole.carry: 2,
            PlayerRole.mid: 2,
            PlayerRole.offlane: 2,
            PlayerRole.softSupport: 1,
            PlayerRole.hardSupport: 1,
            PlayerRole.unknown: 0,
          },
        ),
      );

      final focus = focusGenerator.generate(
        insights,
        _roleSummary(
          readType: SampleRoleReadType.mixedRoles,
          distribution: const {
            PlayerRole.carry: 2,
            PlayerRole.mid: 2,
            PlayerRole.offlane: 2,
            PlayerRole.softSupport: 1,
            PlayerRole.hardSupport: 1,
            PlayerRole.unknown: 0,
          },
        ),
      );

      expect(
        insights.firstWhere(
          (insight) =>
              insight.type == CoachingInsightType.specializationRecommendation,
        ),
        isNotNull,
      );
      expect(focus.sourceType, CoachingInsightType.specializationRecommendation);
      expect(
        focus.action,
        'Queue one role only for 5 games and cap the block at 3 heroes.',
      );
    });

    test('uses a measurable deaths target for early death risk', () {
      final insights = analyzer.analyze(
        _playerData([
          _match(didWin: true, deaths: 9),
          _match(didWin: false, deaths: 8),
          _match(didWin: true, deaths: 10),
          _match(didWin: true, deaths: 7),
          _match(didWin: false, deaths: 9),
          _match(didWin: false, deaths: 8),
        ]),
        _clearRoleSummary(),
      );

      final focus = focusGenerator.generate(insights, _clearRoleSummary());

      expect(focus.sourceType, CoachingInsightType.earlyDeathRisk);
      expect(
        focus.action,
        'Keep deaths to 6 or fewer in each of the next 5 Carry games.',
      );
    });

    test('uses one core role wording when the role read is clear but not trusted', () {
      final roleSummary = _roleSummary(
        primaryRole: PlayerRole.carry,
        confidence: RoleConfidence.medium,
        readType: SampleRoleReadType.clear,
        distribution: const {
          PlayerRole.carry: 4,
          PlayerRole.mid: 2,
          PlayerRole.offlane: 1,
          PlayerRole.softSupport: 0,
          PlayerRole.hardSupport: 0,
          PlayerRole.unknown: 0,
        },
      );
      final insights = analyzer.analyze(
        _playerData([
          _match(heroId: 1, didWin: false),
          _match(heroId: 2, didWin: false),
          _match(heroId: 3, didWin: false),
          _match(heroId: 4, didWin: false),
          _match(heroId: 5, didWin: true),
          _match(heroId: 6, didWin: false),
          _match(heroId: 1, didWin: false),
        ]),
        roleSummary,
      );

      final focus = focusGenerator.generate(insights, roleSummary);

      expect(focus.sourceType, CoachingInsightType.weakRecentTrend);
      expect(focus.action, contains('one core role'));
      expect(focus.action, isNot(contains('Carry')));
    });

    test('uses generic wording when the role read is not trusted', () {
      final insights = analyzer.analyze(
        _playerData([
          _match(heroId: 1, didWin: true),
          _match(heroId: 2, didWin: false),
          _match(heroId: 3, didWin: true),
          _match(heroId: 4, didWin: false),
          _match(heroId: 5, didWin: true),
          _match(heroId: 6, didWin: false),
          _match(heroId: 1, didWin: true),
          _match(heroId: 2, didWin: false),
        ]),
        _roleSummary(
          readType: SampleRoleReadType.mixedRoles,
          distribution: const {
            PlayerRole.carry: 2,
            PlayerRole.mid: 2,
            PlayerRole.offlane: 2,
            PlayerRole.softSupport: 1,
            PlayerRole.hardSupport: 1,
            PlayerRole.unknown: 0,
          },
        ),
      );

      final focus = focusGenerator.generate(
        insights,
        _roleSummary(
          readType: SampleRoleReadType.mixedRoles,
          distribution: const {
            PlayerRole.carry: 2,
            PlayerRole.mid: 2,
            PlayerRole.offlane: 2,
            PlayerRole.softSupport: 1,
            PlayerRole.hardSupport: 1,
            PlayerRole.unknown: 0,
          },
        ),
      );

      expect(focus.action, isNot(contains('Carry')));
      expect(focus.action, contains('one role only'));
    });

    test('different top insights produce clearly different focus text', () {
      final deathInsights = analyzer.analyze(
        _playerData([
          _match(didWin: true, deaths: 9),
          _match(didWin: false, deaths: 8),
          _match(didWin: true, deaths: 10),
          _match(didWin: true, deaths: 7),
          _match(didWin: false, deaths: 9),
          _match(didWin: false, deaths: 8),
        ]),
        _clearRoleSummary(),
      );
      final comfortInsights = analyzer.analyze(
        _playerData([
          _match(heroId: 1, didWin: true),
          _match(heroId: 1, didWin: true),
          _match(heroId: 1, didWin: false),
          _match(heroId: 2, didWin: true),
          _match(heroId: 2, didWin: true),
          _match(heroId: 3, didWin: false),
          _match(heroId: 4, didWin: false),
        ]),
        _clearRoleSummary(),
      );

      final deathFocus = focusGenerator.generate(deathInsights, _clearRoleSummary());
      final comfortFocus = focusGenerator.generate(comfortInsights, _clearRoleSummary());

      expect(deathFocus.action, isNot(equals(comfortFocus.action)));
      expect(deathFocus.action, contains('6 or fewer'));
      expect(comfortFocus.action, contains('comfort heroes'));
    });
  });
}

ImportedPlayerData _playerData(List<RecentMatch> matches) {
  return ImportedPlayerData(
    profile: const PlayerProfileSummary(
      accountId: 86745912,
      personaName: 'Week 2 Player',
      avatarUrl: '',
    ),
    recentMatches: matches,
  );
}

RecentMatch _match({
  int heroId = 1,
  bool didWin = false,
  int deaths = 4,
}) {
  return RecentMatch(
    matchId: heroId * 1000 + deaths,
    heroId: heroId,
    startedAt: DateTime(2025, 3, 20, 18),
    duration: const Duration(minutes: 34),
    kills: 5,
    deaths: deaths,
    assists: 8,
    didWin: didWin,
    partySize: 1,
  );
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
