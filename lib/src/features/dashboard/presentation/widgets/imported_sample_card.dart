import 'package:flutter/material.dart';

import '../../../../app/widgets/app_reason_list.dart';
import '../../../../app/widgets/app_card_header.dart';
import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../utils/imported_sample_summary.dart';

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
    required this.roleRationaleLines,
    required this.roleMixDetailsLabel,
    required this.roleReadLabel,
    required this.primaryRoleAdherenceLabel,
    required this.topHeroes,
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
  final List<String> roleRationaleLines;
  final String? roleMixDetailsLabel;
  final String roleReadLabel;
  final String? primaryRoleAdherenceLabel;
  final List<HeroWinRateStat> topHeroes;

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
                if (primaryRoleAdherenceLabel != null)
                  AppMetricTile(
                    label: 'Role %',
                    value: primaryRoleAdherenceLabel!,
                  ),
              ],
            ),
            if (topHeroes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Top heroes', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              AppMetricGrid(
                children: [
                  for (final hero in topHeroes)
                    AppMetricTile(
                      label: hero.heroName,
                      value: '${hero.winRatePercent}% · ${hero.games}g',
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Role confidence: $roleReadLabel',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(roleReasonLabel, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Text(
              'Why this role read',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            AppReasonList(reasons: roleRationaleLines),
            if (roleMixDetailsLabel != null) ...[
              const SizedBox(height: 8),
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
