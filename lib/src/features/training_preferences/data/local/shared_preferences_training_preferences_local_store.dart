import 'package:shared_preferences/shared_preferences.dart';

import 'training_preferences_local_store.dart';

class SharedPreferencesTrainingPreferencesLocalStore
    implements TrainingPreferencesLocalStore {
  SharedPreferencesTrainingPreferencesLocalStore(this._preferences);

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> getString(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }
}
