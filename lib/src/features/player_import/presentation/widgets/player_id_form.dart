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
    super.key,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final Future<void> Function() onSubmit;

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
                  'Enter a Dota account ID to load your latest sample and build the coaching loop.',
            ),
            const SizedBox(height: 24),
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
                labelText: 'Dota account ID',
                hintText: 'Example: 86745912',
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
                    : const Text('Load dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
