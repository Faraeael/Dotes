import 'package:flutter/material.dart';

import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../domain/models/hero_detail.dart';

class HeroDetailHeaderCard extends StatelessWidget {
  const HeroDetailHeaderCard({required this.detail, super.key});

  final HeroDetail detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.heroName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (detail.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: detail.tags
                    .map((tag) => _HeroDetailTagChip(tag: tag))
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 16),
            AppMetricGrid(
              children: [
                AppMetricTile(
                  label: 'Matches in sample',
                  value: '${detail.matchesInSample}',
                ),
                AppMetricTile(label: 'Wins', value: '${detail.wins}'),
                AppMetricTile(label: 'Losses', value: '${detail.losses}'),
                AppMetricTile(
                  label: 'Win rate',
                  value: '${detail.winRatePercentage}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroDetailTagChip extends StatelessWidget {
  const _HeroDetailTagChip({required this.tag});

  final HeroDetailTag tag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = switch (tag) {
      HeroDetailTag.comfortCore => theme.colorScheme.secondaryContainer,
      HeroDetailTag.inCurrentPlan => theme.colorScheme.primaryContainer,
      HeroDetailTag.outsideCurrentPlan =>
        theme.colorScheme.surfaceContainerHighest,
    };
    final foregroundColor = switch (tag) {
      HeroDetailTag.comfortCore => theme.colorScheme.onSecondaryContainer,
      HeroDetailTag.inCurrentPlan => theme.colorScheme.onPrimaryContainer,
      HeroDetailTag.outsideCurrentPlan => theme.colorScheme.onSurfaceVariant,
    };

    return Chip(
      label: Text(tag.label),
      backgroundColor: backgroundColor,
      labelStyle: theme.textTheme.labelLarge?.copyWith(color: foregroundColor),
      side: BorderSide(color: foregroundColor.withAlpha(48)),
    );
  }
}
