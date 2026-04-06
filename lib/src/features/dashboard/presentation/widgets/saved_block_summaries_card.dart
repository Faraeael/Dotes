import 'package:flutter/material.dart';

import '../../../../app/widgets/app_card_header.dart';
import '../../domain/models/saved_block_summary.dart';
import 'saved_block_summary_row.dart';

class SavedBlockSummariesCard extends StatelessWidget {
  const SavedBlockSummariesCard({
    required this.summaries,
    required this.onCopySummary,
    super.key,
  });

  final List<SavedBlockSummary> summaries;
  final ValueChanged<String> onCopySummary;

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
              title: 'Saved summaries',
              subtitle: 'Completed block handoffs saved on this device.',
            ),
            const SizedBox(height: 12),
            if (summaries.isEmpty)
              Text(
                'No saved summaries yet. Save a completed block to keep a reusable handoff here.',
                style: theme.textTheme.bodyMedium,
              )
            else
              for (var index = 0; index < summaries.length; index++) ...[
                SavedBlockSummaryRow(
                  summary: summaries[index],
                  onCopy: () => onCopySummary(summaries[index].shareText),
                ),
                if (index < summaries.length - 1) const Divider(height: 20),
              ],
          ],
        ),
      ),
    );
  }
}
