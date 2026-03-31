import 'package:shared_preferences/shared_preferences.dart';

import 'tester_feedback_local_store.dart';

class SharedPreferencesTesterFeedbackLocalStore
    implements TesterFeedbackLocalStore {
  SharedPreferencesTesterFeedbackLocalStore(this._preferences);

  final SharedPreferencesAsync _preferences;

  @override
  Future<Set<String>> getKeys() {
    return _preferences.getKeys();
  }

  @override
  Future<String?> getString(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }
}
