import 'package:flutter/material.dart';

import '../../domain/models/dashboard_onboarding_guide.dart';

class CoachingGuideDialog extends StatelessWidget {
  const CoachingGuideDialog({required this.guide, super.key});

  final DashboardOnboardingGuide guide;

  static Future<void> show(
    BuildContext context, {
    required DashboardOnboardingGuide guide,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => CoachingGuideDialog(guide: guide),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(guide.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _GuideLine extends StatelessWidget {
  const _GuideLine({required this.title, required this.description});

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
