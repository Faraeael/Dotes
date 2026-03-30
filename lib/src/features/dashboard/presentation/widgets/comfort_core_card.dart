import 'package:flutter/material.dart';

import '../../../matches/presentation/utils/hero_labels.dart';
import '../../domain/models/comfort_core_summary.dart';
import 'section_card.dart';

class ComfortCoreCard extends StatelessWidget {
  const ComfortCoreCard({
    required this.summary,
    super.key,
  });

  final ComfortCoreSummary summary;

  @override
  Widget build(BuildContext context) {
    if (!summary.isReady) {
      return SectionCard(
        title: 'Comfort core',
        body: summary.conclusion,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comfort core',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'A quick coaching read on whether recent results stay on a small hero core.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ComfortMetric(
                  label: 'Top 2 heroes',
                  value: _topHeroesLabel(summary.topHeroes),
                ),
                _ComfortMetric(
                  label: 'On top 2',
                  value: _recordLabel(
                    wins: summary.topHeroWins,
                    losses: summary.topHeroLosses,
                  ),
                ),
                _ComfortMetric(
                  label: 'On others',
                  value: _recordLabel(
                    wins: summary.otherHeroWins,
                    losses: summary.otherHeroLosses,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              summary.conclusion,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _topHeroesLabel(List<ComfortCoreHeroUsage> heroes) {
    return heroes
        .map((hero) => '${heroDisplayName(hero.heroId)} (${hero.matches})')
        .join(', ');
  }

  String _recordLabel({
    required int wins,
    required int losses,
  }) {
    final totalMatches = wins + losses;
    final winRate = totalMatches == 0 ? 0 : ((wins / totalMatches) * 100).round();
    return '$wins-$losses ($winRate%)';
  }
}

class _ComfortMetric extends StatelessWidget {
  const _ComfortMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 140),
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
