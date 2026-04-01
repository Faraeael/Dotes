import '../../../training_preferences/domain/models/manual_hero_block_action.dart';

class HeroCompareBlockActions {
  const HeroCompareBlockActions({
    required this.currentBlockLabel,
    required this.coachingModeLabel,
    required this.willSwitchToManualSetup,
    required this.leftHero,
    required this.rightHero,
  });

  final String currentBlockLabel;
  final String coachingModeLabel;
  final bool willSwitchToManualSetup;
  final HeroCompareBlockActionEntry leftHero;
  final HeroCompareBlockActionEntry rightHero;
}

class HeroCompareBlockActionEntry {
  const HeroCompareBlockActionEntry({
    required this.heroId,
    required this.heroName,
    required this.isAlreadyInBlock,
    required this.actionType,
    required this.actionLabel,
    required this.replaceOptions,
  });

  final int heroId;
  final String heroName;
  final bool isAlreadyInBlock;
  final HeroTrainingBlockActionType actionType;
  final String actionLabel;
  final List<HeroTrainingBlockReplaceOption> replaceOptions;
}
