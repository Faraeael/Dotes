import 'package:dotes/src/features/dashboard/domain/models/comfort_core_summary.dart';
import 'package:dotes/src/features/dashboard/domain/models/dashboard_verdict.dart';
import 'package:dotes/src/features/dashboard/domain/models/session_plan.dart';
import 'package:dotes/src/features/dashboard/domain/services/session_plan_service.dart';
import 'package:dotes/src/features/insights/domain/models/coaching_insight.dart';
import 'package:dotes/src/features/insights/domain/models/next_games_focus.dart';
import 'package:dotes/src/features/progress/domain/models/focus_follow_through_check.dart';
import 'package:dotes/src/features/roles/domain/models/player_role.dart';
import 'package:dotes/src/features/roles/domain/models/role_confidence.dart';
import 'package:dotes/src/features/roles/domain/models/sample_role_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = SessionPlanService();

  group('SessionPlanService', () {
    test('builds a strong comfort-core plan', () {
      final plan = service.build(
        verdict: const DashboardVerdict(
          biggestEdge: DashboardVerdictLine(
            message: 'Your best results are inside a small comfort core.',
          ),
        ),
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
        comfortCore: _comfortCore(
          conclusionType: ComfortCoreConclusionType.successInsideCore,
        ),
        roleSummary: _trustedRoleSummary(),
        followThroughCheck: null,
        heroLabelFor: _heroLabelFor,
      );

      expect(plan.queue, 'Carry only');
      expect(plan.heroBlock, 'Slardar + Mars');
      expect(plan.target, 'stay inside the block');
      expect(plan.reviewWindow, 'next 5 games');
      expect(plan.targetType, SessionPlanTargetType.comfortBlock);
      expect(plan.heroBlockHeroIds, [28, 129]);
      expect(plan.roleBlockKey, 'carry');
    });

    test('builds a death-reduction plan', () {
      final plan = service.build(
        verdict: const DashboardVerdict(
          biggestLeak: DashboardVerdictLine(
            message: 'Deaths are still above the current focus target.',
          ),
          biggestEdge: DashboardVerdictLine(
            message: 'Your best results are inside a small comfort core.',
          ),
        ),
        nextGamesFocus: const NextGamesFocus(
          title: 'Next 5 games focus',
          action: 'Keep deaths to 6 or fewer in each of the next 5 Carry games.',
          sourceLabel: 'Early death risk',
          sourceType: CoachingInsightType.earlyDeathRisk,
        ),
        comfortCore: _comfortCore(
          conclusionType: ComfortCoreConclusionType.successInsideCore,
        ),
        roleSummary: _trustedRoleSummary(),
        followThroughCheck: null,
        heroLabelFor: _heroLabelFor,
      );

      expect(plan.queue, 'Carry only');
      expect(plan.heroBlock, 'Slardar + Mars');
      expect(plan.target, 'keep deaths to 6 or fewer');
      expect(plan.reviewWindow, 'next 5 games');
      expect(plan.targetType, SessionPlanTargetType.deaths);
      expect(plan.heroBlockHeroIds, [28, 129]);
      expect(plan.roleBlockKey, 'carry');
    });

    test('builds a calm noisy-sample fallback plan', () {
      final plan = service.build(
        verdict: const DashboardVerdict(
          fallbackMessage: 'Current sample is still too noisy for a strong verdict.',
        ),
        nextGamesFocus: const NextGamesFocus(
          title: 'Next 5 games focus',
          action: 'Play 5 more games on one role and a 2-hero block before judging this sample.',
          sourceLabel: 'Limited confidence',
          sourceType: CoachingInsightType.limitedConfidence,
        ),
        comfortCore: _comfortCore(
          conclusionType: ComfortCoreConclusionType.tinySample,
        ),
        roleSummary: _mixedRoleSummary(),
        followThroughCheck: const FocusFollowThroughCheck.waiting(
          fallbackMessage: 'Need a bigger block before judging follow-through.',
        ),
        heroLabelFor: _heroLabelFor,
      );

      expect(plan.queue, 'one role only');
      expect(plan.heroBlock, '2 heroes max');
      expect(plan.target, 'build a cleaner sample');
      expect(plan.reviewWindow, 'next 5 games');
      expect(plan.targetType, SessionPlanTargetType.heroPool);
      expect(plan.heroBlockHeroIds, isEmpty);
      expect(plan.roleBlockKey, isNull);
    });

    test('resolves mixed signals into one plan', () {
      final plan = service.build(
        verdict: const DashboardVerdict(
          biggestLeak: DashboardVerdictLine(
            message: 'Your recent pool is still too wide.',
          ),
          biggestEdge: DashboardVerdictLine(
            message: 'Your best results are inside a small comfort core.',
          ),
        ),
        nextGamesFocus: const NextGamesFocus(
          title: 'Next 5 games focus',
          action: 'Limit the next 5 games to 2 heroes so the sample stays easier to read.',
          sourceLabel: 'Hero pool spread',
          sourceType: CoachingInsightType.heroPoolSpread,
        ),
        comfortCore: _comfortCore(
          conclusionType: ComfortCoreConclusionType.successInsideCore,
        ),
        roleSummary: _trustedRoleSummary(),
        followThroughCheck: null,
        heroLabelFor: _heroLabelFor,
      );

      expect(plan.queue, 'Carry only');
      expect(plan.heroBlock, 'Slardar + Mars');
      expect(plan.target, 'stay on this 2-hero block');
      expect(plan.reviewWindow, 'next 5 games');
      expect(plan.targetType, SessionPlanTargetType.heroPool);
      expect(plan.heroBlockHeroIds, [28, 129]);
      expect(plan.roleBlockKey, 'carry');
    });
  });
}

String _heroLabelFor(int heroId) {
  return switch (heroId) {
    28 => 'Slardar',
    129 => 'Mars',
    _ => 'Hero $heroId',
  };
}

ComfortCoreSummary _comfortCore({
  required ComfortCoreConclusionType conclusionType,
}) {
  return ComfortCoreSummary(
    conclusionType: conclusionType,
    conclusion: 'Conclusion',
    totalMatches: conclusionType == ComfortCoreConclusionType.tinySample ? 4 : 8,
    minimumMatches: 5,
    topHeroes: const [
      ComfortCoreHeroUsage(heroId: 28, matches: 4),
      ComfortCoreHeroUsage(heroId: 129, matches: 2),
    ],
    topHeroWins: 5,
    topHeroLosses: 1,
    otherHeroWins: 1,
    otherHeroLosses: 1,
  );
}

SampleRoleSummary _trustedRoleSummary() {
  return const SampleRoleSummary(
    primaryRole: PlayerRole.carry,
    primaryRoleConfidence: RoleConfidence.high,
    readType: SampleRoleReadType.clear,
    roleDistribution: {
      PlayerRole.carry: 6,
      PlayerRole.mid: 1,
      PlayerRole.offlane: 1,
      PlayerRole.softSupport: 0,
      PlayerRole.hardSupport: 0,
      PlayerRole.unknown: 0,
    },
  );
}

SampleRoleSummary _mixedRoleSummary() {
  return const SampleRoleSummary(
    primaryRole: PlayerRole.unknown,
    primaryRoleConfidence: RoleConfidence.low,
    readType: SampleRoleReadType.smallSample,
    roleDistribution: {
      PlayerRole.carry: 1,
      PlayerRole.mid: 1,
      PlayerRole.offlane: 1,
      PlayerRole.softSupport: 0,
      PlayerRole.hardSupport: 0,
      PlayerRole.unknown: 1,
    },
  );
}
