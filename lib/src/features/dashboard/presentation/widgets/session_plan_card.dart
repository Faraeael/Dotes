import 'package:flutter/material.dart';

import '../../domain/models/session_plan.dart';

class SessionPlanCard extends StatelessWidget {
  const SessionPlanCard({
    required this.plan,
    super.key,
  });

  final SessionPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session plan', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SessionPlanMetric(label: 'Queue', value: plan.queue),
                _SessionPlanMetric(label: 'Hero block', value: plan.heroBlock),
                _SessionPlanMetric(label: 'Target', value: plan.target),
                _SessionPlanMetric(
                  label: 'Review',
                  value: plan.reviewWindow,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionPlanMetric extends StatelessWidget {
  const _SessionPlanMetric({
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
