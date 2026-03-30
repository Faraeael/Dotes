import 'package:flutter/material.dart';

import '../../domain/models/block_review.dart';

class BlockReviewCard extends StatelessWidget {
  const BlockReviewCard({
    required this.review,
    super.key,
  });

  final BlockReview review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Block review', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _BlockReviewMetric(
                  label: 'Block status',
                  value: review.blockStatus.label,
                ),
                _BlockReviewMetric(
                  label: 'Games logged',
                  value: review.gamesLoggedLabel,
                ),
                _BlockReviewMetric(
                  label: 'Adherence',
                  value: review.adherence.label,
                ),
                _BlockReviewMetric(
                  label: 'Target result',
                  value: review.targetResult.label,
                ),
                _BlockReviewMetric(
                  label: 'Overall outcome',
                  value: review.overallOutcome.label,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockReviewMetric extends StatelessWidget {
  const _BlockReviewMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
