import '../models/manual_hero_block_action.dart';
import '../models/training_preferences.dart';

class ManualHeroBlockActionService {
  const ManualHeroBlockActionService();

  HeroTrainingBlockControl buildControl({
    required int heroId,
    required TrainingPreferences preferences,
    required String Function(int heroId) heroLabelFor,
  }) {
    final lockedHeroIds = preferences.normalizedLockedHeroIds;
    final heroAlreadyInBlock = lockedHeroIds.contains(heroId);
    final primaryAction = heroAlreadyInBlock
        ? HeroTrainingBlockActionType.remove
        : lockedHeroIds.length < 2
        ? HeroTrainingBlockActionType.add
        : HeroTrainingBlockActionType.replace;

    return HeroTrainingBlockControl(
      coachingMode: preferences.coachingMode,
      lockedHeroIds: lockedHeroIds,
      lockedBlockLabel: _blockLabel(lockedHeroIds, heroLabelFor),
      primaryAction: primaryAction,
      willSwitchToManualSetup:
          preferences.coachingMode == TrainingCoachingMode.followAppRead,
      replaceOptions: primaryAction == HeroTrainingBlockActionType.replace
          ? lockedHeroIds
                .map(
                  (lockedHeroId) => HeroTrainingBlockReplaceOption(
                    heroId: lockedHeroId,
                    heroLabel: heroLabelFor(lockedHeroId),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  TrainingPreferences addHeroToBlock({
    required int heroId,
    required TrainingPreferences preferences,
  }) {
    final lockedHeroIds = preferences.normalizedLockedHeroIds;
    if (heroId <= 0 ||
        lockedHeroIds.contains(heroId) ||
        lockedHeroIds.length >= 2) {
      return _manualPreferences(preferences, lockedHeroIds);
    }

    return _manualPreferences(preferences, [...lockedHeroIds, heroId]);
  }

  TrainingPreferences replaceHeroInBlock({
    required int heroId,
    required int replaceHeroId,
    required TrainingPreferences preferences,
  }) {
    final lockedHeroIds = preferences.normalizedLockedHeroIds;
    if (heroId <= 0 ||
        !lockedHeroIds.contains(replaceHeroId) ||
        lockedHeroIds.length < 2) {
      return _manualPreferences(preferences, lockedHeroIds);
    }

    final updatedHeroIds = lockedHeroIds
        .map(
          (lockedHeroId) =>
              lockedHeroId == replaceHeroId ? heroId : lockedHeroId,
        )
        .toList(growable: false);
    return _manualPreferences(preferences, updatedHeroIds);
  }

  TrainingPreferences removeHeroFromBlock({
    required int heroId,
    required TrainingPreferences preferences,
  }) {
    final lockedHeroIds = preferences.normalizedLockedHeroIds;
    if (!lockedHeroIds.contains(heroId)) {
      return _manualPreferences(preferences, lockedHeroIds);
    }

    return _manualPreferences(
      preferences,
      lockedHeroIds
          .where((lockedHeroId) => lockedHeroId != heroId)
          .toList(growable: false),
    );
  }

  TrainingPreferences _manualPreferences(
    TrainingPreferences preferences,
    List<int> lockedHeroIds,
  ) {
    return preferences.copyWith(
      coachingMode: TrainingCoachingMode.preferManualSetup,
      lockedHeroIds: lockedHeroIds,
    );
  }

  String _blockLabel(
    List<int> heroIds,
    String Function(int heroId) heroLabelFor,
  ) {
    if (heroIds.isEmpty) {
      return 'None';
    }

    return heroIds.map(heroLabelFor).join(' + ');
  }
}
