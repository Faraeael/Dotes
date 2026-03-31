import 'dart:convert';

import '../../domain/models/training_preferences.dart';
import '../../domain/repositories/training_preferences_repository.dart';
import '../local/training_preferences_local_store.dart';

class LocalTrainingPreferencesRepository
    implements TrainingPreferencesRepository {
  LocalTrainingPreferencesRepository(this._store);

  final TrainingPreferencesLocalStore _store;

  @override
  Future<TrainingPreferences> loadForAccount(int accountId) async {
    final rawValue = await _store.getString(_storageKey(accountId));
    if (rawValue == null || rawValue.isEmpty) {
      return const TrainingPreferences();
    }

    try {
      final json = jsonDecode(rawValue);
      if (json is! Map<dynamic, dynamic>) {
        return const TrainingPreferences();
      }

      return TrainingPreferences.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return const TrainingPreferences();
    }
  }

  @override
  Future<void> saveForAccount(
    int accountId,
    TrainingPreferences preferences,
  ) async {
    await _store.setString(
      _storageKey(accountId),
      jsonEncode(preferences.toJson()),
    );
  }

  String _storageKey(int accountId) => 'training_preferences.$accountId';
}
