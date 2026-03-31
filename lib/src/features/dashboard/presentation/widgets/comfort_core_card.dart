import 'package:flutter/material.dart';

import '../../../../app/widgets/app_metric_grid.dart';
import '../../../matches/presentation/utils/hero_labels.dart';
import '../../domain/models/comfort_core_summary.dart';
import 'hero_link_chips.dart';
import 'section_card.dart';

class ComfortCoreCard extends StatelessWidget {
  const ComfortCoreCard({
    required this.summary,
    required this.onSelectHero,
    super.key,
  });

  final ComfortCoreSummary summary;
  final ValueChanged<int> onSelectHero;

  @override
  Widget build(BuildContext context) {
    if (!summary.isReady) {
      return SectionCard(title: 'Comfort core', body: summary.conclusion);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comfort core', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Checks whether recent results stay on a tight hero core.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            AppMetricGrid(
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
            if (summary.topHeroes.isNotEmpty) ...[
              const SizedBox(height: 12),
              HeroLinkChips(
                heroes: summary.topHeroes
                    .map(
                      (hero) => HeroLinkChipData(
                        heroId: hero.heroId,
                        label: heroDisplayName(hero.heroId),
                        detail: '${hero.matches} matches',
                      ),
                    )
                    .toList(growable: false),
                onSelectHero: onSelectHero,
              ),
            ],
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

  String _recordLabel({required int wins, required int losses}) {
    final totalMatches = wins + losses;
    final winRate = totalMatches == 0
        ? 0
        : ((wins / totalMatches) * 100).round();
    return '$wins-$losses ($winRate%)';
  }
}

class _ComfortMetric extends StatelessWidget {
  const _ComfortMetric({required this.label, required this.value});

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
