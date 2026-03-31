import 'package:flutter/material.dart';

import '../../../../app/widgets/app_card_header.dart';
import '../../../../app/widgets/app_status_badge.dart';
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
        body: 'No strong coaching signals stand out in this sample.',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppCardHeader(
              title: 'Coaching insights',
              subtitle: 'Top rule-based signals from this sample.',
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppStatusBadge(
              label: '${insight.severity.label} severity',
              tone: _toneForSeverity(insight.severity),
            ),
            AppStatusBadge(
              label: '${insight.confidence.label} confidence',
              tone: insight.confidence == CoachingInsightConfidence.high
                  ? AppStatusTone.positive
                  : insight.confidence == CoachingInsightConfidence.medium
                  ? AppStatusTone.info
                  : AppStatusTone.warning,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(insight.explanation, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  AppStatusTone _toneForSeverity(CoachingInsightSeverity severity) {
    return switch (severity) {
      CoachingInsightSeverity.low => AppStatusTone.info,
      CoachingInsightSeverity.medium => AppStatusTone.warning,
      CoachingInsightSeverity.high => AppStatusTone.negative,
    };
  }
}
