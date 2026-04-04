import 'package:flutter/material.dart';

import '../../../../app/widgets/app_card_header.dart';
import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../../../app/widgets/app_status_badge.dart';
import '../../domain/models/block_review.dart';
import '../../domain/models/end_block_summary.dart';

class EndBlockSummaryCard extends StatelessWidget {
  const EndBlockSummaryCard({
    required this.summary,
    this.onSaveSummary,
    super.key,
  });

  final EndBlockSummary summary;
  final VoidCallback? onSaveSummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCardHeader(
              title: 'End block summary',
              subtitle: 'Wrap-up for the completed 5-game block.',
              trailing: AppStatusBadge(
                label: summary.outcome.label,
                tone: _toneForOutcome(summary.outcome),
              ),
            ),
            const SizedBox(height: 16),
            AppMetricGrid(
              children: [
                AppMetricTile(label: 'Outcome', value: summary.outcome.label),
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
            Text('Takeaway: ${summary.takeaway}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              'Next: ${summary.nextStepSuggestion}',
              style: theme.textTheme.bodyMedium,
            ),
            if (onSaveSummary != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonal(
                  onPressed: onSaveSummary,
                  child: const Text('Save summary'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  AppStatusTone _toneForOutcome(BlockReviewOutcome outcome) {
    return switch (outcome) {
      BlockReviewOutcome.onTrack => AppStatusTone.positive,
      BlockReviewOutcome.mixed => AppStatusTone.warning,
      BlockReviewOutcome.offTrack => AppStatusTone.negative,
    };
  }
}
