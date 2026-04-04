import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/presentation/widgets/dashboard_shell.dart';
import '../../dashboard/presentation/widgets/section_card.dart';
import '../application/hero_compare_providers.dart';
import '../domain/models/hero_compare.dart';
import '../domain/models/hero_compare_block_actions.dart';
import 'widgets/hero_compare_block_state_card.dart';
import 'widgets/hero_compare_hero_card.dart';
import 'widgets/hero_compare_replace_hero_dialog.dart';
import '../../training_preferences/application/manual_hero_block_action_providers.dart';
import '../../training_preferences/domain/models/manual_hero_block_action.dart';

class HeroCompareScreen extends ConsumerWidget {
  const HeroCompareScreen({
    required this.primaryHeroId,
    required this.secondaryHeroId,
    super.key,
  });

  final int primaryHeroId;
  final int secondaryHeroId;

  static Route<void> route({
    required int primaryHeroId,
    required int secondaryHeroId,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => HeroCompareScreen(
        primaryHeroId: primaryHeroId,
        secondaryHeroId: secondaryHeroId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = HeroCompareRequest(
      primaryHeroId: primaryHeroId,
      secondaryHeroId: secondaryHeroId,
    );
    final compare = ref.watch(heroCompareProvider(request));
    final blockActions = ref.watch(heroCompareBlockActionsProvider(request));

    return DashboardShell(
      title: 'Hero compare',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (compare == null || blockActions == null)
              const SectionCard(
                title: 'Hero compare',
                body: 'Import a sample first, then choose two heroes to compare.',
              )
            else ...[
              HeroCompareBlockStateCard(blockActions: blockActions),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Comparison verdict',
                body: compare.verdict.message,
              ),
              const SizedBox(height: 16),
              HeroCompareHeroCard(
                detail: compare.primaryHero,
                blockAction: blockActions.leftHero,
                onUseHero: () => _handleBlockAction(
                  context: context,
                  ref: ref,
                  action: blockActions.leftHero,
                ),
              ),
              const SizedBox(height: 16),
              HeroCompareHeroCard(
                detail: compare.secondaryHero,
                blockAction: blockActions.rightHero,
                onUseHero: () => _handleBlockAction(
                  context: context,
                  ref: ref,
                  action: blockActions.rightHero,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleBlockAction({
    required BuildContext context,
    required WidgetRef ref,
    required HeroCompareBlockActionEntry action,
  }) async {
    final controller = ref.read(heroTrainingBlockActionControllerProvider);

    switch (action.actionType) {
      case HeroTrainingBlockActionType.add:
        await controller.addHeroToCurrentBlock(action.heroId);
      case HeroTrainingBlockActionType.replace:
        final replaceHeroId = await HeroCompareReplaceHeroDialog.show(
          context,
          options: action.replaceOptions,
        );
        if (replaceHeroId == null || !context.mounted) {
          return;
        }
        await controller.replaceHeroInCurrentBlock(
          heroId: action.heroId,
          replaceHeroId: replaceHeroId,
        );
      case HeroTrainingBlockActionType.remove:
        return;
    }
  }
}
