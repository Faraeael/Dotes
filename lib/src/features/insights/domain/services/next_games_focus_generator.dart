import '../models/coaching_insight.dart';
import '../models/next_games_focus.dart';
import '../../../roles/domain/models/sample_role_summary.dart';

class NextGamesFocusGenerator {
  const NextGamesFocusGenerator();

  NextGamesFocus generate(
    List<CoachingInsight> insights,
    SampleRoleSummary roleSummary,
  ) {
    // Coaching copy should stay more conservative than the internal role
    // summary. Exact role names only appear when the sample-level role read
    // clears the stricter trust gate exposed by SampleRoleSummary.
    final topInsight = insights.isEmpty ? null : insights.first;
    final trustedRoleLabel = roleSummary.trustedRoleLabelForFocus;
    final roleScopeLabel = roleSummary.focusRoleScopeLabel;

    if (topInsight == null) {
      final scopeLabel = trustedRoleLabel ?? roleScopeLabel;

      return NextGamesFocus(
        title: 'Next 5 games focus',
        action: trustedRoleLabel == null
            ? 'Play the next 5 games on $scopeLabel and no more than 2 heroes.'
            : 'Play the next 5 games on $trustedRoleLabel and no more than 2 heroes.',
        sourceLabel: 'No strong signal yet',
      );
    }

    return switch (topInsight.type) {
      CoachingInsightType.earlyDeathRisk => NextGamesFocus(
        title: 'Next 5 games focus',
        action: trustedRoleLabel == null
            ? 'Keep deaths to 6 or fewer in each of the next 5 games.'
            : 'Keep deaths to 6 or fewer in each of the next 5 $trustedRoleLabel games.',
        sourceLabel: topInsight.title,
        sourceType: topInsight.type,
      ),
      CoachingInsightType.specializationRecommendation => NextGamesFocus(
        title: 'Next 5 games focus',
        action: trustedRoleLabel == null
            ? 'Queue $roleScopeLabel only for 5 games and cap the block at 3 heroes.'
            : 'Queue $trustedRoleLabel only for 5 games and cap the block at 3 heroes.',
        sourceLabel: topInsight.title,
        sourceType: topInsight.type,
      ),
      CoachingInsightType.heroPoolSpread => NextGamesFocus(
        title: 'Next 5 games focus',
        action: trustedRoleLabel == null
            ? 'Limit the next 5 games to 2 heroes so the sample stays easier to read.'
            : 'Limit the next 5 $trustedRoleLabel games to 2 heroes so the sample stays easier to read.',
        sourceLabel: topInsight.title,
        sourceType: topInsight.type,
      ),
      CoachingInsightType.comfortHeroDependence => NextGamesFocus(
        title: 'Next 5 games focus',
        action: trustedRoleLabel == null
            ? 'Play all 5 games on your top 1-2 comfort heroes and compare the results there.'
            : 'Play all 5 $trustedRoleLabel games on your top 1-2 comfort heroes and compare the results there.',
        sourceLabel: topInsight.title,
        sourceType: topInsight.type,
      ),
      CoachingInsightType.weakRecentTrend => NextGamesFocus(
        title: 'Next 5 games focus',
        action: trustedRoleLabel == null
            ? 'Stay on $roleScopeLabel for all 5 games and keep the hero block to 2 picks.'
            : 'Stay on $trustedRoleLabel for all 5 games and keep the hero block to 2 picks.',
        sourceLabel: topInsight.title,
        sourceType: topInsight.type,
      ),
      CoachingInsightType.limitedConfidence => NextGamesFocus(
        title: 'Next 5 games focus',
        action: trustedRoleLabel == null
            ? 'Play 5 more games on $roleScopeLabel and a 2-hero block before judging this sample.'
            : 'Play 5 more $trustedRoleLabel games on a 2-hero block before judging this sample.',
        sourceLabel: topInsight.title,
        sourceType: topInsight.type,
      ),
    };
  }
}
