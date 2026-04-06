import 'package:flutter/material.dart';

class PracticeNoteDialog extends StatefulWidget {
  const PracticeNoteDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const PracticeNoteDialog(),
    );
  }

  @override
  State<PracticeNoteDialog> createState() => _PracticeNoteDialogState();
}

class _PracticeNoteDialogState extends State<PracticeNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add practice note'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Optional: capture what you were intentionally practicing in this block so the saved handoff stays easier to scan later.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 120,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Practice note',
                hintText:
                    'Example: practicing safer lane exits and staying on Slardar + Mars.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(''),
          child: const Text('Skip'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save with note'),
        ),
      ],
    );
  }
}
