import 'package:flutter/material.dart';

import '../../domain/models/next_games_focus.dart';

class NextGamesFocusCard extends StatelessWidget {
  const NextGamesFocusCard({
    required this.focus,
    super.key,
  });

  final NextGamesFocus focus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(focus.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              focus.action,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Based on: ${focus.sourceLabel}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
