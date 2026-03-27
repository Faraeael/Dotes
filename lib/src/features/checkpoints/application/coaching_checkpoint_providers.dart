import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../insights/application/coaching_insights_provider.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../../roles/application/sample_role_summary_provider.dart';
import '../data/local/checkpoint_local_store.dart';
import '../data/local/shared_preferences_checkpoint_local_store.dart';
import '../data/repositories/local_coaching_checkpoint_repository.dart';
import '../domain/models/coaching_checkpoint.dart';
import '../domain/repositories/coaching_checkpoint_repository.dart';

final checkpointLocalStoreProvider = Provider<CheckpointLocalStore>((ref) {
  return SharedPreferencesCheckpointLocalStore(SharedPreferencesAsync());
});

final coachingCheckpointRepositoryProvider =
    Provider<CoachingCheckpointRepository>((ref) {
      final store = ref.watch(checkpointLocalStoreProvider);
      return LocalCoachingCheckpointRepository(store);
    });

final previousCoachingCheckpointProvider =
    StateProvider<CoachingCheckpoint?>((ref) => null);

final _savedCheckpointFingerprintProvider = StateProvider<String?>(
  (ref) => null,
);

final currentCoachingCheckpointDraftProvider =
    Provider<CoachingCheckpointDraft?>((ref) {
      final importedPlayer = ref.watch(importedPlayerProvider);
      final sampleRoleSummary = ref.watch(sampleRoleSummaryProvider);
      final nextGamesFocus = ref.watch(nextGamesFocusProvider);
      if (importedPlayer == null ||
          sampleRoleSummary == null ||
          nextGamesFocus == null) {
        return null;
      }

      return CoachingCheckpointDraft(
        accountId: importedPlayer.profile.accountId,
        focusAction: nextGamesFocus.action,
        focusSourceLabel: nextGamesFocus.sourceLabel,
        topInsightType: nextGamesFocus.sourceType,
        sample: CoachingCheckpointSample.fromImportedPlayer(
          importedPlayer,
          sampleRoleSummary,
        ),
      );
    });

final checkpointPersistenceControllerProvider =
    Provider<CheckpointPersistenceController>((ref) {
      final repository = ref.watch(coachingCheckpointRepositoryProvider);
      return CheckpointPersistenceController(ref, repository);
    });

class CheckpointPersistenceController {
  CheckpointPersistenceController(this._ref, this._repository);

  final Ref _ref;
  final CoachingCheckpointRepository _repository;

  void clearSession() {
    _ref.read(previousCoachingCheckpointProvider.notifier).state = null;
    _ref.read(_savedCheckpointFingerprintProvider.notifier).state = null;
  }

  Future<void> loadPreviousForAccount(int accountId) async {
    final checkpoint = await _repository.loadForAccount(accountId);
    _ref.read(previousCoachingCheckpointProvider.notifier).state = checkpoint;
    _ref.read(_savedCheckpointFingerprintProvider.notifier).state = null;
  }

  Future<void> saveCurrentDraftIfNeeded(CoachingCheckpointDraft draft) async {
    final savedFingerprint = _ref.read(_savedCheckpointFingerprintProvider);
    if (savedFingerprint == draft.fingerprint) {
      return;
    }

    await _repository.saveDraft(draft);
    _ref.read(_savedCheckpointFingerprintProvider.notifier).state =
        draft.fingerprint;
  }
}
