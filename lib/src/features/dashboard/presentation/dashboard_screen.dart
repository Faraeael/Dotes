import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_router.dart';
import '../../../features/checkpoints/application/coaching_checkpoint_providers.dart';
import '../../../features/insights/application/coaching_insights_provider.dart';
import '../../../features/insights/presentation/widgets/coaching_insights_card.dart';
import '../../../features/insights/presentation/widgets/next_games_focus_card.dart';
import '../../../features/matches/presentation/widgets/matches_overview_card.dart';
import '../../../features/player_import/application/imported_player_provider.dart';
import '../../../features/player_import/application/player_import_controller.dart';
import '../../../features/progress/application/progress_check_provider.dart';
import '../../../features/progress/presentation/widgets/progress_check_card.dart';
import '../../../features/roles/application/sample_role_summary_provider.dart';
import 'utils/imported_sample_summary.dart';
import 'widgets/dashboard_shell.dart';
import 'widgets/imported_sample_card.dart';
import 'widgets/player_summary_card.dart';
import 'widgets/section_card.dart';

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

    void goToImport() {
      ref.read(playerImportControllerProvider.notifier).reset();
      Navigator.of(context).pushReplacementNamed(AppRoutes.importPlayer);
    }

    if (importedPlayer == null) {
      return DashboardShell(
        title: 'Dashboard',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SectionCard(
                title: 'No imported player yet',
                body:
                    'Start from the import screen to load a live OpenDota profile and recent matches for this dashboard.',
                action: OutlinedButton(
                  onPressed: goToImport,
                  child: const Text('Back to import'),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final sampleSummary = ImportedSampleSummary.fromImportedPlayer(
      importedPlayer,
      sampleRoleSummary!,
    );

    return DashboardShell(
      title: 'Dashboard',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            importedPlayer.profile.displayName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This dashboard shows the imported sample, a simple progress check, coaching signals, and recent matches at a glance.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          PlayerSummaryCard(profile: importedPlayer.profile),
          const SizedBox(height: 16),
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
          ),
          const SizedBox(height: 16),
          if (progressCheck != null) ...[
            ProgressCheckCard(
              progressCheck: progressCheck,
              followThroughCheck: focusFollowThrough,
            ),
            const SizedBox(height: 16),
          ],
          if (nextGamesFocus != null) ...[
            NextGamesFocusCard(focus: nextGamesFocus),
            const SizedBox(height: 16),
          ],
          CoachingInsightsCard(insights: coachingInsights),
          const SizedBox(height: 16),
          MatchesOverviewCard(recentMatches: importedPlayer.recentMatches),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Player import',
            body:
                'The import flow now validates the ID, fetches the player summary, loads recent matches, stores the result in Riverpod, and only then routes here.',
            action: OutlinedButton(
              onPressed: goToImport,
              child: const Text('Change player'),
            ),
          ),
        ],
      ),
    );
  }
}
