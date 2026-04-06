import 'package:flutter/material.dart';

import '../../../../app/widgets/app_metric_tile.dart';
import '../../../../app/widgets/app_status_badge.dart';
import '../../domain/models/training_history.dart';

class TrainingHistoryTrendPanel extends StatelessWidget {
  const TrainingHistoryTrendPanel({required this.trend, super.key});

  final TrainingHistoryTrend trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppStatusBadge(label: trend.headline, tone: _toneForTrend(trend)),
          const SizedBox(height: 8),
          Text(
            trend.detail,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (trend.completedCycles > 0) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                AppMetricTile(
                  label: 'Cycles',
                  value: '${trend.completedCycles}',
                  minWidth: 90,
                ),
                AppMetricTile(
                  label: 'On track',
                  value: '${trend.onTrackCount}',
                  minWidth: 90,
                ),
                AppMetricTile(
                  label: 'Streak',
                  value: '${trend.currentStreakCount}',
                  minWidth: 90,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  AppStatusTone _toneForTrend(TrainingHistoryTrend trend) {
    if (trend.currentStreakOutcome == TrainingCycleOutcome.onTrack) {
      return AppStatusTone.positive;
    }
    if (trend.currentStreakOutcome == TrainingCycleOutcome.offTrack) {
      return AppStatusTone.negative;
    }
    return AppStatusTone.warning;
  }
}
