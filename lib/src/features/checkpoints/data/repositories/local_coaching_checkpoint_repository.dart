import 'dart:convert';

import '../../domain/models/coaching_checkpoint.dart';
import '../../domain/repositories/coaching_checkpoint_repository.dart';
import '../local/checkpoint_local_store.dart';

class LocalCoachingCheckpointRepository implements CoachingCheckpointRepository {
  LocalCoachingCheckpointRepository(this._store);

  final CheckpointLocalStore _store;

  @override
  Future<CoachingCheckpoint?> loadForAccount(int accountId) async {
    final rawValue = await _store.getString(_storageKey(accountId));
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(rawValue);
      if (json is! Map<String, dynamic>) {
        return null;
      }

      return CoachingCheckpoint.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CoachingCheckpoint> saveDraft(CoachingCheckpointDraft draft) async {
    final checkpoint = draft.toCheckpoint(DateTime.now().toUtc());
    await _store.setString(
      _storageKey(draft.accountId),
      jsonEncode(checkpoint.toJson()),
    );
    return checkpoint;
  }

  String _storageKey(int accountId) => 'coaching_checkpoint.$accountId';
}
