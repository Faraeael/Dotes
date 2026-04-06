import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/widgets/app_status_badge.dart';
import '../../../player_import/application/play_frequency_provider.dart';
import '../../../player_import/domain/models/imported_player_data.dart';
import 'player_summary_card.dart';

class DashboardLoadedHeader extends ConsumerWidget {
  const DashboardLoadedHeader({
    required this.importedPlayer,
    super.key,
  });

  final ImportedPlayerData importedPlayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final playFrequency = ref.watch(playFrequencyProvider);
    final rankLabel = importedPlayer.profile.rankLabel;
    final cadenceLabel = playFrequency?.cadenceLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Competitive coach',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 0.6,
          ),
        ),
        if (importedPlayer.source.isDemo) ...[
          const SizedBox(height: 8),
          AppStatusBadge(
            label:
                'Demo scenario: ${importedPlayer.source.scenarioLabel ?? importedPlayer.profile.displayName}',
            tone: AppStatusTone.warning,
          ),
        ],
        const SizedBox(height: 8),
        Text(
          importedPlayer.profile.displayName,
          style: theme.textTheme.headlineMedium,
        ),
        if (rankLabel != null || cadenceLabel != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (rankLabel != null)
                AppStatusBadge(
                  label: rankLabel,
                  tone: AppStatusTone.info,
                ),
              if (cadenceLabel != null)
                AppStatusBadge(
                  label: cadenceLabel,
                  tone: AppStatusTone.info,
                ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Read the current sample, lock the next plan, and keep the match context close.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        PlayerSummaryCard(
          profile: importedPlayer.profile,
          source: importedPlayer.source,
        ),
      ],
    );
  }
}
