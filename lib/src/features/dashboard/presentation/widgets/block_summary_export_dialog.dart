import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../domain/models/block_summary_export.dart';

class BlockSummaryExportDialog extends StatelessWidget {
  const BlockSummaryExportDialog({required this.summary, super.key});

  final BlockSummaryExport summary;

  static Future<void> show(
    BuildContext context, {
    required BlockSummaryExport summary,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => BlockSummaryExportDialog(summary: summary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Summary ready to share'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(summary.playerLabel, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Completed ${summary.completionDateLabel}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Copy this result into tester notes, chat, or a handoff doc.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            AppMetricGrid(
              children: [
                AppMetricTile(label: 'Outcome', value: summary.outcome),
                AppMetricTile(
                  label: 'Main target',
                  value: summary.mainTargetResult,
                ),
                AppMetricTile(
                  label: 'Adherence',
                  value: summary.adherenceResult,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Takeaway: ${summary.takeaway}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('Next: ${summary.nextStep}', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: summary.shareText));
            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Summary copied for sharing')),
            );
          },
          child: const Text('Copy for sharing'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
