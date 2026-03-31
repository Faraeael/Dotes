import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/playtest_summary_providers.dart';
import '../../domain/models/tester_feedback.dart';
import 'playtest_summary_view.dart';

class PlaytestSummaryDialog extends ConsumerWidget {
  const PlaytestSummaryDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const PlaytestSummaryDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(playtestSummaryProvider);

    return AlertDialog(
      title: const Text('Playtest summary'),
      content: SizedBox(
        width: 520,
        child: summary.when(
          data: (value) => PlaytestSummaryView(
            summary: value,
            onFilterChanged: (TesterFeedbackRating? rating) {
              ref.read(playtestSummaryFilterProvider.notifier).state = rating;
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              const Text('Could not load local playtest notes right now.'),
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
