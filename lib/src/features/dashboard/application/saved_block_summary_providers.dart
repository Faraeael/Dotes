import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../player_import/application/imported_player_provider.dart';
import '../data/local/saved_block_summary_local_store.dart';
import '../data/local/shared_preferences_saved_block_summary_local_store.dart';
import '../data/repositories/local_saved_block_summary_repository.dart';
import '../domain/models/block_summary_export.dart';
import '../domain/models/saved_block_summary.dart';
import '../domain/repositories/saved_block_summary_repository.dart';

final savedBlockSummaryLocalStoreProvider =
    Provider<SavedBlockSummaryLocalStore>((ref) {
      return SharedPreferencesSavedBlockSummaryLocalStore(
        SharedPreferencesAsync(),
      );
    });

final savedBlockSummaryRepositoryProvider =
    Provider<SavedBlockSummaryRepository>((ref) {
      final store = ref.watch(savedBlockSummaryLocalStoreProvider);
      return LocalSavedBlockSummaryRepository(store);
    });

final savedBlockSummaryClockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final _loadedSavedBlockSummaryAccountIdProvider = StateProvider<int?>((ref) {
  return null;
});

final _loadedSavedBlockSummariesStateProvider =
    StateProvider<List<SavedBlockSummary>>((ref) {
      return const [];
    });

final currentSavedBlockSummariesProvider = Provider<List<SavedBlockSummary>>((
  ref,
) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  final loadedAccountId = ref.watch(_loadedSavedBlockSummaryAccountIdProvider);
  if (importedPlayer == null ||
      loadedAccountId != importedPlayer.profile.accountId) {
    return const [];
  }

  return ref.watch(_loadedSavedBlockSummariesStateProvider);
});

final savedBlockSummaryControllerProvider =
    Provider<SavedBlockSummaryController>((ref) {
      final repository = ref.watch(savedBlockSummaryRepositoryProvider);
      final clock = ref.watch(savedBlockSummaryClockProvider);
      return SavedBlockSummaryController(ref, repository, clock);
    });

class SavedBlockSummaryController {
  SavedBlockSummaryController(this._ref, this._repository, this._clock);

  final Ref _ref;
  final SavedBlockSummaryRepository _repository;
  final DateTime Function() _clock;
  int _sessionRevision = 0;

  void clearSession() {
    _sessionRevision++;
    _ref.read(_loadedSavedBlockSummaryAccountIdProvider.notifier).state = null;
    _ref.read(_loadedSavedBlockSummariesStateProvider.notifier).state =
        const [];
  }

  Future<void> loadForAccount(int accountId) async {
    final sessionRevision = ++_sessionRevision;
    _ref.read(_loadedSavedBlockSummaryAccountIdProvider.notifier).state = null;
    _ref.read(_loadedSavedBlockSummariesStateProvider.notifier).state =
        const [];

    final summaries = await _repository.loadForAccount(accountId);
    if (_sessionRevision != sessionRevision) {
      return;
    }

    _ref.read(_loadedSavedBlockSummaryAccountIdProvider.notifier).state =
        accountId;
    _ref.read(_loadedSavedBlockSummariesStateProvider.notifier).state =
        summaries;
  }

  Future<void> loadSeededForAccount(
    int accountId,
    List<SavedBlockSummary> summaries,
  ) async {
    final sessionRevision = ++_sessionRevision;
    _ref.read(_loadedSavedBlockSummaryAccountIdProvider.notifier).state = null;
    _ref.read(_loadedSavedBlockSummariesStateProvider.notifier).state =
        const [];
    if (_sessionRevision != sessionRevision) {
      return;
    }

    final seeded = [...summaries]
      ..sort((left, right) => right.savedAt.compareTo(left.savedAt));
    _ref.read(_loadedSavedBlockSummaryAccountIdProvider.notifier).state =
        accountId;
    _ref.read(_loadedSavedBlockSummariesStateProvider.notifier).state = seeded;
  }

  Future<void> saveForAccount(int accountId, BlockSummaryExport summary) async {
    final sessionRevision = _sessionRevision;
    final stamped = SavedBlockSummary(
      playerLabel: summary.playerLabel,
      completionDateLabel: summary.completionDateLabel,
      outcome: summary.outcome,
      mainTargetResult: summary.mainTargetResult,
      adherenceResult: summary.adherenceResult,
      takeaway: summary.takeaway,
      nextStep: summary.nextStep,
      shareText: summary.shareText,
      savedAt: _clock().toUtc(),
      practiceNote: summary.practiceNote,
    );
    await _repository.saveForAccount(accountId, stamped);
    final summaries = await _repository.loadForAccount(accountId);
    if (_sessionRevision != sessionRevision) {
      return;
    }

    _ref.read(_loadedSavedBlockSummaryAccountIdProvider.notifier).state =
        accountId;
    _ref.read(_loadedSavedBlockSummariesStateProvider.notifier).state =
        summaries;
  }
}
