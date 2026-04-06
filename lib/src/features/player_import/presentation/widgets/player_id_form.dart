import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/widgets/app_card_header.dart';

class PlayerIdForm extends StatelessWidget {
  const PlayerIdForm({
    required this.controller,
    required this.isSubmitting,
    required this.errorText,
    required this.onChanged,
    required this.onSubmit,
    required this.onShowHowItWorks,
    required this.onShowAccountIdHelp,
    super.key,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final Future<void> Function() onSubmit;
  final VoidCallback onShowHowItWorks;
  final VoidCallback onShowAccountIdHelp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppCardHeader(
              title: 'Import player',
              subtitle:
                  'Load a recent public match sample to start or review a 5-game coaching block.',
            ),
            const SizedBox(height: 12),
            Text(
              'First import builds the current read and session plan. Later import reviews the finished block after 5 newer games.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                TextButton(
                  onPressed: onShowHowItWorks,
                  child: const Text('How coaching works'),
                ),
                TextButton(
                  onPressed: onShowAccountIdHelp,
                  child: const Text('How to find account ID'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(20),
              ],
              decoration: const InputDecoration(
                labelText: 'Account ID',
                hintText: 'Example: 86745912',
                helperText:
                    'Use the numeric account ID from a public Dota profile. You can switch accounts later.',
              ),
              onChanged: onChanged,
              onSubmitted: (_) => onSubmit(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: errorText == null
                    ? const SizedBox(height: 20)
                    : Text(
                        errorText!,
                        key: ValueKey(errorText),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSubmitting ? null : onSubmit,
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Import account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
