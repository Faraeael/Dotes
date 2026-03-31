import 'package:flutter/material.dart';

import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../../../app/widgets/app_status_badge.dart';
import '../../../matches/presentation/utils/match_formatters.dart';
import '../../domain/models/hero_detail.dart';

class HeroDetailSummaryCard extends StatelessWidget {
  const HeroDetailSummaryCard({required this.detail, super.key});

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
              'Performance summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AppMetricGrid(
              children: [
                AppMetricTile(
                  label: 'Average deaths',
                  value: _formatAverage(detail.averageDeaths),
                ),
                AppMetricTile(
                  label: 'Average KDA',
                  value: _formatAverage(detail.averageKda),
                ),
                AppMetricTile(
                  label: 'Average duration',
                  value: detail.averageMatchDuration == null
                      ? '-'
                      : formatMatchDuration(detail.averageMatchDuration!),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Coaching read',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(detail.coachingRead),
            const SizedBox(height: 20),
            Text(
              'Training decision',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            AppStatusBadge(
              label: detail.trainingDecision.label,
              tone: _decisionTone(detail.trainingDecision),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAverage(double? value) {
    if (value == null) {
      return '-';
    }

    return value.toStringAsFixed(1);
  }

  AppStatusTone _decisionTone(HeroTrainingDecision decision) {
    return switch (decision) {
      HeroTrainingDecision.keepInBlock => AppStatusTone.positive,
      HeroTrainingDecision.goodBackupHero => AppStatusTone.info,
      HeroTrainingDecision.testLaterNotNow => AppStatusTone.warning,
      HeroTrainingDecision.tooLittleData => AppStatusTone.neutral,
    };
  }
}
