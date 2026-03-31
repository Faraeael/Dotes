import 'package:flutter/material.dart';

import '../../../player_import/domain/models/imported_player_data.dart';
import 'player_summary_card.dart';

class DashboardLoadedHeader extends StatelessWidget {
  const DashboardLoadedHeader({
    required this.importedPlayer,
    super.key,
  });

  final ImportedPlayerData importedPlayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        const SizedBox(height: 8),
        Text(
          importedPlayer.profile.displayName,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Read the current sample, lock the next 5-game plan, and keep the match context close.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        PlayerSummaryCard(profile: importedPlayer.profile),
      ],
    );
  }
}
