import 'package:flutter/material.dart';

import '../../domain/models/dashboard_verdict.dart';

class VerdictCard extends StatelessWidget {
  const VerdictCard({
    required this.verdict,
    super.key,
  });

  final DashboardVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verdict', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            if (!verdict.hasSignal)
              Text(
                verdict.fallbackMessage!,
                style: theme.textTheme.bodyMedium,
              )
            else ...[
              if (verdict.biggestLeak != null)
                _VerdictRow(
                  label: 'Biggest leak',
                  message: verdict.biggestLeak!.message,
                ),
              if (verdict.biggestLeak != null && verdict.biggestEdge != null)
                const Divider(height: 20),
              if (verdict.biggestEdge != null)
                _VerdictRow(
                  label: 'Biggest edge',
                  message: verdict.biggestEdge!.message,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerdictRow extends StatelessWidget {
  const _VerdictRow({
    required this.label,
    required this.message,
  });

  final String label;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
