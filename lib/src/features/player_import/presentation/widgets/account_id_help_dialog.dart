import 'package:flutter/material.dart';

class AccountIdHelpDialog extends StatelessWidget {
  const AccountIdHelpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const AccountIdHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Find your account ID'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Use the numeric account ID for the player you want to review. Dotes imports public recent-match data from OpenDota.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text('Quick checks', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '- It should be digits only, similar to 86745912.\n'
                '- A display name or hero name will not work.\n'
                '- The account needs public match data exposed for OpenDota imports to succeed.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text('After import', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'The first import builds the current coaching read. After you play the next 5 games, import again to review that block.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
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
