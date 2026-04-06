import 'package:flutter/material.dart';

import '../../../checkpoints/domain/models/checkpoint_save_status_summary.dart';
import '../../../checkpoints/domain/models/training_block_action.dart';
import '../../../insights/domain/models/coaching_insight.dart';
import '../../../insights/domain/models/next_games_focus.dart';
import '../../../insights/presentation/widgets/next_games_focus_card.dart';
import '../../../player_import/domain/models/imported_player_data.dart';
import '../../../progress/domain/models/focus_follow_through_check.dart';
import '../../../progress/domain/models/progress_check.dart';
import '../../../tester_feedback/domain/models/tester_feedback.dart';
import '../../../training_preferences/domain/models/coaching_source_summary.dart';
import '../../../training_preferences/presentation/widgets/training_setup_card.dart';
import '../../domain/models/block_review.dart';
import '../../domain/models/comfort_core_summary.dart';
import '../../domain/models/dashboard_onboarding_guide.dart';
import '../../domain/models/dashboard_verdict.dart';
import '../../domain/models/end_block_summary.dart';
import '../../domain/models/saved_block_summary.dart';
import '../../domain/models/session_plan.dart';
import '../../domain/models/session_plan_meta_sanity.dart';
import '../../domain/models/training_history.dart';
import '../utils/imported_sample_summary.dart';
import 'block_review_card.dart';
import 'dashboard_details_section.dart';
import 'dashboard_loaded_header.dart';
import 'dashboard_onboarding_card.dart';
import 'dashboard_section_group.dart';
import 'dashboard_shell.dart';
import 'end_block_summary_card.dart';
import 'player_import_card.dart';
import 'session_plan_card.dart';
import 'verdict_card.dart';

class DashboardLoadedView extends StatelessWidget {
  const DashboardLoadedView({
    required this.importedPlayer,
    required this.sampleSummary,
    required this.coachingInsights,
    required this.trainingHistory,
    required this.savedBlockSummaries,
    required this.detailsExpanded,
    required this.onToggleDetails,
    required this.onOpenHeroDetail,
    required this.onEditTrainingPreferences,
    required this.onEditTesterFeedback,
    required this.onShowPlaytestSummary,
    required this.onCopySavedSummary,
    required this.onStartTrainingBlock,
    required this.onDismissOnboarding,
    required this.onShowHowItWorks,
    required this.onGoToImport,
    this.onSaveEndBlockSummary,
    this.dashboardVerdict,
    this.blockReview,
    this.endBlockSummary,
    this.sessionPlan,
    this.sessionPlanMetaSanity,
    this.nextGamesFocus,
    this.progressCheck,
    this.focusFollowThrough,
    this.comfortCore,
    this.testerFeedback,
    this.coachingSourceSummary,
    this.checkpointSaveStatusSummary,
    this.trainingBlockActionControl,
    this.isStartingTrainingBlock = false,
    this.onboardingGuide,
    super.key,
  });

  final ImportedPlayerData importedPlayer;
  final ImportedSampleSummary sampleSummary;
  final List<CoachingInsight> coachingInsights;
  final TrainingHistory? trainingHistory;
  final List<SavedBlockSummary> savedBlockSummaries;
  final bool detailsExpanded;
  final VoidCallback onToggleDetails;
  final ValueChanged<int> onOpenHeroDetail;
  final VoidCallback onEditTrainingPreferences;
  final VoidCallback onEditTesterFeedback;
  final VoidCallback onShowPlaytestSummary;
  final ValueChanged<String> onCopySavedSummary;
  final VoidCallback onStartTrainingBlock;
  final VoidCallback onDismissOnboarding;
  final VoidCallback onShowHowItWorks;
  final VoidCallback onGoToImport;
  final VoidCallback? onSaveEndBlockSummary;
  final DashboardVerdict? dashboardVerdict;
  final BlockReview? blockReview;
  final EndBlockSummary? endBlockSummary;
  final SessionPlan? sessionPlan;
  final NextGamesFocus? nextGamesFocus;
  final SessionPlanMetaSanity? sessionPlanMetaSanity;
  final ProgressCheck? progressCheck;
  final FocusFollowThroughCheck? focusFollowThrough;
  final ComfortCoreSummary? comfortCore;
  final TesterFeedback? testerFeedback;
  final CoachingSourceSummary? coachingSourceSummary;
  final CheckpointSaveStatusSummary? checkpointSaveStatusSummary;
  final TrainingBlockActionControl? trainingBlockActionControl;
  final bool isStartingTrainingBlock;
  final DashboardOnboardingGuide? onboardingGuide;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: importedPlayer.profile.displayName,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          DashboardLoadedHeader(importedPlayer: importedPlayer),
          const SizedBox(height: 24),
          DashboardSectionGroup(
            key: const ValueKey('core-coaching-section'),
            title: 'Core coaching',
            subtitle:
                'Start here for the current read and the next block to play.',
            emptyMessage:
                'Core coaching cards appear once the sample is ready.',
            children: [
              if (onboardingGuide != null)
                DashboardOnboardingCard(
                  guide: onboardingGuide!,
                  onDismiss: onDismissOnboarding,
                ),
              if (dashboardVerdict != null)
                VerdictCard(verdict: dashboardVerdict!),
              if (blockReview != null) BlockReviewCard(review: blockReview!),
              if (endBlockSummary != null)
                EndBlockSummaryCard(
                  summary: endBlockSummary!,
                  onSaveSummary: onSaveEndBlockSummary,
                ),
              if (sessionPlan != null)
                SessionPlanCard(
                  plan: sessionPlan!,
                  metaSanity: sessionPlanMetaSanity,
                  onSelectHero: onOpenHeroDetail,
                  trainingBlockActionControl: trainingBlockActionControl,
                  onStartTrainingBlock: onStartTrainingBlock,
                  isStartingTrainingBlock: isStartingTrainingBlock,
                ),
              if (nextGamesFocus != null)
                NextGamesFocusCard(focus: nextGamesFocus!),
              if (coachingSourceSummary != null)
                TrainingSetupCard(
                  summary: coachingSourceSummary!,
                  onEdit: onEditTrainingPreferences,
                  onShowHowItWorks: onShowHowItWorks,
                ),
            ],
          ),
          const SizedBox(height: 24),
          DashboardDetailsSection(
            importedPlayer: importedPlayer,
            sampleSummary: sampleSummary,
            coachingInsights: coachingInsights,
            progressCheck: progressCheck,
            focusFollowThrough: focusFollowThrough,
            comfortCore: comfortCore,
            trainingHistory: trainingHistory,
            checkpointSaveStatusSummary: checkpointSaveStatusSummary,
            testerFeedback: testerFeedback,
            savedBlockSummaries: savedBlockSummaries,
            detailsExpanded: detailsExpanded,
            onToggleDetails: onToggleDetails,
            onOpenHeroDetail: onOpenHeroDetail,
            onEditTesterFeedback: onEditTesterFeedback,
            onShowPlaytestSummary: onShowPlaytestSummary,
            onCopySavedSummary: onCopySavedSummary,
          ),
          const SizedBox(height: 24),
          PlayerImportCard(
            importedPlayer: importedPlayer,
            onGoToImport: onGoToImport,
          ),
        ],
      ),
    );
  }
}
