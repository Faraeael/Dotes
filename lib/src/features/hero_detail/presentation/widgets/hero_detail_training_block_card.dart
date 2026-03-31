import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/widgets/app_metric_grid.dart';
import '../../../../app/widgets/app_metric_tile.dart';
import '../../../training_preferences/application/manual_hero_block_action_providers.dart';
import '../../../training_preferences/domain/models/manual_hero_block_action.dart';

class HeroDetailTrainingBlockCard extends ConsumerWidget {
  const HeroDetailTrainingBlockCard({required this.heroId, super.key});

  final int heroId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final control = ref.watch(heroTrainingBlockControlProvider(heroId));
    if (control == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Training block',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AppMetricGrid(
              children: [
                AppMetricTile(label: 'Mode', value: control.coachingMode.label),
                AppMetricTile(
                  label: 'Locked block',
                  value: control.lockedBlockLabel,
                ),
              ],
            ),
            if (control.willSwitchToManualSetup) ...[
              const SizedBox(height: 12),
              Text(
                'Saving this action will switch to Prefer manual setup.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => _handlePrimaryAction(
                    context: context,
                    ref: ref,
                    control: control,
                  ),
                  child: Text(control.primaryAction.label),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePrimaryAction({
    required BuildContext context,
    required WidgetRef ref,
    required HeroTrainingBlockControl control,
  }) async {
    final controller = ref.read(heroTrainingBlockActionControllerProvider);
    switch (control.primaryAction) {
      case HeroTrainingBlockActionType.add:
        await controller.addHeroToCurrentBlock(heroId);
      case HeroTrainingBlockActionType.replace:
        final replaceHeroId = await _ReplaceHeroDialog.show(
          context,
          options: control.replaceOptions,
        );
        if (replaceHeroId == null) {
          return;
        }
        await controller.replaceHeroInCurrentBlock(
          heroId: heroId,
          replaceHeroId: replaceHeroId,
        );
      case HeroTrainingBlockActionType.remove:
        await controller.removeHeroFromCurrentBlock(heroId);
    }
  }
}

class _ReplaceHeroDialog extends StatelessWidget {
  const _ReplaceHeroDialog({required this.options});

  final List<HeroTrainingBlockReplaceOption> options;

  static Future<int?> show(
    BuildContext context, {
    required List<HeroTrainingBlockReplaceOption> options,
  }) {
    return showDialog<int>(
      context: context,
      builder: (_) => _ReplaceHeroDialog(options: options),
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
