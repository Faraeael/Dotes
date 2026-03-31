import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme_tokens.dart';
import '../../../../app/widgets/app_card_header.dart';
import '../../../../app/widgets/app_status_badge.dart';
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
    final tokens = AppThemeTokens.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppCardHeader(
              title: 'Verdict',
              subtitle:
                  'Fast read on the biggest leak to fix and the biggest edge to press.',
            ),
            const SizedBox(height: 16),
            if (!verdict.hasSignal)
              Text(
                verdict.fallbackMessage!,
                style: theme.textTheme.bodyMedium,
              )
            else ...[
              if (verdict.biggestLeak != null)
                _VerdictPanel(
                  badge: const AppStatusBadge(
                    label: 'Main leak',
                    tone: AppStatusTone.negative,
                  ),
                  message: verdict.biggestLeak!.message,
                  borderColor: tokens.negative.withAlpha(110),
                ),
              if (verdict.biggestLeak != null && verdict.biggestEdge != null)
                const SizedBox(height: 14),
              if (verdict.biggestEdge != null)
                _VerdictPanel(
                  badge: const AppStatusBadge(
                    label: 'Main edge',
                    tone: AppStatusTone.positive,
                  ),
                  message: verdict.biggestEdge!.message,
                  borderColor: tokens.positive.withAlpha(110),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerdictPanel extends StatelessWidget {
  const _VerdictPanel({
    required this.badge,
    required this.message,
    required this.borderColor,
  });

  final Widget badge;
  final String message;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          badge,
          const SizedBox(height: 12),
          Text(message, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
