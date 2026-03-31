import 'package:flutter/material.dart';

import '../../domain/models/tester_feedback.dart';

class TesterFeedbackDialog extends StatefulWidget {
  const TesterFeedbackDialog({
    required this.initialFeedback,
    super.key,
  });

  final TesterFeedback? initialFeedback;

  static Future<TesterFeedback?> show(
    BuildContext context, {
    required TesterFeedback? initialFeedback,
  }) {
    return showDialog<TesterFeedback>(
      context: context,
      builder: (_) => TesterFeedbackDialog(initialFeedback: initialFeedback),
    );
  }

  @override
  State<TesterFeedbackDialog> createState() => _TesterFeedbackDialogState();
}

class _TesterFeedbackDialogState extends State<TesterFeedbackDialog> {
  late TesterFeedbackRating _rating;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialFeedback?.rating ?? TesterFeedbackRating.somewhatClear;
    _noteController = TextEditingController(
      text: widget.initialFeedback?.trimmedNote ?? '',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Playtest feedback'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<TesterFeedbackRating>(
              initialValue: _rating,
              decoration: const InputDecoration(labelText: 'Clarity'),
              items: [
                for (final rating in TesterFeedbackRating.values)
                  DropdownMenuItem(
                    value: rating,
                    child: Text(rating.label),
                  ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() => _rating = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Quick note',
                hintText: 'What felt useful, unclear, or hard to trust?',
                helperText: 'Saved locally for this account.',
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              TesterFeedback(
                rating: _rating,
                note: _noteController.text,
              ),
            );
          },
          child: const Text('Save note'),
        ),
      ],
    );
  }
}
