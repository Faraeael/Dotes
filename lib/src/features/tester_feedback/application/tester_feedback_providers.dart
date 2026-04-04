import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../player_import/application/imported_player_provider.dart';
import '../data/local/shared_preferences_tester_feedback_local_store.dart';
import '../data/local/tester_feedback_local_store.dart';
import '../data/repositories/local_tester_feedback_repository.dart';
import '../domain/models/tester_feedback.dart';
import '../domain/repositories/tester_feedback_repository.dart';

final testerFeedbackLocalStoreProvider = Provider<TesterFeedbackLocalStore>((
  ref,
) {
  return SharedPreferencesTesterFeedbackLocalStore(SharedPreferencesAsync());
});

final testerFeedbackRepositoryProvider = Provider<TesterFeedbackRepository>((
  ref,
) {
  final store = ref.watch(testerFeedbackLocalStoreProvider);
  return LocalTesterFeedbackRepository(store);
});

final _loadedTesterFeedbackAccountIdProvider = StateProvider<int?>((ref) {
  return null;
});

final _loadedTesterFeedbackStateProvider = StateProvider<TesterFeedback?>((
  ref,
) {
  return null;
});

final testerFeedbackCollectionRevisionProvider = StateProvider<int>((ref) {
  return 0;
});

final testerFeedbackClockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final currentTesterFeedbackProvider = Provider<TesterFeedback?>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  final loadedAccountId = ref.watch(_loadedTesterFeedbackAccountIdProvider);
  if (importedPlayer == null ||
      loadedAccountId != importedPlayer.profile.accountId) {
    return null;
  }

  return ref.watch(_loadedTesterFeedbackStateProvider);
});

final testerFeedbackControllerProvider = Provider<TesterFeedbackController>((
  ref,
) {
  final repository = ref.watch(testerFeedbackRepositoryProvider);
  final clock = ref.watch(testerFeedbackClockProvider);
  return TesterFeedbackController(ref, repository, clock);
});

class TesterFeedbackController {
  TesterFeedbackController(this._ref, this._repository, this._clock);

  final Ref _ref;
  final TesterFeedbackRepository _repository;
  final DateTime Function() _clock;
  int _sessionRevision = 0;

  void clearSession() {
    _sessionRevision++;
    _ref.read(_loadedTesterFeedbackAccountIdProvider.notifier).state = null;
    _ref.read(_loadedTesterFeedbackStateProvider.notifier).state = null;
  }

  Future<void> loadForAccount(int accountId) async {
    final sessionRevision = ++_sessionRevision;
    _ref.read(_loadedTesterFeedbackAccountIdProvider.notifier).state = null;
    _ref.read(_loadedTesterFeedbackStateProvider.notifier).state = null;

    final feedback = await _repository.loadForAccount(accountId);
    if (_sessionRevision != sessionRevision) {
      return;
    }

    _ref.read(_loadedTesterFeedbackAccountIdProvider.notifier).state =
        accountId;
    _ref.read(_loadedTesterFeedbackStateProvider.notifier).state = feedback;
  }

  Future<void> loadSeededForAccount(
    int accountId,
    TesterFeedback? feedback,
  ) async {
    final sessionRevision = ++_sessionRevision;
    _ref.read(_loadedTesterFeedbackAccountIdProvider.notifier).state = null;
    _ref.read(_loadedTesterFeedbackStateProvider.notifier).state = null;
    if (_sessionRevision != sessionRevision) {
      return;
    }

    _ref.read(_loadedTesterFeedbackAccountIdProvider.notifier).state =
        accountId;
    _ref.read(_loadedTesterFeedbackStateProvider.notifier).state = feedback;
  }

  Future<void> saveForAccount(
    int accountId,
    TesterFeedback feedback, {
    String? playerLabel,
  }) async {
    final sessionRevision = _sessionRevision;
    final stampedFeedback = feedback.copyWith(
      playerLabel: playerLabel,
      savedAt: _clock().toUtc(),
    );
    await _repository.saveForAccount(accountId, stampedFeedback);
    if (_sessionRevision != sessionRevision) {
      return;
    }
    _ref.read(testerFeedbackCollectionRevisionProvider.notifier).state++;
    _ref.read(_loadedTesterFeedbackAccountIdProvider.notifier).state =
        accountId;
    _ref.read(_loadedTesterFeedbackStateProvider.notifier).state =
        stampedFeedback;
  }
}
