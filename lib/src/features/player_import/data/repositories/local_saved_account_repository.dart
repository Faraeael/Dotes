import 'dart:convert';

import '../../domain/models/saved_account_entry.dart';
import '../../domain/repositories/saved_account_repository.dart';
import '../local/saved_accounts_local_store.dart';

class LocalSavedAccountRepository implements SavedAccountRepository {
  LocalSavedAccountRepository(this._store);

  static const _storageKey = 'player_import.saved_accounts.v1';

  final SavedAccountsLocalStore _store;

  @override
  Future<List<SavedAccountEntry>> loadAll() async {
    return _sortEntries(await _readEntries());
  }

  @override
  Future<void> saveEntry(SavedAccountEntry entry) async {
    final entries = await _readEntries();
    final existingIndex = entries.indexWhere(
      (candidate) => candidate.accountId == entry.accountId,
    );
    if (existingIndex >= 0) {
      final preservedPin = entries[existingIndex].isPinned;
      entries[existingIndex] = entry.copyWith(isPinned: preservedPin);
    } else {
      entries.add(entry);
    }
    await _writeEntries(entries);
  }

  @override
  Future<void> remove(int accountId) async {
    final entries = await _readEntries()
      ..removeWhere((candidate) => candidate.accountId == accountId);
    await _writeEntries(entries);
  }

  @override
  Future<void> setPinnedAccount(int? accountId) async {
    final entries = (await _readEntries())
        .map(
          (entry) => entry.copyWith(
            isPinned: accountId != null && entry.accountId == accountId,
          ),
        )
        .toList(growable: false);
    await _writeEntries(entries);
  }

  Future<List<SavedAccountEntry>> _readEntries() async {
    final raw = await _store.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <SavedAccountEntry>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <SavedAccountEntry>[];
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => SavedAccountEntry.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((entry) => entry.accountId > 0)
        .toList(growable: true);
  }

  Future<void> _writeEntries(List<SavedAccountEntry> entries) {
    final encoded = jsonEncode([
      for (final entry in _sortEntries(entries)) entry.toJson(),
    ]);
    return _store.setString(_storageKey, encoded);
  }

  List<SavedAccountEntry> _sortEntries(List<SavedAccountEntry> entries) {
    final sorted = [...entries];
    sorted.sort((left, right) {
      final pinnedComparison = (right.isPinned ? 1 : 0) - (left.isPinned ? 1 : 0);
      if (pinnedComparison != 0) {
        return pinnedComparison;
      }

      final lastOpenedComparison = right.lastOpenedAt.compareTo(left.lastOpenedAt);
      if (lastOpenedComparison != 0) {
        return lastOpenedComparison;
      }

      return left.accountId.compareTo(right.accountId);
    });
    return sorted;
  }
}
