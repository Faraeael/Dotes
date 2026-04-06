import 'package:flutter/material.dart';

import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../domain/models/hero_detail.dart';

class HeroDetailBlockContextCard extends StatelessWidget {
  const HeroDetailBlockContextCard({required this.blockContext, super.key});

  final HeroBlockContext blockContext;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Block context',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AppMetricGrid(
              children: [
                AppMetricTile(
                  label: 'Last plan',
                  value: blockContext.lastPlanStatus.label,
                ),
                AppMetricTile(
                  label: 'Block appearances',
                  value:
                      '${blockContext.reviewedBlockAppearances} of ${blockContext.reviewedBlockGames}',
                ),
                AppMetricTile(
                  label: 'Hero trend',
                  value: blockContext.trendStatus.label,
                  detail: blockContext.trendDetail,
                ),
                AppMetricTile(
                  label: 'Before block',
                  value: blockContext.baselineWinRatePercentage == null
                      ? '-'
                      : '${blockContext.baselineWinRatePercentage}%',
                ),
                AppMetricTile(
                  label: 'In block',
                  value: blockContext.reviewedBlockWinRatePercentage == null
                      ? '-'
                      : '${blockContext.reviewedBlockWinRatePercentage}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
