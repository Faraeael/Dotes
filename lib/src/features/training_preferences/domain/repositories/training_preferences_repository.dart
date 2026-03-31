import '../models/training_preferences.dart';

abstract class TrainingPreferencesRepository {
  Future<TrainingPreferences> loadForAccount(int accountId);

  Future<void> saveForAccount(int accountId, TrainingPreferences preferences);
}
