import 'package:flutter/material.dart';

import '../../../checkpoints/domain/models/training_block_action.dart';

class SessionPlanBlockActionPanel extends StatelessWidget {
  const SessionPlanBlockActionPanel({
    required this.control,
    required this.isSaving,
    required this.onPressed,
    super.key,
  });

  final TrainingBlockActionControl control;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Training block', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            control.blockStateLabel,
            style: theme.textTheme.titleSmall,
          ),
          if (control.blockStateDetail != null) ...[
            const SizedBox(height: 4),
            Text(
              control.blockStateDetail!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: isSaving ? null : onPressed,
            child: Text(isSaving ? 'Saving...' : control.actionType.label),
          ),
        ],
      ),
    );
  }
}
