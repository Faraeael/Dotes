import 'package:flutter/material.dart';

import '../../domain/models/playtest_summary.dart';
import '../../domain/models/tester_feedback.dart';
import 'playtest_summary_entry_tile.dart';

class PlaytestSummaryView extends StatelessWidget {
  const PlaytestSummaryView({
    required this.summary,
    required this.onFilterChanged,
    super.key,
  });

  final PlaytestSummary summary;
  final ValueChanged<TesterFeedbackRating?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('Clear ${summary.clearCount}')),
            Chip(label: Text('Somewhat clear ${summary.somewhatClearCount}')),
            Chip(label: Text('Confusing ${summary.confusingCount}')),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: summary.activeFilter == null,
              onSelected: (_) => onFilterChanged(null),
            ),
            for (final rating in TesterFeedbackRating.values)
              ChoiceChip(
                label: Text(rating.label),
                selected: summary.activeFilter == rating,
                onSelected: (_) => onFilterChanged(rating),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (!summary.hasEntries)
          Text(summary.emptyMessage)
        else
          SizedBox(
            width: double.maxFinite,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: summary.entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return PlaytestSummaryEntryTile(entry: summary.entries[index]);
                },
              ),
            ),
          ),
      ],
    );
  }
}
