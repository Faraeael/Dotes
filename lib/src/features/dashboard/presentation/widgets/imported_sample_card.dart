import 'package:flutter/material.dart';

import '../../../../app/widgets/app_card_header.dart';
import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';

class ImportedSampleCard extends StatelessWidget {
  const ImportedSampleCard({
    required this.matchesAnalyzed,
    required this.wins,
    required this.losses,
    required this.winRateLabel,
    required this.uniqueHeroesPlayed,
    required this.mostPlayedHeroLabel,
    required this.primaryRoleLabel,
    required this.roleReasonLabel,
    required this.roleMixDetailsLabel,
    required this.roleReadLabel,
    super.key,
  });

  final int matchesAnalyzed;
  final int wins;
  final int losses;
  final String winRateLabel;
  final int uniqueHeroesPlayed;
  final String? mostPlayedHeroLabel;
  final String primaryRoleLabel;
  final String roleReasonLabel;
  final String? roleMixDetailsLabel;
  final String roleReadLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppCardHeader(
              title: 'Current sample',
              subtitle: 'Quick read on the current match sample.',
            ),
            const SizedBox(height: 16),
            AppMetricGrid(
              children: [
                AppMetricTile(label: 'Matches', value: '$matchesAnalyzed'),
                AppMetricTile(label: 'Wins', value: '$wins'),
                AppMetricTile(label: 'Losses', value: '$losses'),
                AppMetricTile(label: 'Win rate', value: winRateLabel),
                AppMetricTile(
                  label: 'Unique heroes',
                  value: '$uniqueHeroesPlayed',
                ),
                if (mostPlayedHeroLabel != null)
                  AppMetricTile(
                    label: 'Most played',
                    value: mostPlayedHeroLabel!,
                  ),
                AppMetricTile(label: 'Likely role', value: primaryRoleLabel),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Role confidence: $roleReadLabel',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(roleReasonLabel, style: Theme.of(context).textTheme.bodySmall),
            if (roleMixDetailsLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                roleMixDetailsLabel!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
