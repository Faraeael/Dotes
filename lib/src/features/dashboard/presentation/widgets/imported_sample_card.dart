import 'package:flutter/material.dart';

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
            Text(
              'Imported sample',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Quick read on the current imported match sample.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SampleMetric(label: 'Matches', value: '$matchesAnalyzed'),
                _SampleMetric(label: 'Wins', value: '$wins'),
                _SampleMetric(label: 'Losses', value: '$losses'),
                _SampleMetric(label: 'Win rate', value: winRateLabel),
                _SampleMetric(
                  label: 'Unique heroes',
                  value: '$uniqueHeroesPlayed',
                ),
                if (mostPlayedHeroLabel != null)
                  _SampleMetric(
                    label: 'Most played',
                    value: mostPlayedHeroLabel!,
                  ),
                _SampleMetric(
                  label: 'Likely role',
                  value: primaryRoleLabel,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Role estimate: $roleReadLabel',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              roleReasonLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
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

class _SampleMetric extends StatelessWidget {
  const _SampleMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
