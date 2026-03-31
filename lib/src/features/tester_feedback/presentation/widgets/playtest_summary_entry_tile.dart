import 'package:flutter/material.dart';

import '../../domain/models/playtest_summary.dart';

class PlaytestSummaryEntryTile extends StatelessWidget {
  const PlaytestSummaryEntryTile({
    required this.entry,
    super.key,
  });

  final PlaytestSummaryEntry entry;

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
          Text(entry.playerLabel, style: theme.textTheme.titleMedium),
          if (entry.accountLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              entry.accountLabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text('Rating: ${entry.ratingLabel}'),
          const SizedBox(height: 4),
          Text(entry.note),
          if (entry.savedAtLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              'Saved: ${entry.savedAtLabel!}',
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
