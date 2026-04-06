import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../domain/models/block_summary_export.dart';

class BlockSummaryExportDialog extends StatelessWidget {
  const BlockSummaryExportDialog({
    required this.summary,
    this.savedToHistory = false,
    super.key,
  });

  final BlockSummaryExport summary;
  final bool savedToHistory;

  static Future<void> show(
    BuildContext context, {
    required BlockSummaryExport summary,
    bool savedToHistory = false,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => BlockSummaryExportDialog(
        summary: summary,
        savedToHistory: savedToHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.72;

    return AlertDialog(
      title: Text(savedToHistory ? 'Summary saved' : 'Summary ready to share'),
      content: SizedBox(
        width: 560,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
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
                  _introCopy,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                AppMetricGrid(
                  children: [
                    AppMetricTile(label: 'Outcome', value: summary.outcome),
                    AppMetricTile(
                      label: 'Target result',
                      value: summary.mainTargetResult,
                    ),
                    AppMetricTile(
                      label: 'Adherence',
                      value: summary.adherenceResult,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Block setup', style: theme.textTheme.titleSmall),
                const SizedBox(height: 6),
                ..._setupLines(theme),
                const SizedBox(height: 12),
                Text(
                  'Takeaway: ${summary.takeaway}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Next: ${summary.nextStep}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text('Share preview', style: theme.textTheme.titleSmall),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    summary.shareText,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async => _copy(context),
          child: const Text('Copy for sharing'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  String get _introCopy => savedToHistory
      ? 'This result is saved locally for this account and copied in a cleaner coaching-handoff format.'
      : 'Copy this result into tester notes, chat, or a handoff doc.';

  List<Widget> _setupLines(ThemeData theme) {
    final lines = <String>[
      if (summary.practiceNote != null)
        'Practice note: ${summary.practiceNote}',
      'Focus: ${summary.focusLabel}',
      'Queue: ${summary.queueLabel}',
      'Hero block: ${summary.heroBlockLabel}',
      'Target: ${summary.targetLabel}',
      'Review window: ${summary.reviewWindowLabel}',
    ];
    return [
      for (var index = 0; index < lines.length; index++) ...[
        Text(lines[index], style: theme.textTheme.bodyMedium),
        if (index < lines.length - 1) const SizedBox(height: 4),
      ],
    ];
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: summary.shareText));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Summary copied for sharing')));
  }
}
