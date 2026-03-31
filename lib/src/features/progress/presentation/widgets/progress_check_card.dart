import 'package:flutter/material.dart';

import '../../../../app/widgets/app_card_header.dart';
import '../../../../app/theme/app_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/section_card.dart';
import 'checkpoint_follow_through_panel.dart';
import '../../domain/models/focus_follow_through_check.dart';
import '../../domain/models/progress_check.dart';

class ProgressCheckCard extends StatelessWidget {
  const ProgressCheckCard({
    required this.progressCheck,
    this.followThroughCheck,
    super.key,
  });

  final ProgressCheck progressCheck;
  final FocusFollowThroughCheck? followThroughCheck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!progressCheck.isReady && followThroughCheck == null) {
      return SectionCard(
        title: 'Progress check',
        body: progressCheck.fallbackMessage!,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppCardHeader(
              title: 'Progress check',
              subtitle:
                  'Compare the latest block to the one before it without losing the coaching read.',
            ),
            const SizedBox(height: 12),
            Text(
              progressCheck.isReady
                  ? progressCheck.subtitle
                  : progressCheck.fallbackMessage!,
              style: theme.textTheme.bodyMedium,
            ),
            if (followThroughCheck != null) ...[
              const SizedBox(height: 12),
              CheckpointFollowThroughPanel(
                followThroughCheck: followThroughCheck!,
              ),
            ],
            if (progressCheck.isReady) ...[
              const SizedBox(height: 16),
              for (
                var index = 0;
                index < progressCheck.comparisons.length;
                index++
              )
                Padding(
                  padding: EdgeInsets.only(
                    bottom: index == progressCheck.comparisons.length - 1
                        ? 0
                        : 12,
                  ),
                  child: _ComparisonRow(
                    comparison: progressCheck.comparisons[index],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({required this.comparison});

  final ProgressMetricComparison comparison;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(comparison.label, style: theme.textTheme.titleMedium),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _ComparisonBadge(direction: comparison.direction),
            const SizedBox(height: 2),
            Text(
              comparison.detailLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ],
    );
  }
}

class _ComparisonBadge extends StatelessWidget {
  const _ComparisonBadge({required this.direction});

  final ProgressDirection direction;

  static const _neutralGray = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppThemeTokens.of(context);
    final color = switch (direction) {
      ProgressDirection.up => tokens.positive,
      ProgressDirection.down => tokens.negative,
      ProgressDirection.same => _neutralGray,
      ProgressDirection.narrower => tokens.positive,
      ProgressDirection.wider => tokens.warning,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(72)),
      ),
      child: Text(
        direction.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
