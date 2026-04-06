import 'package:flutter/material.dart';

import '../../../../app/widgets/app_card_header.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../../../app/widgets/app_status_badge.dart';
import '../../../checkpoints/domain/models/checkpoint_save_status_summary.dart';
import '../../domain/models/training_history.dart';
import 'training_history_trend_panel.dart';

class TrainingHistoryCard extends StatelessWidget {
  const TrainingHistoryCard({
    required this.history,
    this.checkpointSaveStatusSummary,
    super.key,
  });

  final TrainingHistory history;
  final CheckpointSaveStatusSummary? checkpointSaveStatusSummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppCardHeader(
              title: 'Training history',
              subtitle: 'Recent coaching cycles for this account.',
            ),
            if (checkpointSaveStatusSummary != null) ...[
              const SizedBox(height: 12),
              _CheckpointSaveStatusPanel(summary: checkpointSaveStatusSummary!),
            ],
            const SizedBox(height: 12),
            TrainingHistoryTrendPanel(trend: history.trend),
            const SizedBox(height: 8),
            if (!history.hasEntries)
              Text(history.fallbackMessage!, style: theme.textTheme.bodyMedium)
            else ...[
              const SizedBox(height: 8),
              for (var index = 0; index < history.entries.length; index++) ...[
                _TrainingHistoryRow(entry: history.entries[index]),
                if (index < history.entries.length - 1)
                  const Divider(height: 20),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckpointSaveStatusPanel extends StatelessWidget {
  const _CheckpointSaveStatusPanel({required this.summary});

  final CheckpointSaveStatusSummary summary;

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
          AppStatusBadge(
            label: summary.headline,
            tone: _toneForHeadline(summary.headline),
          ),
          if (summary.detail != null) ...[
            const SizedBox(height: 8),
            Text(
              summary.detail!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrainingHistoryRow extends StatelessWidget {
  const _TrainingHistoryRow({required this.entry});

  final TrainingHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _formatDate(entry.savedAt),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            AppStatusBadge(
              label: entry.outcome.label,
              tone: switch (entry.outcome) {
                TrainingCycleOutcome.onTrack => AppStatusTone.positive,
                TrainingCycleOutcome.mixed => AppStatusTone.warning,
                TrainingCycleOutcome.offTrack => AppStatusTone.negative,
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(entry.focusLabel, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(entry.resultSummary, style: theme.textTheme.bodyMedium),
        if (entry.deathsAverage != null || entry.winRatePercent != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (entry.deathsAverage != null)
                AppMetricTile(
                  label: 'Deaths avg',
                  value: entry.deathsAverage!.toStringAsFixed(1),
                  minWidth: 100,
                ),
              if (entry.winRatePercent != null)
                AppMetricTile(
                  label: 'Win rate',
                  value: '${entry.winRatePercent!.toStringAsFixed(0)}%',
                  minWidth: 100,
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime savedAt) {
    final local = savedAt.toLocal();
    final month = _monthLabels[local.month - 1];
    return '$month ${local.day}, ${local.year}';
  }
}

AppStatusTone _toneForHeadline(String headline) {
  final lower = headline.toLowerCase();
  if (lower.contains('saved')) {
    return AppStatusTone.positive;
  }

  if (lower.contains('waiting')) {
    return AppStatusTone.info;
  }

  if (lower.contains('overlap') || lower.contains('no new matches')) {
    return AppStatusTone.warning;
  }

  return AppStatusTone.neutral;
}

const _monthLabels = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
