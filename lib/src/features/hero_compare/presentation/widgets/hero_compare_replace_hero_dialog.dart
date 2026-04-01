import 'package:flutter/material.dart';

import '../../../training_preferences/domain/models/manual_hero_block_action.dart';

class HeroCompareReplaceHeroDialog extends StatelessWidget {
  const HeroCompareReplaceHeroDialog({
    required this.options,
    super.key,
  });

  final List<HeroTrainingBlockReplaceOption> options;

  static Future<int?> show(
    BuildContext context, {
    required List<HeroTrainingBlockReplaceOption> options,
  }) {
    return showDialog<int>(
      context: context,
      builder: (_) => HeroCompareReplaceHeroDialog(options: options),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Replace in training block'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose which locked hero to replace.'),
          const SizedBox(height: 12),
          for (final option in options)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(option.heroLabel),
              onTap: () => Navigator.of(context).pop(option.heroId),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
