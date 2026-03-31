import 'dart:convert';

import '../../domain/models/tester_feedback.dart';
import '../../domain/models/tester_feedback_record.dart';
import '../../domain/repositories/tester_feedback_repository.dart';
import '../local/tester_feedback_local_store.dart';

class LocalTesterFeedbackRepository implements TesterFeedbackRepository {
  LocalTesterFeedbackRepository(this._store);

  final TesterFeedbackLocalStore _store;

  @override
  Future<List<TesterFeedbackRecord>> loadAll() async {
    final keys = (await _store.getKeys()).toList(growable: false)..sort();
    final records = <TesterFeedbackRecord>[];
    for (final key in keys) {
      final accountId = _parseAccountId(key);
      if (accountId == null) {
        continue;
      }

      final feedback = await loadForAccount(accountId);
      if (feedback == null) {
        continue;
      }

      records.add(
        TesterFeedbackRecord(accountId: accountId, feedback: feedback),
      );
    }

    return records;
  }

  @override
  Future<TesterFeedback?> loadForAccount(int accountId) async {
    final rawValue = await _store.getString(_storageKey(accountId));
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(rawValue);
      if (json is! Map<dynamic, dynamic>) {
        return null;
      }

      return TesterFeedback.fromJsonOrNull(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveForAccount(int accountId, TesterFeedback feedback) async {
    await _store.setString(
      _storageKey(accountId),
      jsonEncode(feedback.toJson()),
    );
  }

  String _storageKey(int accountId) => 'tester_feedback.$accountId';

  int? _parseAccountId(String key) {
    if (!key.startsWith('tester_feedback.')) {
      return null;
    }

    return int.tryParse(key.substring('tester_feedback.'.length));
  }
}
