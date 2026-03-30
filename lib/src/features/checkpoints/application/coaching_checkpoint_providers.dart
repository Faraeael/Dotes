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
import '../domain/services/checkpoint_save_policy_service.dart';

final checkpointLocalStoreProvider = Provider<CheckpointLocalStore>((ref) {
  return SharedPreferencesCheckpointLocalStore(SharedPreferencesAsync());
});

final coachingCheckpointRepositoryProvider =
    Provider<CoachingCheckpointRepository>((ref) {
      final store = ref.watch(checkpointLocalStoreProvider);
      return LocalCoachingCheckpointRepository(store);
    });

final checkpointSavePolicyServiceProvider =
    Provider<CheckpointSavePolicyService>((ref) {
      return const CheckpointSavePolicyService();
    });

final previousCoachingCheckpointProvider =
    StateProvider<CoachingCheckpoint?>((ref) => null);

final coachingCheckpointHistoryProvider =
    StateProvider<List<CoachingCheckpoint>>((ref) => const []);

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
        focusHeroBlock: nextGamesFocus.heroBlock == null
            ? null
            : CoachingCheckpointHeroBlock.fromNextGamesFocusHeroBlock(
                nextGamesFocus.heroBlock!,
              ),
        sample: CoachingCheckpointSample.fromImportedPlayer(
          importedPlayer,
          sampleRoleSummary,
        ),
      );
    });

final checkpointPersistenceControllerProvider =
    Provider<CheckpointPersistenceController>((ref) {
      final repository = ref.watch(coachingCheckpointRepositoryProvider);
      final savePolicyService = ref.watch(checkpointSavePolicyServiceProvider);
      return CheckpointPersistenceController(ref, repository, savePolicyService);
    });

class CheckpointPersistenceController {
  CheckpointPersistenceController(
    this._ref,
    this._repository,
    this._savePolicyService,
  );

  final Ref _ref;
  final CoachingCheckpointRepository _repository;
  final CheckpointSavePolicyService _savePolicyService;

  void clearSession() {
    _ref.read(previousCoachingCheckpointProvider.notifier).state = null;
    _ref.read(coachingCheckpointHistoryProvider.notifier).state = const [];
    _ref.read(_savedCheckpointFingerprintProvider.notifier).state = null;
  }

  Future<void> loadPreviousForAccount(int accountId) async {
    final history = await _repository.loadHistoryForAccount(accountId);
    final checkpoint = history.isEmpty ? null : history.first;
    _ref.read(coachingCheckpointHistoryProvider.notifier).state = history;
    _ref.read(previousCoachingCheckpointProvider.notifier).state = checkpoint;
    _ref.read(_savedCheckpointFingerprintProvider.notifier).state =
        checkpoint?.fingerprint;
  }

  Future<void> saveCurrentDraftIfNeeded(CoachingCheckpointDraft draft) async {
    final savedFingerprint = _ref.read(_savedCheckpointFingerprintProvider);
    if (savedFingerprint == draft.fingerprint) {
      return;
    }

    final currentHistory = _ref.read(coachingCheckpointHistoryProvider);
    final lastCheckpoint = currentHistory.isEmpty ? null : currentHistory.first;
    final decision = _savePolicyService.evaluate(
      currentDraft: draft,
      lastCheckpoint: lastCheckpoint,
    );
    if (!decision.shouldSave) {
      return;
    }

    final checkpoint = await _repository.saveDraft(draft);
    _ref.read(coachingCheckpointHistoryProvider.notifier).state = [
      checkpoint,
      ...currentHistory,
    ];
    _ref.read(_savedCheckpointFingerprintProvider.notifier).state =
        checkpoint.fingerprint;
  }
}
