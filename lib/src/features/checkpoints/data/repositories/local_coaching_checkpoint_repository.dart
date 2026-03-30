import 'dart:convert';

import '../../domain/models/coaching_checkpoint.dart';
import '../../domain/repositories/coaching_checkpoint_repository.dart';
import '../local/checkpoint_local_store.dart';

class LocalCoachingCheckpointRepository implements CoachingCheckpointRepository {
  LocalCoachingCheckpointRepository(this._store);

  final CheckpointLocalStore _store;

  @override
  Future<CoachingCheckpoint?> loadForAccount(int accountId) async {
    final history = await loadHistoryForAccount(accountId);
    if (history.isEmpty) {
      return null;
    }

    return history.first;
  }

  @override
  Future<List<CoachingCheckpoint>> loadHistoryForAccount(int accountId) async {
    final rawValue = await _store.getString(_storageKey(accountId));
    if (rawValue == null || rawValue.isEmpty) {
      return const [];
    }

    try {
      final json = jsonDecode(rawValue);
      return _decodeHistory(json);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<CoachingCheckpoint> saveDraft(CoachingCheckpointDraft draft) async {
    final history = await loadHistoryForAccount(draft.accountId);
    final checkpoint = draft.toCheckpoint(DateTime.now().toUtc());
    final updatedHistory = [
      checkpoint,
      ...history,
    ]..sort(_compareCheckpointsBySavedAtDesc);
    await _store.setString(
      _storageKey(draft.accountId),
      jsonEncode([
        for (final entry in updatedHistory) entry.toJson(),
      ]),
    );
    return checkpoint;
  }

  String _storageKey(int accountId) => 'coaching_checkpoint.$accountId';

  List<CoachingCheckpoint> _decodeHistory(dynamic json) {
    final history = switch (json) {
      List<dynamic>() => json
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (entry) => CoachingCheckpoint.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          )
          .toList(growable: false),
      Map<dynamic, dynamic>() => [
          CoachingCheckpoint.fromJson(Map<String, dynamic>.from(json)),
        ],
      _ => const <CoachingCheckpoint>[],
    };

    final sortedHistory = history.toList(growable: false)
      ..sort(_compareCheckpointsBySavedAtDesc);
    return sortedHistory;
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
