import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/saved_accounts_local_store.dart';
import '../data/local/shared_preferences_saved_accounts_local_store.dart';
import '../data/repositories/local_saved_account_repository.dart';
import '../domain/models/player_profile_summary.dart';
import '../domain/models/saved_account_entry.dart';
import '../domain/repositories/saved_account_repository.dart';

final savedAccountsClockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final savedAccountsLocalStoreProvider = Provider<SavedAccountsLocalStore>((ref) {
  return SharedPreferencesSavedAccountsLocalStore(SharedPreferencesAsync());
});

final savedAccountRepositoryProvider = Provider<SavedAccountRepository>((ref) {
  final store = ref.watch(savedAccountsLocalStoreProvider);
  return LocalSavedAccountRepository(store);
});

final savedAccountsControllerProvider =
    StateNotifierProvider<SavedAccountsController, SavedAccountsState>((ref) {
      final repository = ref.watch(savedAccountRepositoryProvider);
      final clock = ref.watch(savedAccountsClockProvider);
      return SavedAccountsController(repository, clock);
    });

final recentSavedAccountsProvider = Provider<List<SavedAccountEntry>>((ref) {
  final state = ref.watch(savedAccountsControllerProvider);
  return state.entries
      .where((entry) => entry.sourceType == SavedAccountSourceType.real)
      .toList(growable: false);
});

final lastOpenedSavedAccountProvider = Provider<SavedAccountEntry?>((ref) {
  final entries = ref.watch(recentSavedAccountsProvider);
  if (entries.isEmpty) {
    return null;
  }

  return entries.reduce(
    (current, next) =>
        next.lastOpenedAt.isAfter(current.lastOpenedAt) ? next : current,
  );
});

class SavedAccountsController extends StateNotifier<SavedAccountsState> {
  SavedAccountsController(this._repository, this._clock)
    : super(const SavedAccountsState()) {
    unawaited(refresh());
  }

  final SavedAccountRepository _repository;
  final DateTime Function() _clock;
  bool _disposed = false;

  Future<void> refresh() async {
    final entries = await _repository.loadAll();
    if (_disposed) {
      return;
    }

    state = SavedAccountsState(hasLoaded: true, entries: entries);
  }

  Future<void> saveRealAccount(PlayerProfileSummary profile) async {
    await _repository.saveEntry(
      SavedAccountEntry(
        accountId: profile.accountId,
        displayName: profile.displayName,
        sourceType: SavedAccountSourceType.real,
        lastOpenedAt: _clock(),
      ),
    );
    await refresh();
  }

  Future<void> removeAccount(int accountId) async {
    await _repository.remove(accountId);
    await refresh();
  }

  Future<void> togglePinnedAccount(int accountId) async {
    final pinnedAccountId = state.entries
        .where((entry) => entry.isPinned)
        .map((entry) => entry.accountId)
        .cast<int?>()
        .firstOrNull;
    await _repository.setPinnedAccount(
      pinnedAccountId == accountId ? null : accountId,
    );
    await refresh();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class SavedAccountsState {
  const SavedAccountsState({
    this.hasLoaded = false,
    this.entries = const [],
  });

  final bool hasLoaded;
  final List<SavedAccountEntry> entries;
}
