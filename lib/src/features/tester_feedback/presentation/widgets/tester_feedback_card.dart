import 'package:flutter/material.dart';

import '../../domain/models/tester_feedback.dart';

class TesterFeedbackCard extends StatelessWidget {
  const TesterFeedbackCard({
    required this.feedback,
    required this.onEdit,
    required this.onShowSummary,
    super.key,
  });

  final TesterFeedback? feedback;
  final VoidCallback onEdit;
  final VoidCallback onShowSummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyText =
        feedback == null
            ? 'Save a quick local note on what felt clear, confusing, or worth following.'
            : 'Saved locally for this player so the latest test read is easy to revisit.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Playtest feedback', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(bodyText),
            if (feedback != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clarity: ${feedback!.rating.label}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback!.hasNote
                          ? feedback!.trimmedNote
                          : 'No note yet.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: onEdit,
                  child: Text(
                    feedback == null ? 'Add note' : 'Edit note',
                  ),
                ),
                TextButton(
                  onPressed: onShowSummary,
                  child: const Text('Playtest summary'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
