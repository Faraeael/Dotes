import '../../../training_preferences/domain/models/manual_hero_block_action.dart';
import '../models/hero_compare.dart';
import '../models/hero_compare_block_actions.dart';

class HeroCompareBlockActionsService {
  const HeroCompareBlockActionsService();

  HeroCompareBlockActions build({
    required HeroCompare compare,
    required HeroTrainingBlockControl leftControl,
    required HeroTrainingBlockControl rightControl,
  }) {
    return HeroCompareBlockActions(
      currentBlockLabel: leftControl.lockedBlockLabel,
      coachingModeLabel: leftControl.coachingMode.label,
      willSwitchToManualSetup:
          leftControl.willSwitchToManualSetup ||
          rightControl.willSwitchToManualSetup,
      leftHero: _entry(compare.primaryHero.heroName, compare.primaryHero.heroId, leftControl),
      rightHero: _entry(compare.secondaryHero.heroName, compare.secondaryHero.heroId, rightControl),
    );
  }

  HeroCompareBlockActionEntry _entry(
    String heroName,
    int heroId,
    HeroTrainingBlockControl control,
  ) {
    return HeroCompareBlockActionEntry(
      heroId: heroId,
      heroName: heroName,
      isAlreadyInBlock: control.heroAlreadyInBlock,
      actionType: control.primaryAction,
      actionLabel: switch (control.primaryAction) {
        HeroTrainingBlockActionType.add => 'Use $heroName in block',
        HeroTrainingBlockActionType.replace =>
          'Replace current block hero with $heroName',
        HeroTrainingBlockActionType.remove => '$heroName already in block',
      },
      replaceOptions: control.replaceOptions,
    );
  }
}
