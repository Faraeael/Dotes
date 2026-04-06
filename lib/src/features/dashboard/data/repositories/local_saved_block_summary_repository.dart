import 'dart:convert';

import '../../domain/models/saved_block_summary.dart';
import '../../domain/repositories/saved_block_summary_repository.dart';
import '../local/saved_block_summary_local_store.dart';

class LocalSavedBlockSummaryRepository implements SavedBlockSummaryRepository {
  LocalSavedBlockSummaryRepository(this._store);

  final SavedBlockSummaryLocalStore _store;

  @override
  Future<List<SavedBlockSummary>> loadForAccount(int accountId) async {
    final rawValue = await _store.getString(_storageKey(accountId));
    if (rawValue == null || rawValue.isEmpty) {
      return const [];
    }

    try {
      final json = jsonDecode(rawValue);
      if (json is! List<dynamic>) {
        return const [];
      }

      final entries =
          json
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (entry) => SavedBlockSummary.fromJsonOrNull(
                  Map<String, dynamic>.from(entry),
                ),
              )
              .whereType<SavedBlockSummary>()
              .toList(growable: false)
            ..sort(_compareBySavedAtDesc);
      return entries;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveForAccount(int accountId, SavedBlockSummary summary) async {
    final existing = await loadForAccount(accountId);
    final alreadySaved = existing.any(
      (entry) => entry.shareText == summary.shareText,
    );
    if (alreadySaved) {
      return;
    }

    final updated = [summary, ...existing]..sort(_compareBySavedAtDesc);
    await _store.setString(
      _storageKey(accountId),
      jsonEncode([for (final entry in updated) entry.toJson()]),
    );
  }

  String _storageKey(int accountId) => 'block_summary_archive.$accountId';

  int _compareBySavedAtDesc(SavedBlockSummary left, SavedBlockSummary right) {
    return right.savedAt.compareTo(left.savedAt);
  }
}
