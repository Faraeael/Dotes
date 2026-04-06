import '../../../dashboard/domain/models/comfort_core_summary.dart';
import '../../../player_import/domain/models/player_profile_summary.dart';
import '../../../player_import/domain/models/recent_match.dart';
import '../models/coaching_insight.dart';
import '../models/next_games_focus.dart';
import '../../../training_preferences/domain/models/training_preferences.dart';
import '../../../roles/domain/models/sample_role_summary.dart';

class NextGamesFocusGenerator {
  const NextGamesFocusGenerator();

  NextGamesFocus generate(
    List<CoachingInsight> insights,
    SampleRoleSummary roleSummary, {
    ComfortCoreSummary? comfortCore,
    List<RecentMatch> recentMatches = const [],
    String Function(int heroId)? heroLabelFor,
    TrainingPreferences trainingPreferences = const TrainingPreferences(),
    int blockSize = 5,
    CoachingRankTier rankTier = CoachingRankTier.standard,
  }) {
    // Coaching copy should stay more conservative than the internal role
    // summary. Exact role names only appear when the sample-level role read
    // clears the stricter trust gate exposed by SampleRoleSummary.
    final topInsight = insights.isEmpty ? null : insights.first;
    final preferredRoleLabel = trainingPreferences.activePreferredRole?.label;
    final trustedRoleLabel =
        preferredRoleLabel ?? roleSummary.trustedRoleLabelForFocus;
    final roleScopeLabel =
        preferredRoleLabel ?? roleSummary.focusRoleScopeLabel;
    final lockedHeroBlock = _lockedHeroBlock(
      trainingPreferences,
      recentMatches,
      heroLabelFor,
    );
    final comfortHeroBlock =
        lockedHeroBlock ?? _namedHeroBlock(comfortCore, heroLabelFor);
    final coachingStyle = trainingPreferences.coachingStyle;

    if (topInsight == null) {
      final scopeLabel = trustedRoleLabel ?? roleScopeLabel;
      final baseAction = lockedHeroBlock == null
          ? trustedRoleLabel == null
                ? 'Play the next $blockSize games on $scopeLabel and no more than 2 heroes.'
                : 'Play the next $blockSize games on $trustedRoleLabel and no more than 2 heroes.'
          : 'Play the next $blockSize games on $scopeLabel and stay on ${lockedHeroBlock.actionLabel}.';

      return NextGamesFocus(
        title: 'Next $blockSize games focus',
        action: _applyTone(baseAction, coachingStyle, rankTier),
        sourceLabel: 'No strong signal yet',
        confidenceLabel: 'Conservative read',
        reasonLabel: roleSummary.reasonLabel,
        heroBlock: lockedHeroBlock,
      );
    }

    final confidenceLabel = '${topInsight.confidence.label} confidence';
    final reasonLabel = topInsight.explanation;

    return switch (topInsight.type) {
      CoachingInsightType.earlyDeathRisk => NextGamesFocus(
        title: 'Next $blockSize games focus',
        action: _applyTone(
          _earlyDeathAction(
            trustedRoleLabel: trustedRoleLabel,
            heroBlock: lockedHeroBlock,
            blockSize: blockSize,
          ),
          coachingStyle,
          rankTier,
        ),
        sourceLabel: topInsight.title,
        confidenceLabel: confidenceLabel,
        reasonLabel: reasonLabel,
        sourceType: topInsight.type,
        heroBlock: lockedHeroBlock,
      ),
      CoachingInsightType.specializationRecommendation => NextGamesFocus(
        title: 'Next $blockSize games focus',
        action: _applyTone(
          lockedHeroBlock == null
              ? trustedRoleLabel == null
                    ? 'Queue $roleScopeLabel only for $blockSize games and cap the block at 3 heroes.'
                    : 'Queue $trustedRoleLabel only for $blockSize games and cap the block at 3 heroes.'
              : 'Queue $roleScopeLabel only for $blockSize games and stay on ${lockedHeroBlock.actionLabel}.',
          coachingStyle,
          rankTier,
        ),
        sourceLabel: topInsight.title,
        confidenceLabel: confidenceLabel,
        reasonLabel: reasonLabel,
        sourceType: topInsight.type,
        heroBlock: lockedHeroBlock,
      ),
      CoachingInsightType.heroPoolSpread => NextGamesFocus(
        title: 'Next $blockSize games focus',
        action: _applyTone(
          lockedHeroBlock == null
              ? trustedRoleLabel == null
                    ? 'Limit the next $blockSize games to 2 heroes so the sample stays easier to read.'
                    : 'Limit the next $blockSize $trustedRoleLabel games to 2 heroes so the sample stays easier to read.'
              : trustedRoleLabel == null
              ? 'Keep the next $blockSize games on ${lockedHeroBlock.actionLabel} so the sample stays easier to read.'
              : 'Keep the next $blockSize $trustedRoleLabel games on ${lockedHeroBlock.actionLabel} so the sample stays easier to read.',
          coachingStyle,
          rankTier,
        ),
        sourceLabel: topInsight.title,
        confidenceLabel: confidenceLabel,
        reasonLabel: reasonLabel,
        sourceType: topInsight.type,
        heroBlock: lockedHeroBlock,
      ),
      CoachingInsightType.comfortHeroDependence => NextGamesFocus(
        title: 'Next $blockSize games focus',
        action: _applyTone(
          _comfortHeroAction(
            trustedRoleLabel: trustedRoleLabel,
            heroBlock: comfortHeroBlock,
            comfortCore: comfortCore,
            blockSize: blockSize,
          ),
          coachingStyle,
          rankTier,
        ),
        sourceLabel: topInsight.title,
        confidenceLabel: confidenceLabel,
        reasonLabel: reasonLabel,
        sourceType: topInsight.type,
        heroBlock: comfortHeroBlock,
      ),
      CoachingInsightType.weakRecentTrend => NextGamesFocus(
        title: 'Next $blockSize games focus',
        action: _applyTone(
          lockedHeroBlock == null
              ? trustedRoleLabel == null
                    ? 'Stay on $roleScopeLabel for all $blockSize games and keep the hero block to 2 picks.'
                    : 'Stay on $trustedRoleLabel for all $blockSize games and keep the hero block to 2 picks.'
              : 'Stay on $roleScopeLabel for all $blockSize games and keep the block on ${lockedHeroBlock.actionLabel}.',
          coachingStyle,
          rankTier,
        ),
        sourceLabel: topInsight.title,
        confidenceLabel: confidenceLabel,
        reasonLabel: reasonLabel,
        sourceType: topInsight.type,
        heroBlock: lockedHeroBlock,
      ),
      CoachingInsightType.limitedConfidence => NextGamesFocus(
        title: 'Next $blockSize games focus',
        action: _applyTone(
          lockedHeroBlock == null
              ? trustedRoleLabel == null
                    ? 'Play $blockSize more games on $roleScopeLabel and a 2-hero block before judging this sample.'
                    : 'Play $blockSize more $trustedRoleLabel games on a 2-hero block before judging this sample.'
              : trustedRoleLabel == null
              ? 'Play $blockSize more games on $roleScopeLabel and stay on ${lockedHeroBlock.actionLabel} before judging this sample.'
              : 'Play $blockSize more $trustedRoleLabel games on ${lockedHeroBlock.actionLabel} before judging this sample.',
          coachingStyle,
          rankTier,
        ),
        sourceLabel: topInsight.title,
        confidenceLabel: confidenceLabel,
        reasonLabel: reasonLabel,
        sourceType: topInsight.type,
        heroBlock: lockedHeroBlock,
      ),
    };
  }

  String _earlyDeathAction({
    required String? trustedRoleLabel,
    required NextGamesFocusHeroBlock? heroBlock,
    int blockSize = 5,
  }) {
    final roleScope = trustedRoleLabel == null
        ? 'the next $blockSize games'
        : 'the next $blockSize $trustedRoleLabel games';
    if (heroBlock == null) {
      return 'Keep deaths to 6 or fewer in each of $roleScope.';
    }

    return 'Keep deaths to 6 or fewer in each of $roleScope while staying on ${heroBlock.actionLabel}.';
  }

  String _comfortHeroAction({
    required String? trustedRoleLabel,
    required NextGamesFocusHeroBlock? heroBlock,
    required ComfortCoreSummary? comfortCore,
    int blockSize = 5,
  }) {
    if (heroBlock != null) {
      return 'Play your next $blockSize games on ${heroBlock.actionLabel}.';
    }

    if (_hasStableComfortBlock(comfortCore)) {
      return 'Stay inside your top 2 hero block until the trend stabilizes.';
    }

    return trustedRoleLabel == null
        ? 'Play all $blockSize games on your top 1-2 comfort heroes and compare the results there.'
        : 'Play all $blockSize $trustedRoleLabel games on your top 1-2 comfort heroes and compare the results there.';
  }

  NextGamesFocusHeroBlock? _lockedHeroBlock(
    TrainingPreferences trainingPreferences,
    List<RecentMatch> recentMatches,
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

    final blockMatches = recentMatches
        .where((match) => heroIds.contains(match.heroId))
        .toList(growable: false);
    final wins = blockMatches.where((match) => match.didWin).length;

    return NextGamesFocusHeroBlock(
      heroIds: heroIds,
      heroLabels: heroLabels,
      wins: wins,
      losses: blockMatches.length - wins,
    );
  }

  NextGamesFocusHeroBlock? _namedHeroBlock(
    ComfortCoreSummary? comfortCore,
    String Function(int heroId)? heroLabelFor,
  ) {
    if (heroLabelFor == null || !_canNameComfortHeroes(comfortCore)) {
      return null;
    }

    final names = comfortCore!.topHeroes
        .take(2)
        .map((hero) => heroLabelFor(hero.heroId).trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    final heroIds = comfortCore.topHeroes
        .take(2)
        .map((hero) => hero.heroId)
        .toList(growable: false);

    if (names.isEmpty || heroIds.length != names.length) {
      return null;
    }

    return NextGamesFocusHeroBlock(
      heroIds: heroIds,
      heroLabels: names,
      wins: comfortCore.topHeroWins,
      losses: comfortCore.topHeroLosses,
    );
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

  /// Applies the correct tone variant based on coaching style and rank tier.
  ///
  /// User-selected [steady] / [direct] styles take precedence.
  /// Rank-tier tone only fires when the style is [auto].
  String _applyTone(
    String baseAction,
    TrainingCoachingStyle coachingStyle,
    CoachingRankTier rankTier,
  ) {
    return switch (coachingStyle) {
      TrainingCoachingStyle.steady => _steadyActionLabel(baseAction),
      TrainingCoachingStyle.direct => _directActionLabel(baseAction),
      TrainingCoachingStyle.auto => switch (rankTier) {
        CoachingRankTier.introductory => _introActionLabel(baseAction),
        CoachingRankTier.advanced => _advancedActionLabel(baseAction),
        CoachingRankTier.standard => baseAction,
      },
    };
  }

  /// Simplified phrasing for Herald–Crusader players.
  String _introActionLabel(String baseAction) {
    if (baseAction.contains('no more than 2 heroes')) {
      final match = RegExp(r'next (\d+) games on (.+) and no more than').firstMatch(baseAction);
      if (match != null) {
        return 'Pick ${match.group(2)} and stick to 2 heroes for ${match.group(1)} games.';
      }
      return 'Pick one role and stick to 2 heroes.';
    }
    if (baseAction.contains('Keep deaths to 6 or fewer')) {
      return baseAction.replaceFirst(
        'Keep deaths to 6 or fewer in each of',
        'Try to die 6 times or less each game for',
      );
    }
    if (baseAction.contains('Limit the next') && baseAction.contains('to 2 heroes')) {
      final match = RegExp(r'Limit the next (\d+)').firstMatch(baseAction);
      final n = match?.group(1) ?? '5';
      return 'Play the same 2 heroes for $n games in a row.';
    }
    return baseAction;
  }

  /// Terse, efficiency-first phrasing for Divine/Immortal players.
  String _advancedActionLabel(String baseAction) {
    if (baseAction.contains('no more than 2 heroes')) {
      final match = RegExp(r'next (\d+) games').firstMatch(baseAction);
      final n = match?.group(1) ?? '5';
      final roleMatch = RegExp(r'games on (\S+) and').firstMatch(baseAction);
      final role = roleMatch?.group(1);
      return role != null
          ? '$n-game $role block, 2-hero cap.'
          : '$n-game block, 2-hero cap.';
    }
    if (baseAction.contains('Keep deaths to 6 or fewer')) {
      final match = RegExp(r'(\d+) games').firstMatch(baseAction);
      final n = match?.group(1) ?? '5';
      return 'Target ≤6 deaths per game for $n games.';
    }
    if (baseAction.contains('Limit the next') && baseAction.contains('to 2 heroes')) {
      final match = RegExp(r'(\d+)').firstMatch(baseAction);
      final n = match?.group(1) ?? '5';
      return 'Lock to 2-hero block for $n games.';
    }
    if (baseAction.contains('Stay inside your top 2 hero block')) {
      return 'Lock to top-2 comfort block until trend stabilizes.';
    }
    return baseAction;
  }

  String _steadyActionLabel(String baseAction) {
    if (baseAction.startsWith('Play your next') && baseAction.contains('games on ')) {
      return baseAction.replaceFirst(
        RegExp(r'Play your next \d+ games on '),
        'Keep the next block steady on ',
      );
    }
    if (baseAction.startsWith('Keep deaths to 6 or fewer')) {
      return baseAction.replaceFirst(
        'Keep deaths to 6 or fewer',
        'Keep the block steady and deaths to 6 or fewer',
      );
    }
    if (baseAction.startsWith('Limit the next')) {
      return baseAction
          .replaceFirst('Limit', 'Keep')
          .replaceFirst(
            'to 2 heroes so the sample stays easier to read.',
            'on 2 heroes so the sample stays easier to read.',
          );
    }
    if (baseAction.startsWith('Play') && baseAction.contains('more')) {
      return baseAction.replaceFirst('Play', 'Keep the next block steady with');
    }
    if (baseAction.startsWith('Play the next') && baseAction.contains('games on')) {
      return baseAction.replaceFirst(
        RegExp(r'Play the next \d+ games on'),
        'Keep the next block steady on',
      );
    }
    return baseAction;
  }

  String _directActionLabel(String baseAction) {
    if (baseAction.startsWith('Play your next') && baseAction.contains('games on ')) {
      return baseAction.replaceFirst(
        RegExp(r'Play your next \d+ games on '),
        'Run the next block on ',
      );
    }
    if (baseAction.startsWith('Keep deaths to 6 or fewer')) {
      return baseAction.replaceFirst('Keep deaths to 6 or fewer', 'Cap deaths at 6');
    }
    if (baseAction.startsWith('Limit the next') && baseAction.contains('to 2 heroes')) {
      final match = RegExp(r'Limit the next (\d+)( \w+)? games to 2 heroes').firstMatch(baseAction);
      if (match != null) {
        final n = match.group(1)!;
        final role = match.group(2)?.trim();
        return role != null
            ? 'Lock the next $n $role games to 2 heroes.'
            : 'Lock the next $n games to 2 heroes.';
      }
    }
    if (baseAction.startsWith('Play') && baseAction.contains('more')) {
      return baseAction.replaceFirst(RegExp(r'Play (\d+ more)'), 'Run \$1');
    }
    if (baseAction.startsWith('Play the next') && baseAction.contains('games on')) {
      return baseAction.replaceFirst(
        RegExp(r'Play the next \d+ games on'),
        'Run the next block on',
      );
    }
    return baseAction;
  }
}
