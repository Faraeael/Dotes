import '../../../dashboard/domain/models/comfort_core_summary.dart';
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

    if (topInsight == null) {
      final scopeLabel = trustedRoleLabel ?? roleScopeLabel;

      return NextGamesFocus(
        title: 'Next 5 games focus',
        action: lockedHeroBlock == null
            ? trustedRoleLabel == null
                  ? 'Play the next 5 games on $scopeLabel and no more than 2 heroes.'
                  : 'Play the next 5 games on $trustedRoleLabel and no more than 2 heroes.'
            : 'Play the next 5 games on $scopeLabel and stay on ${lockedHeroBlock.actionLabel}.',
        sourceLabel: 'No strong signal yet',
        heroBlock: lockedHeroBlock,
      );
    }

    return switch (topInsight.type) {
      CoachingInsightType.earlyDeathRisk => NextGamesFocus(
        title: 'Next 5 games focus',
        action: _earlyDeathAction(
          trustedRoleLabel: trustedRoleLabel,
          heroBlock: lockedHeroBlock,
        ),
        sourceLabel: topInsight.title,
        sourceType: topInsight.type,
        heroBlock: lockedHeroBlock,
      ),
      CoachingInsightType.specializationRecommendation => NextGamesFocus(
        title: 'Next 5 games focus',
        action: lockedHeroBlock == null
            ? trustedRoleLabel == null
                  ? 'Queue $roleScopeLabel only for 5 games and cap the block at 3 heroes.'
                  : 'Queue $trustedRoleLabel only for 5 games and cap the block at 3 heroes.'
            : 'Queue $roleScopeLabel only for 5 games and stay on ${lockedHeroBlock.actionLabel}.',
        sourceLabel: topInsight.title,
        sourceType: topInsight.type,
        heroBlock: lockedHeroBlock,
      ),
      CoachingInsightType.heroPoolSpread => NextGamesFocus(
        title: 'Next 5 games focus',
        action: lockedHeroBlock == null
            ? trustedRoleLabel == null
                  ? 'Limit the next 5 games to 2 heroes so the sample stays easier to read.'
                  : 'Limit the next 5 $trustedRoleLabel games to 2 heroes so the sample stays easier to read.'
            : trustedRoleLabel == null
            ? 'Keep the next 5 games on ${lockedHeroBlock.actionLabel} so the sample stays easier to read.'
            : 'Keep the next 5 $trustedRoleLabel games on ${lockedHeroBlock.actionLabel} so the sample stays easier to read.',
        sourceLabel: topInsight.title,
        sourceType: topInsight.type,
        heroBlock: lockedHeroBlock,
      ),
      CoachingInsightType.comfortHeroDependence => NextGamesFocus(
        title: 'Next 5 games focus',
        action: _comfortHeroAction(
          trustedRoleLabel: trustedRoleLabel,
          heroBlock: comfortHeroBlock,
          comfortCore: comfortCore,
        ),
        sourceLabel: topInsight.title,
        sourceType: topInsight.type,
        heroBlock: comfortHeroBlock,
      ),
      CoachingInsightType.weakRecentTrend => NextGamesFocus(
        title: 'Next 5 games focus',
        action: lockedHeroBlock == null
            ? trustedRoleLabel == null
                  ? 'Stay on $roleScopeLabel for all 5 games and keep the hero block to 2 picks.'
                  : 'Stay on $trustedRoleLabel for all 5 games and keep the hero block to 2 picks.'
            : 'Stay on $roleScopeLabel for all 5 games and keep the block on ${lockedHeroBlock.actionLabel}.',
        sourceLabel: topInsight.title,
        sourceType: topInsight.type,
        heroBlock: lockedHeroBlock,
      ),
      CoachingInsightType.limitedConfidence => NextGamesFocus(
        title: 'Next 5 games focus',
        action: lockedHeroBlock == null
            ? trustedRoleLabel == null
                  ? 'Play 5 more games on $roleScopeLabel and a 2-hero block before judging this sample.'
                  : 'Play 5 more $trustedRoleLabel games on a 2-hero block before judging this sample.'
            : trustedRoleLabel == null
            ? 'Play 5 more games on $roleScopeLabel and stay on ${lockedHeroBlock.actionLabel} before judging this sample.'
            : 'Play 5 more $trustedRoleLabel games on ${lockedHeroBlock.actionLabel} before judging this sample.',
        sourceLabel: topInsight.title,
        sourceType: topInsight.type,
        heroBlock: lockedHeroBlock,
      ),
    };
  }

  String _earlyDeathAction({
    required String? trustedRoleLabel,
    required NextGamesFocusHeroBlock? heroBlock,
  }) {
    final roleScope = trustedRoleLabel == null
        ? 'the next 5 games'
        : 'the next 5 $trustedRoleLabel games';
    if (heroBlock == null) {
      return 'Keep deaths to 6 or fewer in each of $roleScope.';
    }

    return 'Keep deaths to 6 or fewer in each of $roleScope while staying on ${heroBlock.actionLabel}.';
  }

  String _comfortHeroAction({
    required String? trustedRoleLabel,
    required NextGamesFocusHeroBlock? heroBlock,
    required ComfortCoreSummary? comfortCore,
  }) {
    if (heroBlock != null) {
      return 'Play your next 5 games on ${heroBlock.actionLabel}.';
    }

    if (_hasStableComfortBlock(comfortCore)) {
      return 'Stay inside your top 2 hero block until the trend stabilizes.';
    }

    return trustedRoleLabel == null
        ? 'Play all 5 games on your top 1-2 comfort heroes and compare the results there.'
        : 'Play all 5 $trustedRoleLabel games on your top 1-2 comfort heroes and compare the results there.';
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
}
