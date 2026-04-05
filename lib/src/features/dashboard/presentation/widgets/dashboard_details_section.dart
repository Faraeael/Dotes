import 'package:flutter/material.dart';

import '../../../checkpoints/domain/models/checkpoint_save_status_summary.dart';
import '../../../insights/domain/models/coaching_insight.dart';
import '../../../insights/presentation/widgets/coaching_insights_card.dart';
import '../../../matches/presentation/widgets/matches_overview_card.dart';
import '../../../player_import/domain/models/imported_player_data.dart';
import '../../../progress/domain/models/focus_follow_through_check.dart';
import '../../../progress/domain/models/progress_check.dart';
import '../../../progress/presentation/widgets/progress_check_card.dart';
import '../../../tester_feedback/domain/models/tester_feedback.dart';
import '../../../tester_feedback/presentation/widgets/tester_feedback_card.dart';
import '../../domain/models/comfort_core_summary.dart';
import '../../domain/models/training_history.dart';
import '../utils/imported_sample_summary.dart';
import 'comfort_core_card.dart';
import 'dashboard_section_group.dart';
import 'imported_sample_card.dart';
import 'training_history_card.dart';

class DashboardDetailsSection extends StatelessWidget {
  const DashboardDetailsSection({
    required this.importedPlayer,
    required this.sampleSummary,
    required this.coachingInsights,
    required this.detailsExpanded,
    required this.onToggleDetails,
    required this.onOpenHeroDetail,
    required this.onEditTesterFeedback,
    required this.onShowPlaytestSummary,
    this.progressCheck,
    this.focusFollowThrough,
    this.comfortCore,
    this.trainingHistory,
    this.checkpointSaveStatusSummary,
    this.testerFeedback,
    super.key,
  });

  final ImportedPlayerData importedPlayer;
  final ImportedSampleSummary sampleSummary;
  final List<CoachingInsight> coachingInsights;
  final bool detailsExpanded;
  final VoidCallback onToggleDetails;
  final ValueChanged<int> onOpenHeroDetail;
  final VoidCallback onEditTesterFeedback;
  final VoidCallback onShowPlaytestSummary;
  final ProgressCheck? progressCheck;
  final FocusFollowThroughCheck? focusFollowThrough;
  final ComfortCoreSummary? comfortCore;
  final TrainingHistory? trainingHistory;
  final CheckpointSaveStatusSummary? checkpointSaveStatusSummary;
  final TesterFeedback? testerFeedback;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionGroup(
      key: const ValueKey('details-section'),
      title: 'Details',
      subtitle:
          'Open the supporting read for more context, history, tester notes, and raw matches.',
      collapsible: true,
      isExpanded: detailsExpanded,
      onToggleExpanded: onToggleDetails,
      emptyMessage: 'No detail cards are available yet.',
      children: [
        ImportedSampleCard(
          matchesAnalyzed: sampleSummary.matchesAnalyzed,
          wins: sampleSummary.wins,
          losses: sampleSummary.losses,
          winRateLabel: sampleSummary.winRateLabel,
          uniqueHeroesPlayed: sampleSummary.uniqueHeroesPlayed,
          mostPlayedHeroLabel: sampleSummary.mostPlayedHeroLabel,
          primaryRoleLabel: sampleSummary.primaryRoleLabel,
          roleReasonLabel: sampleSummary.roleReasonLabel,
          roleMixDetailsLabel: sampleSummary.roleMixDetailsLabel,
          roleReadLabel: sampleSummary.roleReadLabel,
          primaryRoleAdherenceLabel: sampleSummary.primaryRoleAdherenceLabel,
          topHeroes: sampleSummary.topHeroes,
        ),
        if (progressCheck != null)
          ProgressCheckCard(
            progressCheck: progressCheck!,
            followThroughCheck: focusFollowThrough,
          ),
        if (comfortCore != null)
          ComfortCoreCard(
            summary: comfortCore!,
            onSelectHero: onOpenHeroDetail,
          ),
        CoachingInsightsCard(insights: coachingInsights),
        if (trainingHistory != null)
          TrainingHistoryCard(
            history: trainingHistory!,
            checkpointSaveStatusSummary: checkpointSaveStatusSummary,
          ),
        TesterFeedbackCard(
          feedback: testerFeedback,
          onEdit: onEditTesterFeedback,
          onShowSummary: onShowPlaytestSummary,
        ),
        MatchesOverviewCard(
          recentMatches: importedPlayer.recentMatches,
          onSelectHero: onOpenHeroDetail,
        ),
      ],
    );
  }
}
