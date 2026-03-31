import 'package:flutter/material.dart';

import '../../domain/models/dashboard_onboarding_guide.dart';

class DashboardOnboardingCard extends StatelessWidget {
  const DashboardOnboardingCard({
    required this.guide,
    required this.onDismiss,
    super.key,
  });

  final DashboardOnboardingGuide guide;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(guide.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(guide.subtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            for (final step in guide.steps) ...[
              _GuideLine(title: step.title, description: step.description),
              if (step != guide.steps.last) const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
            Text('Key cards', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final hint in guide.cardHints) ...[
              _GuideLine(title: hint.title, description: hint.description),
              if (hint != guide.cardHints.last) const SizedBox(height: 10),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onDismiss,
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideLine extends StatelessWidget {
  const _GuideLine({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 2),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
