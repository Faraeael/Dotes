import '../../../insights/domain/models/coaching_insight.dart';
import '../../../insights/domain/models/next_games_focus.dart';
import '../../../progress/domain/models/focus_follow_through_check.dart';
import '../../../roles/domain/models/sample_role_summary.dart';
import '../models/comfort_core_summary.dart';
import '../models/dashboard_verdict.dart';
import '../models/session_plan.dart';

class SessionPlanService {
  const SessionPlanService();

  SessionPlan build({
    required DashboardVerdict? verdict,
    required NextGamesFocus? nextGamesFocus,
    required ComfortCoreSummary? comfortCore,
    required SampleRoleSummary? roleSummary,
    required FocusFollowThroughCheck? followThroughCheck,
    String Function(int heroId)? heroLabelFor,
  }) {
    final isNoisySample = _isNoisySample(
      verdict: verdict,
      nextGamesFocus: nextGamesFocus,
      comfortCore: comfortCore,
    );
    final namedHeroBlock = _namedHeroBlockLabel(
      nextGamesFocus: nextGamesFocus,
      comfortCore: comfortCore,
      heroLabelFor: heroLabelFor,
    );
    final namedHeroBlockIds = _namedHeroBlockIds(
      nextGamesFocus: nextGamesFocus,
      comfortCore: comfortCore,
    );
    final targetType = _targetType(
      verdict: verdict,
      nextGamesFocus: nextGamesFocus,
      comfortCore: comfortCore,
      isNoisySample: isNoisySample,
      hasNamedHeroBlock: namedHeroBlock != null,
    );
    final roleBlockKey = _roleBlockKey(
      roleSummary,
      isNoisySample: isNoisySample,
    );

    return SessionPlan(
      queue: _queueLabel(roleSummary, isNoisySample: isNoisySample),
      heroBlock: _heroBlockLabel(
        namedHeroBlock: namedHeroBlock,
        nextGamesFocus: nextGamesFocus,
        comfortCore: comfortCore,
        isNoisySample: isNoisySample,
      ),
      target: _targetLabel(
        verdict: verdict,
        nextGamesFocus: nextGamesFocus,
        comfortCore: comfortCore,
        followThroughCheck: followThroughCheck,
        isNoisySample: isNoisySample,
        hasNamedHeroBlock: namedHeroBlock != null,
      ),
      reviewWindow: 'next 5 games',
      targetType: targetType,
      heroBlockHeroIds: namedHeroBlockIds,
      roleBlockKey: roleBlockKey,
    );
  }

  bool _isNoisySample({
    required DashboardVerdict? verdict,
    required NextGamesFocus? nextGamesFocus,
    required ComfortCoreSummary? comfortCore,
  }) {
    if (nextGamesFocus?.sourceType == CoachingInsightType.limitedConfidence) {
      return true;
    }

    if (verdict == null || !verdict.hasSignal) {
      return comfortCore == null || !comfortCore.isReady;
    }

    return false;
  }

  String _queueLabel(
    SampleRoleSummary? roleSummary, {
    required bool isNoisySample,
  }) {
    final trustedRoleLabel = roleSummary?.trustedRoleLabelForFocus;
    if (!isNoisySample && trustedRoleLabel != null) {
      return '$trustedRoleLabel only';
    }

    return 'one role only';
  }

  String? _roleBlockKey(
    SampleRoleSummary? roleSummary, {
    required bool isNoisySample,
  }) {
    if (isNoisySample || roleSummary?.hasTrustedPrimaryRoleForFocus != true) {
      return null;
    }

    return roleSummary!.primaryRole.name;
  }

  String _heroBlockLabel({
    required String? namedHeroBlock,
    required NextGamesFocus? nextGamesFocus,
    required ComfortCoreSummary? comfortCore,
    required bool isNoisySample,
  }) {
    if (namedHeroBlock != null) {
      return namedHeroBlock;
    }

    if (isNoisySample) {
      return '2 heroes max';
    }

    if (nextGamesFocus?.sourceType ==
        CoachingInsightType.specializationRecommendation) {
      return '3 heroes max';
    }

    if (_hasStableComfortBlock(comfortCore)) {
      return 'top 2 comfort heroes';
    }

    return '2 heroes max';
  }

  String _targetLabel({
    required DashboardVerdict? verdict,
    required NextGamesFocus? nextGamesFocus,
    required ComfortCoreSummary? comfortCore,
    required FocusFollowThroughCheck? followThroughCheck,
    required bool isNoisySample,
    required bool hasNamedHeroBlock,
  }) {
    if (isNoisySample) {
      return 'build a cleaner sample';
    }

    if (nextGamesFocus?.sourceType == CoachingInsightType.earlyDeathRisk) {
      return 'keep deaths to 6 or fewer';
    }

    if ((hasNamedHeroBlock || _hasStableComfortBlock(comfortCore)) &&
        followThroughCheck?.isReady == true) {
      return switch (followThroughCheck!.status!) {
        FocusFollowThroughStatus.onTrack => 'repeat the block cleanly',
        FocusFollowThroughStatus.mixed => 'cut the drift outside the block',
        FocusFollowThroughStatus.offTrack => 'get back inside the block',
      };
    }

    return switch (nextGamesFocus?.sourceType) {
      CoachingInsightType.heroPoolSpread =>
        hasNamedHeroBlock ? 'stay on this 2-hero block' : 'keep the pool to 2 heroes',
      CoachingInsightType.specializationRecommendation =>
        'make the sample easier to read',
      CoachingInsightType.comfortHeroDependence =>
        hasNamedHeroBlock ? 'stay inside the block' : 'compare results inside the block',
      CoachingInsightType.weakRecentTrend => 'stabilize the next block',
      CoachingInsightType.limitedConfidence => 'build a cleaner sample',
      CoachingInsightType.earlyDeathRisk => 'keep deaths to 6 or fewer',
      null => verdict?.biggestLeak == null && verdict?.biggestEdge != null
          ? 'hold the clean edge'
          : 'keep the block easy to review',
    };
  }

  SessionPlanTargetType _targetType({
    required DashboardVerdict? verdict,
    required NextGamesFocus? nextGamesFocus,
    required ComfortCoreSummary? comfortCore,
    required bool isNoisySample,
    required bool hasNamedHeroBlock,
  }) {
    if (isNoisySample) {
      return SessionPlanTargetType.heroPool;
    }

    if (nextGamesFocus?.sourceType == CoachingInsightType.earlyDeathRisk) {
      return SessionPlanTargetType.deaths;
    }

    if (hasNamedHeroBlock || _hasStableComfortBlock(comfortCore)) {
      return switch (nextGamesFocus?.sourceType) {
        CoachingInsightType.heroPoolSpread =>
          SessionPlanTargetType.heroPool,
        CoachingInsightType.specializationRecommendation =>
          SessionPlanTargetType.heroPool,
        CoachingInsightType.weakRecentTrend =>
          SessionPlanTargetType.heroPool,
        CoachingInsightType.limitedConfidence =>
          SessionPlanTargetType.heroPool,
        CoachingInsightType.earlyDeathRisk =>
          SessionPlanTargetType.deaths,
        CoachingInsightType.comfortHeroDependence ||
        null => SessionPlanTargetType.comfortBlock,
      };
    }

    return verdict?.biggestLeak == null && verdict?.biggestEdge != null
        ? SessionPlanTargetType.comfortBlock
        : SessionPlanTargetType.heroPool;
  }

  String? _namedHeroBlockLabel({
    required NextGamesFocus? nextGamesFocus,
    required ComfortCoreSummary? comfortCore,
    required String Function(int heroId)? heroLabelFor,
  }) {
    final focusHeroBlock = nextGamesFocus?.heroBlock;
    if (focusHeroBlock != null && focusHeroBlock.heroLabels.isNotEmpty) {
      return _heroBlockLabelFromNames(focusHeroBlock.heroLabels);
    }

    if (!_canNameComfortHeroes(comfortCore) || heroLabelFor == null) {
      return null;
    }

    final names = comfortCore!.topHeroes
        .take(2)
        .map((hero) => heroLabelFor(hero.heroId).trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);

    if (names.isEmpty) {
      return null;
    }

    return _heroBlockLabelFromNames(names);
  }

  List<int> _namedHeroBlockIds({
    required NextGamesFocus? nextGamesFocus,
    required ComfortCoreSummary? comfortCore,
  }) {
    final focusHeroBlock = nextGamesFocus?.heroBlock;
    if (focusHeroBlock != null && focusHeroBlock.heroIds.isNotEmpty) {
      return focusHeroBlock.heroIds;
    }

    if (!_canNameComfortHeroes(comfortCore)) {
      return const [];
    }

    return comfortCore!.topHeroes
        .take(2)
        .map((hero) => hero.heroId)
        .toList(growable: false);
  }

  String _heroBlockLabelFromNames(List<String> heroLabels) {
    if (heroLabels.length == 1) {
      return heroLabels.first;
    }

    return '${heroLabels.first} + ${heroLabels.last}';
  }

  bool _canNameComfortHeroes(ComfortCoreSummary? comfortCore) {
    return comfortCore != null &&
        comfortCore.isReady &&
        comfortCore.conclusionType ==
            ComfortCoreConclusionType.successInsideCore &&
        comfortCore.topHeroes.isNotEmpty;
  }

  bool _hasStableComfortBlock(ComfortCoreSummary? comfortCore) {
    return comfortCore != null &&
        comfortCore.isReady &&
        (comfortCore.conclusionType ==
                ComfortCoreConclusionType.successInsideCore ||
            comfortCore.conclusionType ==
                ComfortCoreConclusionType.outsideWeaker);
  }
}
