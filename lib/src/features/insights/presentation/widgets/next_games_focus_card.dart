import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme_tokens.dart';
import '../../../../app/widgets/app_status_badge.dart';
import '../../domain/models/next_games_focus.dart';

class NextGamesFocusCard extends StatelessWidget {
  const NextGamesFocusCard({required this.focus, super.key});

  final NextGamesFocus focus;

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
            Text(focus.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusBadge(
                  label: focus.sourceLabel,
                  tone: _toneForSource(focus.sourceLabel),
                ),
                AppStatusBadge(
                  label: focus.confidenceLabel,
                  tone: _toneForConfidence(focus.confidenceLabel),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'One clear emphasis for the next block so the review is easy to trust.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (focus.reasonLabel != null) ...[
              const SizedBox(height: 10),
              Text(
                'Why this focus: ${focus.reasonLabel!}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: tokens.panelBorderStrong),
              ),
              child: Text(focus.action, style: theme.textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }

  AppStatusTone _toneForSource(String sourceLabel) {
    final lower = sourceLabel.toLowerCase();
    if (lower.contains('limited') || lower.contains('noisy')) {
      return AppStatusTone.warning;
    }

    if (lower.contains('strong') || lower.contains('comfort')) {
      return AppStatusTone.positive;
    }

    return AppStatusTone.info;
  }

  AppStatusTone _toneForConfidence(String confidenceLabel) {
    final lower = confidenceLabel.toLowerCase();
    if (lower.contains('low') || lower.contains('limited')) {
      return AppStatusTone.warning;
    }

    if (lower.contains('high') || lower.contains('strong')) {
      return AppStatusTone.positive;
    }

    return AppStatusTone.info;
  }
}
