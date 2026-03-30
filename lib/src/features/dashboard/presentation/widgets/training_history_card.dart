import 'package:flutter/material.dart';

import '../../domain/models/training_history.dart';

class TrainingHistoryCard extends StatelessWidget {
  const TrainingHistoryCard({
    required this.history,
    super.key,
  });

  final TrainingHistory history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Training history', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            if (!history.hasEntries)
              Text(
                history.fallbackMessage!,
                style: theme.textTheme.bodyMedium,
              )
            else ...[
              Text(
                'Recent completed coaching cycles for this account.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
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

class _TrainingHistoryRow extends StatelessWidget {
  const _TrainingHistoryRow({
    required this.entry,
  });

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                entry.outcome.label,
                style: theme.textTheme.labelSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(entry.focusLabel, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          entry.resultSummary,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  String _formatDate(DateTime savedAt) {
    final local = savedAt.toLocal();
    final month = _monthLabels[local.month - 1];
    return '$month ${local.day}, ${local.year}';
  }
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
