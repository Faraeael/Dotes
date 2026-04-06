import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_router.dart';
import '../../../features/checkpoints/application/coaching_checkpoint_providers.dart';
import '../../../features/checkpoints/application/training_block_action_providers.dart';
import '../../../features/dashboard/application/block_review_provider.dart';
import '../../../features/dashboard/application/comfort_core_provider.dart';
import '../../../features/dashboard/application/dashboard_layout_providers.dart';
import '../../../features/dashboard/application/dashboard_onboarding_providers.dart';
import '../../../features/dashboard/application/dashboard_verdict_provider.dart';
import '../../../features/dashboard/application/end_block_summary_provider.dart';
import '../../../features/dashboard/application/saved_block_summary_providers.dart';
import '../../../features/dashboard/application/session_plan_provider.dart';
import '../../../features/dashboard/application/training_history_provider.dart';
import '../../../features/dashboard/domain/services/block_summary_export_service.dart';
import '../../../features/hero_detail/presentation/hero_detail_screen.dart';
import '../../../features/insights/application/coaching_insights_provider.dart';
import '../../../features/player_import/application/imported_player_provider.dart';
import '../../../features/player_import/application/player_import_controller.dart';
import '../../../features/progress/application/progress_check_provider.dart';
import '../../../features/roles/application/sample_role_summary_provider.dart';
import '../../../features/tester_feedback/application/playtest_summary_providers.dart';
import '../../../features/tester_feedback/application/tester_feedback_providers.dart';
import '../../../features/tester_feedback/presentation/widgets/playtest_summary_dialog.dart';
import '../../../features/tester_feedback/presentation/widgets/tester_feedback_dialog.dart';
import '../../../features/training_preferences/application/training_preferences_providers.dart';
import '../../../features/training_preferences/presentation/widgets/training_preferences_dialog.dart';
import 'utils/imported_sample_summary.dart';
import 'widgets/block_summary_export_dialog.dart';
import 'widgets/dashboard_empty_view.dart';
import 'widgets/dashboard_loaded_view.dart';
import 'widgets/practice_note_dialog.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(currentCoachingCheckpointDraftProvider, (previous, next) {
      if (next == null) {
        return;
      }

      unawaited(
        ref
            .read(checkpointPersistenceControllerProvider)
            .saveCurrentDraftIfNeeded(next),
      );
    });

    final importedPlayer = ref.watch(importedPlayerProvider);
    final coachingInsights = ref.watch(coachingInsightsProvider);
    final nextGamesFocus = ref.watch(nextGamesFocusProvider);
    final progressCheck = ref.watch(progressCheckProvider);
    final focusFollowThrough = ref.watch(focusFollowThroughProvider);
    final sampleRoleSummary = ref.watch(sampleRoleSummaryProvider);
    final comfortCore = ref.watch(comfortCoreProvider);
    final dashboardVerdict = ref.watch(dashboardVerdictProvider);
    final blockReview = ref.watch(blockReviewProvider);
    final endBlockSummary = ref.watch(endBlockSummaryProvider);
    final savedBlockSummaries = ref.watch(currentSavedBlockSummariesProvider);
    final sessionPlan = ref.watch(sessionPlanProvider);
    final sessionPlanMetaSanity = ref.watch(sessionPlanMetaSanityProvider);
    final trainingHistory = ref.watch(trainingHistoryProvider);
    final checkpointSaveStatusSummary = ref.watch(
      checkpointSaveStatusSummaryProvider,
    );
    final trainingBlockActionControl = ref.watch(
      trainingBlockActionControlProvider,
    );
    final isStartingTrainingBlock = ref.watch(trainingBlockActionBusyProvider);
    final showDashboardOnboarding = ref.watch(
      dashboardOnboardingVisibleProvider,
    );
    final detailsExpanded = ref.watch(dashboardDetailsExpandedProvider);
    final testerFeedback = ref.watch(currentTesterFeedbackProvider);
    final trainingPreferences = ref.watch(currentTrainingPreferencesProvider);
    final coachingSourceSummary = ref.watch(coachingSourceSummaryProvider);
    final onboardingGuide = showDashboardOnboarding
        ? ref.watch(dashboardOnboardingGuideProvider)
        : null;

    void goToImport() {
      ref.read(playerImportControllerProvider.notifier).reset();
      Navigator.of(context).pushReplacementNamed(AppRoutes.importPlayer);
    }

    Future<void> editTrainingPreferences() async {
      if (importedPlayer == null) {
        return;
      }

      final updatedPreferences = await TrainingPreferencesDialog.show(
        context,
        initialPreferences: trainingPreferences,
      );
      if (updatedPreferences == null) {
        return;
      }

      await ref
          .read(trainingPreferencesControllerProvider)
          .saveForAccount(importedPlayer.profile.accountId, updatedPreferences);
    }

    Future<void> editTesterFeedback() async {
      if (importedPlayer == null) {
        return;
      }

      final updatedFeedback = await TesterFeedbackDialog.show(
        context,
        initialFeedback: testerFeedback,
      );
      if (updatedFeedback == null) {
        return;
      }

      await ref
          .read(testerFeedbackControllerProvider)
          .saveForAccount(
            importedPlayer.profile.accountId,
            updatedFeedback,
            playerLabel: importedPlayer.profile.displayName,
          );
    }

    Future<void> showPlaytestSummary() async {
      ref.read(playtestSummaryFilterProvider.notifier).state = null;
      await PlaytestSummaryDialog.show(context);
    }

    Future<void> saveEndBlockSummary() async {
      if (importedPlayer == null) {
        return;
      }

      final practiceNote = await PracticeNoteDialog.show(context);
      if (!context.mounted || practiceNote == null) {
        return;
      }

      final exportSummary = const BlockSummaryExportService().build(
        completedSummary: endBlockSummary,
        activeStartedCheckpoint: ref.read(previousCoachingCheckpointProvider),
        importedPlayer: importedPlayer,
        practiceNote: practiceNote,
      );
      if (exportSummary == null) {
        return;
      }

      await ref
          .read(savedBlockSummaryControllerProvider)
          .saveForAccount(importedPlayer.profile.accountId, exportSummary);
      if (!context.mounted) {
        return;
      }

      await BlockSummaryExportDialog.show(
        context,
        summary: exportSummary,
        savedToHistory: true,
      );
    }

    Future<void> copySavedSummary(String shareText) async {
      await Clipboard.setData(ClipboardData(text: shareText));
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved summary copied for sharing')),
      );
    }

    if (importedPlayer == null || sampleRoleSummary == null) {
      return DashboardEmptyView(onGoToImport: goToImport);
    }

    final sampleSummary = ImportedSampleSummary.fromImportedPlayer(
      importedPlayer,
      sampleRoleSummary,
    );

    return DashboardLoadedView(
      importedPlayer: importedPlayer,
      sampleSummary: sampleSummary,
      coachingInsights: coachingInsights,
      nextGamesFocus: nextGamesFocus,
      progressCheck: progressCheck,
      focusFollowThrough: focusFollowThrough,
      comfortCore: comfortCore,
      testerFeedback: testerFeedback,
      savedBlockSummaries: savedBlockSummaries,
      dashboardVerdict: dashboardVerdict,
      blockReview: blockReview,
      endBlockSummary: endBlockSummary,
      sessionPlan: sessionPlan,
      sessionPlanMetaSanity: sessionPlanMetaSanity,
      trainingHistory: trainingHistory,
      checkpointSaveStatusSummary: checkpointSaveStatusSummary,
      trainingBlockActionControl: trainingBlockActionControl,
      isStartingTrainingBlock: isStartingTrainingBlock,
      coachingSourceSummary: coachingSourceSummary,
      onboardingGuide: onboardingGuide,
      detailsExpanded: detailsExpanded,
      onOpenHeroDetail: (heroId) {
        Navigator.of(context).push(HeroDetailScreen.route(heroId));
      },
      onToggleDetails: () {
        ref.read(dashboardDetailsExpandedProvider.notifier).state =
            !detailsExpanded;
      },
      onDismissOnboarding: () {
        unawaited(
          ref.read(dashboardOnboardingControllerProvider.notifier).dismiss(),
        );
      },
      onStartTrainingBlock: () {
        unawaited(
          ref
              .read(trainingBlockActionControllerProvider)
              .startOrRestartCurrentBlock(),
        );
      },
      onShowHowItWorks: () {
        ref.read(dashboardOnboardingControllerProvider.notifier).showGuide();
      },
      onEditTrainingPreferences: () {
        unawaited(editTrainingPreferences());
      },
      onEditTesterFeedback: () {
        unawaited(editTesterFeedback());
      },
      onShowPlaytestSummary: () {
        unawaited(showPlaytestSummary());
      },
      onSaveEndBlockSummary: endBlockSummary == null
          ? null
          : () {
              unawaited(saveEndBlockSummary());
            },
      onCopySavedSummary: (shareText) {
        unawaited(copySavedSummary(shareText));
      },
      onGoToImport: goToImport,
    );
  }
}
