import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../insights/application/coaching_insights_provider.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../../roles/application/sample_role_summary_provider.dart';
import '../data/local/checkpoint_local_store.dart';
import '../data/local/shared_preferences_checkpoint_local_store.dart';
import '../data/repositories/local_coaching_checkpoint_repository.dart';
import '../domain/models/coaching_checkpoint.dart';
import '../domain/models/checkpoint_save_status_summary.dart';
import '../domain/repositories/coaching_checkpoint_repository.dart';
import '../domain/services/checkpoint_save_policy_service.dart';
import '../domain/services/checkpoint_save_status_summary_service.dart';

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

final checkpointSaveStatusSummaryServiceProvider =
    Provider<CheckpointSaveStatusSummaryService>((ref) {
      return const CheckpointSaveStatusSummaryService();
    });

final previousCoachingCheckpointProvider = StateProvider<CoachingCheckpoint?>(
  (ref) => null,
);

final coachingCheckpointHistoryProvider =
    StateProvider<List<CoachingCheckpoint>>((ref) => const []);

final latestCheckpointSaveDecisionProvider =
    StateProvider<CheckpointSaveDecision?>((ref) => null);

final checkpointSaveStatusSummaryProvider =
    Provider<CheckpointSaveStatusSummary?>((ref) {
      final importedPlayer = ref.watch(importedPlayerProvider);
      final latestDecision = ref.watch(latestCheckpointSaveDecisionProvider);
      if (importedPlayer == null || latestDecision == null) {
        return null;
      }

      if (importedPlayer.profile.accountId != latestDecision.accountId) {
        return null;
      }

      final service = ref.watch(checkpointSaveStatusSummaryServiceProvider);
      return service.build(latestDecision);
    });

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
      return CheckpointPersistenceController(
        ref,
        repository,
        savePolicyService,
      );
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
  Future<CheckpointSaveDecision>? _saveInFlight;
  String? _saveInFlightFingerprint;
  String? _lastProcessedDraftFingerprint;
  CheckpointSaveDecision? _lastProcessedDecision;
  int _sessionRevision = 0;

  void clearSession() {
    _sessionRevision++;
    _ref.read(previousCoachingCheckpointProvider.notifier).state = null;
    _ref.read(coachingCheckpointHistoryProvider.notifier).state = const [];
    _ref.read(latestCheckpointSaveDecisionProvider.notifier).state = null;
    _saveInFlight = null;
    _saveInFlightFingerprint = null;
    _lastProcessedDraftFingerprint = null;
    _lastProcessedDecision = null;
  }

  Future<void> loadPreviousForAccount(int accountId) async {
    final sessionRevision = ++_sessionRevision;
    _saveInFlight = null;
    _saveInFlightFingerprint = null;
    _ref.read(latestCheckpointSaveDecisionProvider.notifier).state = null;
    _lastProcessedDraftFingerprint = null;
    _lastProcessedDecision = null;

    final history = await _repository.loadHistoryForAccount(accountId);
    if (_sessionRevision != sessionRevision) {
      return;
    }

    final checkpoint = history.isEmpty ? null : history.first;
    _ref.read(coachingCheckpointHistoryProvider.notifier).state = history;
    _ref.read(previousCoachingCheckpointProvider.notifier).state = checkpoint;
  }

  Future<CheckpointSaveDecision> saveCurrentDraftIfNeeded(
    CoachingCheckpointDraft draft,
  ) async {
    if (_lastProcessedDraftFingerprint == draft.fingerprint &&
        _lastProcessedDecision != null) {
      return _lastProcessedDecision!;
    }

    final saveInFlight = _saveInFlight;
    if (saveInFlight != null) {
      if (_saveInFlightFingerprint == draft.fingerprint) {
        return saveInFlight;
      }

      await saveInFlight;
    }

    final saveOperation = _saveCurrentDraftIfNeededInternal(
      draft,
      _sessionRevision,
    );
    _saveInFlight = saveOperation;
    _saveInFlightFingerprint = draft.fingerprint;

    try {
      return await saveOperation;
    } finally {
      if (identical(_saveInFlight, saveOperation)) {
        _saveInFlight = null;
        _saveInFlightFingerprint = null;
      }
    }
  }

  Future<CoachingCheckpoint> startOrRestartBlock(
    CoachingCheckpointDraft draft,
  ) async {
    final saveInFlight = _saveInFlight;
    if (saveInFlight != null) {
      await saveInFlight;
    }

    final sessionRevision = _sessionRevision;
    final checkpoint = await _repository.saveDraft(draft);
    if (_sessionRevision != sessionRevision) {
      return checkpoint;
    }

    final currentHistory = _ref.read(coachingCheckpointHistoryProvider);
    final updatedHistory = [checkpoint, ...currentHistory]
      ..sort(_compareCheckpointsBySavedAtDesc);
    _ref.read(coachingCheckpointHistoryProvider.notifier).state = updatedHistory;
    _ref.read(previousCoachingCheckpointProvider.notifier).state = checkpoint;
    _rememberDecision(
      draftFingerprint: draft.fingerprint,
      decision: CheckpointSaveDecision(
        accountId: draft.accountId,
        status: CheckpointSaveStatus.saved,
        newWindowMatchCount: draft.sample.recentMatchesWindow.length,
        overlapCount: 0,
        blockFingerprint: draft.blockFingerprint,
      ),
      sessionRevision: sessionRevision,
    );
    return checkpoint;
  }

  Future<CheckpointSaveDecision> _saveCurrentDraftIfNeededInternal(
    CoachingCheckpointDraft draft,
    int sessionRevision,
  ) async {
    final currentHistory = _ref.read(coachingCheckpointHistoryProvider);
    final lastCheckpoint = currentHistory.isEmpty ? null : currentHistory.first;
    final decision = _savePolicyService.evaluate(
      currentDraft: draft,
      lastCheckpoint: lastCheckpoint,
    );
    if (!decision.shouldSave) {
      _rememberDecision(
        draftFingerprint: draft.fingerprint,
        decision: decision,
        sessionRevision: sessionRevision,
      );
      return decision;
    }

    final checkpoint = await _repository.saveDraft(draft);
    if (_sessionRevision != sessionRevision) {
      return decision;
    }

    _ref.read(coachingCheckpointHistoryProvider.notifier).state = [
      checkpoint,
      ...currentHistory,
    ];
    _rememberDecision(
      draftFingerprint: draft.fingerprint,
      decision: decision,
      sessionRevision: sessionRevision,
    );
    return decision;
  }

  void _rememberDecision({
    required String draftFingerprint,
    required CheckpointSaveDecision decision,
    required int sessionRevision,
  }) {
    if (_sessionRevision != sessionRevision) {
      return;
    }

    _lastProcessedDraftFingerprint = draftFingerprint;
    _lastProcessedDecision = decision;
    _ref.read(latestCheckpointSaveDecisionProvider.notifier).state = decision;
  }

  int _compareCheckpointsBySavedAtDesc(
    CoachingCheckpoint left,
    CoachingCheckpoint right,
  ) {
    final savedAtCompare = right.savedAt.compareTo(left.savedAt);
    if (savedAtCompare != 0) {
      return savedAtCompare;
    }

    final focusCompare = left.focusAction.compareTo(right.focusAction);
    if (focusCompare != 0) {
      return focusCompare;
    }

    return left.focusSourceLabel.compareTo(right.focusSourceLabel);
  }
}
