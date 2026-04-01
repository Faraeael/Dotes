import 'package:flutter/material.dart';

import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../../../app/widgets/app_status_badge.dart';
import '../../domain/models/hero_compare_block_actions.dart';
import '../../../hero_detail/domain/models/hero_detail.dart';

class HeroCompareHeroCard extends StatelessWidget {
  const HeroCompareHeroCard({
    required this.detail,
    required this.blockAction,
    required this.onUseHero,
    super.key,
  });

  final HeroDetail detail;
  final HeroCompareBlockActionEntry blockAction;
  final Future<void> Function() onUseHero;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(detail.heroName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            AppMetricGrid(
              children: [
                AppMetricTile(label: 'Matches', value: '${detail.matchesInSample}'),
                AppMetricTile(label: 'Wins', value: '${detail.wins}'),
                AppMetricTile(label: 'Losses', value: '${detail.losses}'),
                AppMetricTile(label: 'Win rate', value: '${detail.winRatePercentage}%'),
                AppMetricTile(
                  label: 'Average deaths',
                  value: detail.averageDeaths?.toStringAsFixed(1) ?? '-',
                ),
                AppMetricTile(
                  label: 'Meta',
                  value: detail.metaSummary.reference?.tier.label ??
                      'No meta reference',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _statusBadge(
                  label: detail.tags.contains(HeroDetailTag.comfortCore)
                      ? 'Comfort core'
                      : 'Outside comfort core',
                  tone: detail.tags.contains(HeroDetailTag.comfortCore)
                      ? AppStatusTone.info
                      : AppStatusTone.neutral,
                ),
                _statusBadge(
                  label: detail.tags.contains(HeroDetailTag.inCurrentPlan)
                      ? 'In current plan'
                      : 'Outside current plan',
                  tone: detail.tags.contains(HeroDetailTag.inCurrentPlan)
                      ? AppStatusTone.positive
                      : AppStatusTone.warning,
                ),
                if (blockAction.isAlreadyInBlock)
                  _statusBadge(
                    label: 'Already in block',
                    tone: AppStatusTone.positive,
                  ),
              ],
            ),
            if (detail.blockContext != null) ...[
              const SizedBox(height: 12),
              Text(
                'Block context: ${detail.blockContext!.lastPlanStatus.label}. ${detail.blockContext!.trendStatus.label}.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onUseHero,
                child: Text(blockAction.actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge({
    required String label,
    required AppStatusTone tone,
  }) {
    return AppStatusBadge(label: label, tone: tone);
  }
}
