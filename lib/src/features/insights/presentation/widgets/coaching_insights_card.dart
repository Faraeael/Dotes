import 'package:flutter/material.dart';

import '../../../dashboard/presentation/widgets/section_card.dart';
import '../../domain/models/coaching_insight.dart';

class CoachingInsightsCard extends StatelessWidget {
  const CoachingInsightsCard({
    required this.insights,
    super.key,
  });

  final List<CoachingInsight> insights;

  @override
  Widget build(BuildContext context) {
    final visibleInsights = insights.take(3).toList(growable: false);

    if (visibleInsights.isEmpty) {
      return const SectionCard(
        title: 'Coaching insights',
        body:
            'No strong rule-based coaching signals stand out in the current imported sample.',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coaching insights',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Top rule-based signals from the current imported sample.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            for (var index = 0; index < visibleInsights.length; index++) ...[
              _InsightRow(insight: visibleInsights[index]),
              if (index < visibleInsights.length - 1) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.insight});

  final CoachingInsight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(insight.title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          '${insight.severity.label} severity - ${insight.confidence.label} confidence',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(insight.explanation, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
