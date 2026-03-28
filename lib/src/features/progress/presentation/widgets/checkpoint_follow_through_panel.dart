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
          Text(
            followThroughCheck.isReady
                ? 'Since last checkpoint: ${followThroughCheck.status!.label}'
                : 'Since last checkpoint',
            style: theme.textTheme.titleSmall,
          ),
          if (followThroughCheck.hasCheckpointContext) ...[
            const SizedBox(height: 4),
            Text(
              'Saved ${_formatTimestamp(followThroughCheck.checkpointSavedAt!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Previous focus: ${followThroughCheck.previousFocusLabel!}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              followThroughCheck.comparisonLabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            followThroughCheck.isReady
                ? followThroughCheck.detail!
                : followThroughCheck.fallbackMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
