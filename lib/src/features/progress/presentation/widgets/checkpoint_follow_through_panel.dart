import 'package:flutter/material.dart';

import '../../domain/models/focus_follow_through_check.dart';

class CheckpointFollowThroughPanel extends StatelessWidget {
  const CheckpointFollowThroughPanel({
    required this.followThroughCheck,
    super.key,
  });

  final FocusFollowThroughCheck followThroughCheck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Since last checkpoint', style: theme.textTheme.titleSmall),
          if (followThroughCheck.hasCheckpointContext) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ContextPill(
                  label: 'Saved',
                  value: _formatTimestamp(
                    followThroughCheck.checkpointSavedAt!,
                  ),
                ),
                _ContextPill(
                  label: 'Focus',
                  value: followThroughCheck.previousFocusLabel!,
                ),
                _ContextPill(
                  label: 'Status',
                  value: followThroughCheck.statusLabel!,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              followThroughCheck.comparisonLabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            followThroughCheck.isReady
                ? followThroughCheck.detail!
                : followThroughCheck.fallbackMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    final month = _monthLabels[local.month - 1];
    final hour = local.hour == 0
        ? 12
        : local.hour > 12
        ? local.hour - 12
        : local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final meridiem = local.hour >= 12 ? 'PM' : 'AM';

    return '$month ${local.day}, ${local.year} at $hour:$minute $meridiem';
  }
}

class _ContextPill extends StatelessWidget {
  const _ContextPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
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
