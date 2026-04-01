import 'package:flutter/material.dart';

import '../../../../app/widgets/app_status_badge.dart';
import '../../domain/models/saved_account_entry.dart';

class SavedAccountTile extends StatelessWidget {
  const SavedAccountTile({
    required this.entry,
    required this.isSubmitting,
    required this.onOpen,
    required this.onTogglePinned,
    required this.onRemove,
    super.key,
  });

  final SavedAccountEntry entry;
  final bool isSubmitting;
  final Future<void> Function() onOpen;
  final Future<void> Function() onTogglePinned;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (entry.isPinned)
                  const AppStatusBadge(
                    label: 'Pinned default',
                    tone: AppStatusTone.info,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Account ID ${entry.accountId}'),
            const SizedBox(height: 4),
            Text(
              '${entry.sourceLabel} • Last opened ${_formatLastOpened(entry.lastOpenedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: isSubmitting ? null : onOpen,
                    child: const Text('Open account'),
                  ),
                ),
                IconButton(
                  onPressed: isSubmitting ? null : onTogglePinned,
                  tooltip: entry.isPinned
                      ? 'Remove pinned default'
                      : 'Pin as default',
                  icon: Icon(
                    entry.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  ),
                ),
                IconButton(
                  onPressed: isSubmitting ? null : onRemove,
                  tooltip: 'Remove from device',
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastOpened(DateTime value) {
    final month = switch (value.month) {
      1 => 'Jan',
      2 => 'Feb',
      3 => 'Mar',
      4 => 'Apr',
      5 => 'May',
      6 => 'Jun',
      7 => 'Jul',
      8 => 'Aug',
      9 => 'Sep',
      10 => 'Oct',
      11 => 'Nov',
      _ => 'Dec',
    };
    final minute = value.minute.toString().padLeft(2, '0');
    return '$month ${value.day}, ${value.year} ${value.hour}:$minute';
  }
}
