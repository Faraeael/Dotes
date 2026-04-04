import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../matches/presentation/utils/hero_labels.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../data/local/shared_preferences_training_preferences_local_store.dart';
import '../data/local/training_preferences_local_store.dart';
import '../data/repositories/local_training_preferences_repository.dart';
import '../domain/models/coaching_source_summary.dart';
import '../domain/models/training_preferences.dart';
import '../domain/repositories/training_preferences_repository.dart';
import '../domain/services/coaching_source_summary_service.dart';

final trainingPreferencesLocalStoreProvider =
    Provider<TrainingPreferencesLocalStore>((ref) {
      return SharedPreferencesTrainingPreferencesLocalStore(
        SharedPreferencesAsync(),
      );
    });

final trainingPreferencesRepositoryProvider =
    Provider<TrainingPreferencesRepository>((ref) {
      final store = ref.watch(trainingPreferencesLocalStoreProvider);
      return LocalTrainingPreferencesRepository(store);
    });

final _loadedTrainingPreferencesAccountIdProvider = StateProvider<int?>(
  (ref) => null,
);

final _loadedTrainingPreferencesStateProvider =
    StateProvider<TrainingPreferences>((ref) => const TrainingPreferences());

final currentTrainingPreferencesProvider = Provider<TrainingPreferences>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  final loadedAccountId = ref.watch(
    _loadedTrainingPreferencesAccountIdProvider,
  );
  if (importedPlayer == null ||
      loadedAccountId != importedPlayer.profile.accountId) {
    return const TrainingPreferences();
  }

  return ref.watch(_loadedTrainingPreferencesStateProvider);
});

final coachingSourceSummaryServiceProvider =
    Provider<CoachingSourceSummaryService>((ref) {
      return const CoachingSourceSummaryService();
    });

final coachingSourceSummaryProvider = Provider<CoachingSourceSummary?>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  if (importedPlayer == null) {
    return null;
  }

  final preferences = ref.watch(currentTrainingPreferencesProvider);
  return ref
      .watch(coachingSourceSummaryServiceProvider)
      .build(preferences, heroLabelFor: heroDisplayName);
});

final trainingPreferencesControllerProvider =
    Provider<TrainingPreferencesController>((ref) {
      final repository = ref.watch(trainingPreferencesRepositoryProvider);
      return TrainingPreferencesController(ref, repository);
    });

class TrainingPreferencesController {
  TrainingPreferencesController(this._ref, this._repository);

  final Ref _ref;
  final TrainingPreferencesRepository _repository;
  int _sessionRevision = 0;

  void clearSession() {
    _sessionRevision++;
    _ref.read(_loadedTrainingPreferencesAccountIdProvider.notifier).state =
        null;
    _ref.read(_loadedTrainingPreferencesStateProvider.notifier).state =
        const TrainingPreferences();
  }

  Future<void> loadForAccount(int accountId) async {
    final sessionRevision = ++_sessionRevision;
    _ref.read(_loadedTrainingPreferencesAccountIdProvider.notifier).state =
        null;
    _ref.read(_loadedTrainingPreferencesStateProvider.notifier).state =
        const TrainingPreferences();

    final preferences = await _repository.loadForAccount(accountId);
    if (_sessionRevision != sessionRevision) {
      return;
    }

    _ref.read(_loadedTrainingPreferencesAccountIdProvider.notifier).state =
        accountId;
    _ref.read(_loadedTrainingPreferencesStateProvider.notifier).state =
        preferences;
  }

  Future<void> loadSeededForAccount(
    int accountId,
    TrainingPreferences preferences,
  ) async {
    final sessionRevision = ++_sessionRevision;
    _ref.read(_loadedTrainingPreferencesAccountIdProvider.notifier).state =
        null;
    _ref.read(_loadedTrainingPreferencesStateProvider.notifier).state =
        const TrainingPreferences();
    if (_sessionRevision != sessionRevision) {
      return;
    }

    _ref.read(_loadedTrainingPreferencesAccountIdProvider.notifier).state =
        accountId;
    _ref.read(_loadedTrainingPreferencesStateProvider.notifier).state =
        preferences;
  }

  Future<void> saveForAccount(
    int accountId,
    TrainingPreferences preferences,
  ) async {
    final sessionRevision = _sessionRevision;
    await _repository.saveForAccount(accountId, preferences);
    if (_sessionRevision != sessionRevision) {
      return;
    }
    _ref.read(_loadedTrainingPreferencesAccountIdProvider.notifier).state =
        accountId;
    _ref.read(_loadedTrainingPreferencesStateProvider.notifier).state =
        preferences;
  }
}
