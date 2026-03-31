import 'training_preferences.dart';

enum HeroTrainingBlockActionType {
  add('Add to training block'),
  replace('Replace in training block'),
  remove('Remove from training block');

  const HeroTrainingBlockActionType(this.label);

  final String label;
}

class HeroTrainingBlockReplaceOption {
  const HeroTrainingBlockReplaceOption({
    required this.heroId,
    required this.heroLabel,
  });

  final int heroId;
  final String heroLabel;
}

class HeroTrainingBlockControl {
  const HeroTrainingBlockControl({
    required this.coachingMode,
    required this.lockedHeroIds,
    required this.lockedBlockLabel,
    required this.primaryAction,
    required this.willSwitchToManualSetup,
    required this.replaceOptions,
  });

  final TrainingCoachingMode coachingMode;
  final List<int> lockedHeroIds;
  final String lockedBlockLabel;
  final HeroTrainingBlockActionType primaryAction;
  final bool willSwitchToManualSetup;
  final List<HeroTrainingBlockReplaceOption> replaceOptions;

  bool get heroAlreadyInBlock =>
      primaryAction == HeroTrainingBlockActionType.remove;
}
