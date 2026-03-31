import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../matches/presentation/utils/hero_labels.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../domain/models/manual_hero_block_action.dart';
import '../domain/models/training_preferences.dart';
import '../domain/services/manual_hero_block_action_service.dart';
import 'training_preferences_providers.dart';

final manualHeroBlockActionServiceProvider =
    Provider<ManualHeroBlockActionService>((ref) {
      return const ManualHeroBlockActionService();
    });

final heroTrainingBlockControlProvider =
    Provider.family<HeroTrainingBlockControl?, int>((ref, heroId) {
      final importedPlayer = ref.watch(importedPlayerProvider);
      if (importedPlayer == null) {
        return null;
      }

      final preferences = ref.watch(currentTrainingPreferencesProvider);
      return ref
          .watch(manualHeroBlockActionServiceProvider)
          .buildControl(
            heroId: heroId,
            preferences: preferences,
            heroLabelFor: heroDisplayName,
          );
    });

final heroTrainingBlockActionControllerProvider =
    Provider<HeroTrainingBlockActionController>((ref) {
      return HeroTrainingBlockActionController(
        ref,
        ref.watch(manualHeroBlockActionServiceProvider),
        ref.watch(trainingPreferencesControllerProvider),
      );
    });

class HeroTrainingBlockActionController {
  HeroTrainingBlockActionController(
    this._ref,
    this._service,
    this._trainingPreferencesController,
  );

  final Ref _ref;
  final ManualHeroBlockActionService _service;
  final TrainingPreferencesController _trainingPreferencesController;

  Future<void> addHeroToCurrentBlock(int heroId) async {
    final accountId = _currentAccountId();
    if (accountId == null) {
      return;
    }

    final updatedPreferences = _service.addHeroToBlock(
      heroId: heroId,
      preferences: _currentPreferences(),
    );
    await _trainingPreferencesController.saveForAccount(
      accountId,
      updatedPreferences,
    );
  }

  Future<void> replaceHeroInCurrentBlock({
    required int heroId,
    required int replaceHeroId,
  }) async {
    final accountId = _currentAccountId();
    if (accountId == null) {
      return;
    }

    final updatedPreferences = _service.replaceHeroInBlock(
      heroId: heroId,
      replaceHeroId: replaceHeroId,
      preferences: _currentPreferences(),
    );
    await _trainingPreferencesController.saveForAccount(
      accountId,
      updatedPreferences,
    );
  }

  Future<void> removeHeroFromCurrentBlock(int heroId) async {
    final accountId = _currentAccountId();
    if (accountId == null) {
      return;
    }

    final updatedPreferences = _service.removeHeroFromBlock(
      heroId: heroId,
      preferences: _currentPreferences(),
    );
    await _trainingPreferencesController.saveForAccount(
      accountId,
      updatedPreferences,
    );
  }

  int? _currentAccountId() {
    return _ref.read(importedPlayerProvider)?.profile.accountId;
  }

  TrainingPreferences _currentPreferences() {
    return _ref.read(currentTrainingPreferencesProvider);
  }
}
