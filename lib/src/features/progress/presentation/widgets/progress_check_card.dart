import 'package:flutter/material.dart';

import '../../../dashboard/presentation/widgets/section_card.dart';
import '../../domain/models/focus_follow_through_check.dart';
import '../../domain/models/progress_check.dart';

class ProgressCheckCard extends StatelessWidget {
  const ProgressCheckCard({
    required this.progressCheck,
    this.followThroughCheck,
    super.key,
  });

  final ProgressCheck progressCheck;
  final FocusFollowThroughCheck? followThroughCheck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!progressCheck.isReady && followThroughCheck == null) {
      return SectionCard(
        title: 'Progress check',
        body: progressCheck.fallbackMessage!,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress check', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              progressCheck.isReady
                  ? progressCheck.subtitle
                  : progressCheck.fallbackMessage!,
              style: theme.textTheme.bodyMedium,
            ),
            if (followThroughCheck != null) ...[
              const SizedBox(height: 12),
              _FollowThroughRow(followThroughCheck: followThroughCheck!),
            ],
            if (progressCheck.isReady) ...[
              const SizedBox(height: 16),
              for (
                var index = 0;
                index < progressCheck.comparisons.length;
                index++
              )
                Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        index == progressCheck.comparisons.length - 1 ? 0 : 12,
                  ),
                  child: _ComparisonRow(
                    comparison: progressCheck.comparisons[index],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FollowThroughRow extends StatelessWidget {
  const _FollowThroughRow({required this.followThroughCheck});

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
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({required this.comparison});

  final ProgressMetricComparison comparison;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            comparison.label,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              comparison.direction.label,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              comparison.detailLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ],
    );
  }
}
