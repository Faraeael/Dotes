import '../../../insights/domain/models/coaching_insight.dart';
import '../../../insights/domain/models/next_games_focus.dart';
import '../../../progress/domain/models/focus_follow_through_check.dart';
import '../../../roles/domain/models/player_role.dart';
import '../../../roles/domain/models/sample_role_summary.dart';
import '../../../training_preferences/domain/models/training_preferences.dart';
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
    TrainingPreferences trainingPreferences = const TrainingPreferences(),
    int blockSize = 5,
  }) {
    final preferredRole = trainingPreferences.activePreferredRole;
    final isNoisySample = _isNoisySample(
      verdict: verdict,
      nextGamesFocus: nextGamesFocus,
      comfortCore: comfortCore,
    );
    final manualHeroBlock = _lockedHeroBlockLabel(
      trainingPreferences,
      heroLabelFor,
    );
    final namedHeroBlock =
        manualHeroBlock ??
        _namedHeroBlockLabel(
          nextGamesFocus: nextGamesFocus,
          comfortCore: comfortCore,
          heroLabelFor: heroLabelFor,
        );
    final manualHeroBlockIds = trainingPreferences.activeLockedHeroIds;
    final namedHeroBlockIds = manualHeroBlockIds.isNotEmpty
        ? manualHeroBlockIds
        : _namedHeroBlockIds(
            nextGamesFocus: nextGamesFocus,
            comfortCore: comfortCore,
          );
    final focusPriority = trainingPreferences.focusPriority;
    final targetType = _targetType(
      verdict: verdict,
      nextGamesFocus: nextGamesFocus,
      comfortCore: comfortCore,
      isNoisySample: isNoisySample,
      hasNamedHeroBlock: namedHeroBlock != null,
      focusPriority: focusPriority,
    );
    final coachingStyle = trainingPreferences.coachingStyle;
    final roleBlockKey = _roleBlockKey(
      roleSummary,
      isNoisySample: isNoisySample,
      preferredRole: preferredRole,
    );

    return SessionPlan(
      queue: _queueLabel(
        roleSummary,
        isNoisySample: isNoisySample,
        preferredRole: preferredRole,
        queuePreference: trainingPreferences.queuePreference,
      ),
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
        focusPriority: focusPriority,
        coachingStyle: coachingStyle,
      ),
      reviewWindow: 'next $blockSize games',
      targetType: targetType,
      heroBlockHeroIds: namedHeroBlockIds,
      roleBlockKey: roleBlockKey,
      usesManualRoleSetup: preferredRole != null,
      usesManualHeroBlock: manualHeroBlockIds.isNotEmpty,
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
    required PlayerRole? preferredRole,
    required TrainingQueuePreference queuePreference,
  }) {
    final baseQueue = _baseQueueLabel(
      roleSummary,
      isNoisySample: isNoisySample,
      preferredRole: preferredRole,
    );
    return _queuePreferenceLabel(baseQueue, queuePreference);
  }

  String _baseQueueLabel(
    SampleRoleSummary? roleSummary, {
    required bool isNoisySample,
    required PlayerRole? preferredRole,
  }) {
    if (preferredRole != null) {
      return '${preferredRole.label} only';
    }

    final trustedRoleLabel = roleSummary?.trustedRoleLabelForFocus;
    if (!isNoisySample && trustedRoleLabel != null) {
      return '$trustedRoleLabel only';
    }

    return 'one role only';
  }

  String _queuePreferenceLabel(
    String baseQueue,
    TrainingQueuePreference queuePreference,
  ) {
    return switch (queuePreference) {
      TrainingQueuePreference.auto => baseQueue,
      TrainingQueuePreference.soloOnly => '$baseQueue, solo queue',
      TrainingQueuePreference.partyOnly => '$baseQueue, party queue',
    };
  }

  String? _roleBlockKey(
    SampleRoleSummary? roleSummary, {
    required bool isNoisySample,
    required PlayerRole? preferredRole,
  }) {
    if (preferredRole != null) {
      return preferredRole.name;
    }

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

  String? _lockedHeroBlockLabel(
    TrainingPreferences trainingPreferences,
    String Function(int heroId)? heroLabelFor,
  ) {
    final heroIds = trainingPreferences.activeLockedHeroIds;
    if (heroIds.isEmpty || heroLabelFor == null) {
      return null;
    }

    final heroLabels = heroIds
        .map((heroId) => heroLabelFor(heroId).trim())
        .where((label) => label.isNotEmpty)
        .toList(growable: false);
    if (heroLabels.length != heroIds.length) {
      return null;
    }

    return _heroBlockLabelFromNames(heroLabels);
  }

  String _targetLabel({
    required DashboardVerdict? verdict,
    required NextGamesFocus? nextGamesFocus,
    required ComfortCoreSummary? comfortCore,
    required FocusFollowThroughCheck? followThroughCheck,
    required bool isNoisySample,
    required bool hasNamedHeroBlock,
    required TrainingFocusPriority focusPriority,
    required TrainingCoachingStyle coachingStyle,
  }) {
    final focusPriorityTarget = _focusPriorityTargetLabel(
      focusPriority: focusPriority,
      hasNamedHeroBlock: hasNamedHeroBlock,
      comfortCore: comfortCore,
    );
    if (focusPriorityTarget != null) {
      return _styleTargetLabel(focusPriorityTarget, coachingStyle);
    }

    if (isNoisySample) {
      return _styleTargetLabel('build a cleaner sample', coachingStyle);
    }

    if (nextGamesFocus?.sourceType == CoachingInsightType.earlyDeathRisk) {
      return _styleTargetLabel('keep deaths to 6 or fewer', coachingStyle);
    }

    if ((hasNamedHeroBlock || _hasStableComfortBlock(comfortCore)) &&
        followThroughCheck?.isReady == true) {
      final baseTarget = switch (followThroughCheck!.status!) {
        FocusFollowThroughStatus.onTrack => 'repeat the block cleanly',
        FocusFollowThroughStatus.mixed => 'cut the drift outside the block',
        FocusFollowThroughStatus.offTrack => 'get back inside the block',
      };
      return _styleTargetLabel(baseTarget, coachingStyle);
    }

    final baseTarget = switch (nextGamesFocus?.sourceType) {
      CoachingInsightType.heroPoolSpread =>
        hasNamedHeroBlock
            ? 'stay on this 2-hero block'
            : 'keep the pool to 2 heroes',
      CoachingInsightType.specializationRecommendation =>
        'make the sample easier to read',
      CoachingInsightType.comfortHeroDependence =>
        hasNamedHeroBlock
            ? 'stay inside the block'
            : 'compare results inside the block',
      CoachingInsightType.weakRecentTrend => 'stabilize the next block',
      CoachingInsightType.limitedConfidence => 'build a cleaner sample',
      CoachingInsightType.earlyDeathRisk => 'keep deaths to 6 or fewer',
      null =>
        verdict?.biggestLeak == null && verdict?.biggestEdge != null
            ? 'hold the clean edge'
            : 'keep the block easy to review',
    };
    return _styleTargetLabel(baseTarget, coachingStyle);
  }

  SessionPlanTargetType _targetType({
    required DashboardVerdict? verdict,
    required NextGamesFocus? nextGamesFocus,
    required ComfortCoreSummary? comfortCore,
    required bool isNoisySample,
    required bool hasNamedHeroBlock,
    required TrainingFocusPriority focusPriority,
  }) {
    final focusPriorityType = _focusPriorityTargetType(
      focusPriority: focusPriority,
      hasNamedHeroBlock: hasNamedHeroBlock,
      comfortCore: comfortCore,
    );
    if (focusPriorityType != null) {
      return focusPriorityType;
    }

    if (isNoisySample) {
      return SessionPlanTargetType.heroPool;
    }

    if (nextGamesFocus?.sourceType == CoachingInsightType.earlyDeathRisk) {
      return SessionPlanTargetType.deaths;
    }

    if (hasNamedHeroBlock || _hasStableComfortBlock(comfortCore)) {
      return switch (nextGamesFocus?.sourceType) {
        CoachingInsightType.heroPoolSpread => SessionPlanTargetType.heroPool,
        CoachingInsightType.specializationRecommendation =>
          SessionPlanTargetType.heroPool,
        CoachingInsightType.weakRecentTrend => SessionPlanTargetType.heroPool,
        CoachingInsightType.limitedConfidence => SessionPlanTargetType.heroPool,
        CoachingInsightType.earlyDeathRisk => SessionPlanTargetType.deaths,
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

  String? _focusPriorityTargetLabel({
    required TrainingFocusPriority focusPriority,
    required bool hasNamedHeroBlock,
    required ComfortCoreSummary? comfortCore,
  }) {
    return switch (focusPriority) {
      TrainingFocusPriority.auto => null,
      TrainingFocusPriority.reduceDeaths => 'keep deaths to 6 or fewer',
      TrainingFocusPriority.tightenHeroPool =>
        hasNamedHeroBlock
            ? 'stay on this 2-hero block'
            : 'keep the pool to 2 heroes',
      TrainingFocusPriority.stayInComfortBlock =>
        (hasNamedHeroBlock || _hasStableComfortBlock(comfortCore))
            ? 'stay inside the block'
            : 'compare results inside the block',
    };
  }

  SessionPlanTargetType? _focusPriorityTargetType({
    required TrainingFocusPriority focusPriority,
    required bool hasNamedHeroBlock,
    required ComfortCoreSummary? comfortCore,
  }) {
    return switch (focusPriority) {
      TrainingFocusPriority.auto => null,
      TrainingFocusPriority.reduceDeaths => SessionPlanTargetType.deaths,
      TrainingFocusPriority.tightenHeroPool => SessionPlanTargetType.heroPool,
      TrainingFocusPriority.stayInComfortBlock =>
        hasNamedHeroBlock || _hasStableComfortBlock(comfortCore)
            ? SessionPlanTargetType.comfortBlock
            : SessionPlanTargetType.heroPool,
    };
  }

  String _styleTargetLabel(
    String baseTarget,
    TrainingCoachingStyle coachingStyle,
  ) {
    return switch (coachingStyle) {
      TrainingCoachingStyle.auto => baseTarget,
      TrainingCoachingStyle.steady => _steadyTargetLabel(baseTarget),
      TrainingCoachingStyle.direct => _directTargetLabel(baseTarget),
    };
  }

  String _steadyTargetLabel(String baseTarget) {
    return switch (baseTarget) {
      'keep deaths to 6 or fewer' => 'keep the block steady and deaths to 6 or fewer',
      'stay on this 2-hero block' => 'keep the block steady on this 2-hero pool',
      'keep the pool to 2 heroes' => 'keep the next block steady on 2 heroes',
      'stay inside the block' => 'keep the next block steady inside the comfort block',
      'compare results inside the block' =>
        'use the next block to compare steadier results inside the comfort block',
      'build a cleaner sample' => 'keep the next block steady and build a cleaner sample',
      'repeat the block cleanly' => 'keep the next block steady and repeat the block cleanly',
      'cut the drift outside the block' =>
        'steady the next block and cut the drift outside the pool',
      'get back inside the block' =>
        'steady the next block and get back inside the pool',
      'make the sample easier to read' =>
        'keep the next block steady so the sample stays easier to read',
      'stabilize the next block' => 'keep the next block steady and stable',
      'hold the clean edge' => 'keep the next block steady and hold the clean edge',
      'keep the block easy to review' =>
        'keep the next block steady and easy to review',
      _ => baseTarget,
    };
  }

  String _directTargetLabel(String baseTarget) {
    return switch (baseTarget) {
      'keep deaths to 6 or fewer' => 'cap deaths at 6',
      'stay on this 2-hero block' => 'lock the next block to these 2 heroes',
      'keep the pool to 2 heroes' => 'lock the next block to 2 heroes',
      'stay inside the block' => 'stay in the block',
      'compare results inside the block' => 'test results inside the block',
      'build a cleaner sample' => 'clean up the sample',
      'repeat the block cleanly' => 'repeat the block cleanly',
      'cut the drift outside the block' => 'cut the drift',
      'get back inside the block' => 'get back in the block',
      'make the sample easier to read' => 'make the sample easier to read',
      'stabilize the next block' => 'stabilize the block',
      'hold the clean edge' => 'hold the edge',
      'keep the block easy to review' => 'keep the block reviewable',
      _ => baseTarget,
    };
  }
}
