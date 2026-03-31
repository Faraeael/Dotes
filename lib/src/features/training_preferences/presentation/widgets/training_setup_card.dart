import 'package:flutter/material.dart';

import '../../../../app/widgets/app_card_header.dart';
import '../../../../app/widgets/app_status_badge.dart';
import '../../domain/models/coaching_source_summary.dart';

class TrainingSetupCard extends StatelessWidget {
  const TrainingSetupCard({
    required this.summary,
    required this.onEdit,
    this.onShowHowItWorks,
    super.key,
  });

  final CoachingSourceSummary summary;
  final VoidCallback onEdit;
  final VoidCallback? onShowHowItWorks;

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
              title: 'Training setup',
              subtitle:
                  'Use app read by default, or lock a setup when role or hero read is noisy.',
              trailing: AppStatusBadge(
                label: summary.headline.contains('Manual')
                    ? 'Manual setup'
                    : 'App read',
                tone: summary.headline.contains('Manual')
                    ? AppStatusTone.info
                    : AppStatusTone.neutral,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(summary.headline, style: theme.textTheme.titleMedium),
                  if (summary.detail != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      summary.detail!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: onEdit,
                  child: const Text('Edit setup'),
                ),
                if (onShowHowItWorks != null)
                  TextButton(
                    onPressed: onShowHowItWorks,
                    child: const Text('View guide'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
