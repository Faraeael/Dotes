import 'package:flutter/material.dart';

import '../../../../app/widgets/app_status_badge.dart';
import '../../domain/models/saved_block_summary.dart';

class SavedBlockSummaryRow extends StatelessWidget {
  const SavedBlockSummaryRow({
    required this.summary,
    required this.onCopy,
    super.key,
  });

  final SavedBlockSummary summary;
  final VoidCallback onCopy;

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
                '${summary.completionDateLabel} | saved ${_formatDate(summary.savedAt)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            AppStatusBadge(
              label: summary.outcome,
              tone: _toneForOutcome(summary.outcome),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(summary.playerLabel, style: theme.textTheme.titleMedium),
        if (summary.practiceNote != null) ...[
          const SizedBox(height: 4),
          Text(
            'Practice note: ${summary.practiceNote}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 4),
        Text(
          'Takeaway: ${summary.takeaway}',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text('Next: ${summary.nextStep}', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onCopy,
            child: const Text('Copy summary'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final month = _monthLabels[local.month - 1];
    return '$month ${local.day}, ${local.year}';
  }

  AppStatusTone _toneForOutcome(String outcome) {
    final normalized = outcome.toLowerCase();
    if (normalized.contains('on track')) {
      return AppStatusTone.positive;
    }
    if (normalized.contains('mixed')) {
      return AppStatusTone.warning;
    }
    return AppStatusTone.negative;
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
